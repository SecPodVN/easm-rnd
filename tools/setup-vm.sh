#!/bin/bash
#
# EASM Platform - Ubuntu 24.04 VM Setup Script
# Automates installation of MicroK8s, ArgoCD, and all dependencies
#
# Usage: ./setup-vm.sh [OPTIONS]
# Options:
#   --skip-system-update    Skip apt update/upgrade
#   --skip-microk8s         Skip MicroK8s installation
#   --skip-argocd           Skip ArgoCD installation
#   --skip-docker           Skip Docker installation
#   --metallb-range         MetalLB IP range (default: 192.168.1.200-192.168.1.210)
#   --help                  Show this help message
#

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
SKIP_SYSTEM_UPDATE=false
SKIP_MICROK8S=false
SKIP_ARGOCD=false
SKIP_DOCKER=false
METALLB_RANGE="192.168.1.200-192.168.1.210"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-system-update)
            SKIP_SYSTEM_UPDATE=true
            shift
            ;;
        --skip-microk8s)
            SKIP_MICROK8S=true
            shift
            ;;
        --skip-argocd)
            SKIP_ARGOCD=true
            shift
            ;;
        --skip-docker)
            SKIP_DOCKER=true
            shift
            ;;
        --metallb-range)
            METALLB_RANGE="$2"
            shift 2
            ;;
        --help)
            grep '^#' "$0" | grep -v '#!/bin/bash' | sed 's/^# //'
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Functions
print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

check_root() {
    if [[ $EUID -eq 0 ]]; then
        print_error "This script should NOT be run as root (don't use sudo)"
        print_info "The script will ask for sudo password when needed"
        exit 1
    fi
}

check_ubuntu_version() {
    if [[ ! -f /etc/os-release ]]; then
        print_error "Cannot detect OS version"
        exit 1
    fi

    source /etc/os-release
    if [[ "$ID" != "ubuntu" ]]; then
        print_warning "This script is designed for Ubuntu. Detected: $ID"
        read -p "Continue anyway? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi

    print_success "Detected: $PRETTY_NAME"
}

# Main installation functions

install_basic_tools() {
    print_header "Installing Basic Tools"

    if [[ "$SKIP_SYSTEM_UPDATE" = false ]]; then
        print_info "Updating system packages..."
        sudo apt update
        sudo apt upgrade -y
        print_success "System updated"
    else
        print_info "Skipping system update (--skip-system-update flag)"
    fi

    print_info "Installing essential packages..."
    sudo apt install -y \
        curl \
        wget \
        git \
        jq \
        ca-certificates \
        gnupg \
        lsb-release \
        apt-transport-https \
        software-properties-common \
        net-tools \
        vim \
        htop \
        unzip \
        snapd

    # Ensure snap is running
    sudo systemctl enable --now snapd.socket
    sudo ln -sf /var/lib/snapd/snap /snap 2>/dev/null || true

    print_success "Basic tools installed"
}

install_microk8s() {
    if [[ "$SKIP_MICROK8S" = true ]]; then
        print_info "Skipping MicroK8s installation (--skip-microk8s flag)"
        return
    fi

    print_header "Installing MicroK8s"

    # Check if already installed
    if command -v microk8s &> /dev/null; then
        print_warning "MicroK8s is already installed"
        microk8s version
        read -p "Reinstall? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_info "Skipping MicroK8s installation"
            return
        fi
    fi

    print_info "Installing MicroK8s (stable channel 1.32)..."
    sudo snap install microk8s --classic --channel=1.32/stable

    print_info "Adding user to microk8s group..."
    sudo usermod -a -G microk8s $USER
    sudo chown -f -R $USER ~/.kube

    print_info "Waiting for MicroK8s to be ready..."
    sudo microk8s status --wait-ready

    print_success "MicroK8s installed"
}

configure_microk8s() {
    if [[ "$SKIP_MICROK8S" = true ]]; then
        return
    fi

    print_header "Configuring MicroK8s Add-ons"

    print_info "Enabling essential add-ons..."

    # Enable add-ons one by one with status checks
    sudo microk8s enable dns
    print_success "DNS enabled"

    sudo microk8s enable storage
    print_success "Storage enabled"

    sudo microk8s enable ingress
    print_success "Ingress enabled"

    print_info "Configuring MetalLB with IP range: $METALLB_RANGE"
    sudo microk8s enable metallb:$METALLB_RANGE
    print_success "MetalLB enabled"

    sudo microk8s enable registry
    print_success "Registry enabled"

    sudo microk8s enable helm3
    print_success "Helm3 enabled"

    # Optional add-ons
    print_info "Enabling optional add-ons (dashboard, metrics-server)..."
    sudo microk8s enable dashboard
    sudo microk8s enable metrics-server

    print_info "Waiting for all pods to be ready..."
    sudo microk8s kubectl wait --for=condition=ready pod --all --all-namespaces --timeout=600s || {
        print_warning "Some pods are not ready yet. This might be normal."
    }

    print_success "MicroK8s configured"
}

setup_kubectl_alias() {
    if [[ "$SKIP_MICROK8S" = true ]]; then
        return
    fi

    print_header "Setting up kubectl and helm aliases"

    # Add aliases to .bashrc if not already present
    if ! grep -q "alias kubectl='microk8s kubectl'" ~/.bashrc; then
        echo "" >> ~/.bashrc
        echo "# MicroK8s aliases" >> ~/.bashrc
        echo "alias kubectl='microk8s kubectl'" >> ~/.bashrc
        echo "alias helm='microk8s helm3'" >> ~/.bashrc
        print_success "Added aliases to ~/.bashrc"
    else
        print_info "Aliases already exist in ~/.bashrc"
    fi

    # Export kubeconfig
    mkdir -p ~/.kube
    sudo microk8s config | tee ~/.kube/config > /dev/null
    print_success "Kubeconfig exported to ~/.kube/config"

    # Install kubectl separately (optional but useful)
    if ! command -v kubectl &> /dev/null; then
        print_info "Installing kubectl via snap..."
        sudo snap install kubectl --classic
        print_success "kubectl installed"
    fi
}

install_argocd() {
    if [[ "$SKIP_ARGOCD" = true ]]; then
        print_info "Skipping ArgoCD installation (--skip-argocd flag)"
        return
    fi

    print_header "Installing ArgoCD"

    # Use microk8s kubectl
    KUBECTL="sudo microk8s kubectl"

    # Create namespace
    print_info "Creating argocd namespace..."
    $KUBECTL create namespace argocd --dry-run=client -o yaml | $KUBECTL apply -f -

    # Install ArgoCD
    print_info "Installing ArgoCD manifests..."
    $KUBECTL apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

    print_info "Waiting for ArgoCD pods to be ready (this may take a few minutes)..."
    $KUBECTL wait --for=condition=ready pod --all -n argocd --timeout=600s || {
        print_warning "Some ArgoCD pods are not ready yet"
        $KUBECTL get pods -n argocd
    }

    print_success "ArgoCD installed"
}

configure_argocd_ingress() {
    if [[ "$SKIP_ARGOCD" = true ]]; then
        return
    fi

    print_header "Configuring ArgoCD Ingress"

    KUBECTL="sudo microk8s kubectl"

    # Create ingress for ArgoCD
    cat <<EOF | $KUBECTL apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: argocd-server-ingress
  namespace: argocd
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
    nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
spec:
  ingressClassName: nginx
  rules:
  - host: argocd.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: argocd-server
            port:
              number: 443
EOF

    print_success "ArgoCD ingress configured"
}

install_argocd_cli() {
    if [[ "$SKIP_ARGOCD" = true ]]; then
        return
    fi

    print_header "Installing ArgoCD CLI"

    if command -v argocd &> /dev/null; then
        print_info "ArgoCD CLI already installed"
        argocd version --client
        return
    fi

    print_info "Downloading ArgoCD CLI..."
    curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
    sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
    rm argocd-linux-amd64

    print_success "ArgoCD CLI installed"
    argocd version --client
}

install_docker() {
    if [[ "$SKIP_DOCKER" = true ]]; then
        print_info "Skipping Docker installation (--skip-docker flag)"
        return
    fi

    print_header "Installing Docker"

    if command -v docker &> /dev/null; then
        print_warning "Docker is already installed"
        docker --version
        read -p "Reinstall? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_info "Skipping Docker installation"
            return
        fi
    fi

    print_info "Adding Docker repository..."
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg

    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    print_info "Installing Docker packages..."
    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    print_info "Adding user to docker group..."
    sudo usermod -aG docker $USER

    print_success "Docker installed"
    docker --version
}

install_helm() {
    print_header "Installing Helm"

    if command -v helm &> /dev/null; then
        print_info "Helm already installed"
        helm version
        return
    fi

    print_info "Installing Helm..."
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

    print_success "Helm installed"
    helm version
}

display_summary() {
    print_header "Installation Summary"

    echo -e "${GREEN}Installation completed successfully!${NC}\n"

    echo "Installed components:"
    echo "-------------------"

    if [[ "$SKIP_MICROK8S" = false ]]; then
        echo -e "${GREEN}✓${NC} MicroK8s: $(sudo microk8s version | head -n1)"
        echo -e "${GREEN}✓${NC} kubectl: $(kubectl version --client --short 2>/dev/null || echo 'via microk8s')"
    fi

    if [[ "$SKIP_DOCKER" = false ]]; then
        echo -e "${GREEN}✓${NC} Docker: $(docker --version)"
    fi

    if [[ "$SKIP_ARGOCD" = false ]]; then
        echo -e "${GREEN}✓${NC} ArgoCD: Installed in namespace 'argocd'"
        echo -e "${GREEN}✓${NC} ArgoCD CLI: $(argocd version --client --short 2>/dev/null || echo 'installed')"
    fi

    echo -e "${GREEN}✓${NC} Helm: $(helm version --short 2>/dev/null || echo 'installed')"

    echo ""
    print_header "Next Steps"

    echo "1. ${YELLOW}Apply group changes (required for microk8s and docker):${NC}"
    echo "   newgrp microk8s"
    echo "   newgrp docker"
    echo "   ${BLUE}Or logout and login again${NC}"
    echo ""

    if [[ "$SKIP_ARGOCD" = false ]]; then
        echo "2. ${YELLOW}Get ArgoCD initial admin password:${NC}"
        echo "   sudo microk8s kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath=\"{.data.password}\" | base64 -d && echo"
        echo ""

        echo "3. ${YELLOW}Access ArgoCD UI:${NC}"
        echo "   Method 1 (Port Forward):"
        echo "     kubectl port-forward svc/argocd-server -n argocd 8080:443"
        echo "     Open: https://localhost:8080"
        echo ""
        echo "   Method 2 (Ingress):"
        echo "     Add to /etc/hosts: <VM_IP> argocd.local"
        echo "     Open: http://argocd.local"
        echo ""
    fi

    echo "4. ${YELLOW}Verify MicroK8s status:${NC}"
    echo "   microk8s status"
    echo "   kubectl get nodes"
    echo "   kubectl get pods --all-namespaces"
    echo ""

    echo "5. ${YELLOW}Deploy EASM platform:${NC}"
    echo "   See docs/PROXMOX-VM-SETUP.md for deployment instructions"
    echo ""

    print_info "Configuration saved. Log files: /var/log/microk8s/"
    print_success "Setup complete! 🎉"
}

# Main execution
main() {
    print_header "EASM Platform - VM Setup Script"

    check_root
    check_ubuntu_version

    print_info "Starting installation with the following options:"
    echo "  Skip system update: $SKIP_SYSTEM_UPDATE"
    echo "  Skip MicroK8s: $SKIP_MICROK8S"
    echo "  Skip ArgoCD: $SKIP_ARGOCD"
    echo "  Skip Docker: $SKIP_DOCKER"
    echo "  MetalLB IP range: $METALLB_RANGE"
    echo ""

    read -p "Continue? (Y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        print_info "Installation cancelled"
        exit 0
    fi

    # Run installation steps
    install_basic_tools
    install_microk8s
    configure_microk8s
    setup_kubectl_alias
    install_argocd
    configure_argocd_ingress
    install_argocd_cli
    install_docker
    install_helm

    display_summary
}

# Run main function
main "$@"
