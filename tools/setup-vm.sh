#!/bin/bash
#
# EASM Platform - Ubuntu 24.04 VM Setup Script
# Automates installation of MicroK8s, and all dependencies
#
# Usage: ./setup-vm.sh [OPTIONS]
# Options:
#   --skip-system-update    Skip apt update/upgrade
#   --skip-microk8s         Skip MicroK8s installation
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
METALLB_RANGE="192.168.1.200-192.168.1.210"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --metallb-range)
            METALLB_RANGE="$2"
            shift 2
            ;;
        --help|-h)
            grep '^#' "$0" | grep -v '#!/bin/bash' | sed 's/^# //'
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            echo "Use -h or --help for usage information"
            exit 1
            ;;
    esac
done

# Functions
print_header() {
    echo -e "\n========================================"
    echo -e "$1"
    echo -e "========================================\n"
}

print_success() {
    echo -e "\n${GREEN}$1${NC}\n"
}

print_warning() {
    echo -e "\n${YELLOW}$1${NC}\n"
}

print_error() {
    echo -e "\n${RED}$1${NC}\n"
}

print_info() {
    echo -e "\n$1${NC}\n"
}

check_root() {
    if [[ $EUID -eq 0 ]]; then
        print_warning "This script should NOT be run as root."
        print_info "The script will ask for sudo password when needed."
        exit 1
    fi
}

check_ubuntu_version() {
    if [[ ! -f /etc/os-release ]]; then
        print_error "Cannot detect OS version"
        exit 1
    fi

    source /etc/os-release
    if [[ "${ID}" != "ubuntu" ]]; then
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

system_update() {
    print_header "Updating System Packages"

    print_info "Updating system..."
    sudo apt update && sudo apt upgrade -y

    print_success "System packages updated"
}

install_basic_tools() {
    print_header "Installing Basic Tools"

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

    print_success "Basic tools installed"
}

install_microk8s() {
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

    print_info "Installing MicroK8s..."
    sudo snap install microk8s --classic --channel=1.34/stable

    print_info "Configuring UFW firewall..."
    sudo ufw allow in on cni0 && sudo ufw allow out on cni0
    sudo ufw default allow routed

    print_info "Waiting for MicroK8s to be ready..."
    sudo microk8s status --wait-ready

    print_info "Adding user to microk8s group..."
    sudo usermod -a -G microk8s $USER
    newgrp microk8s

    print_success "MicroK8s installed"
}

configure_microk8s() {
    print_header "Configuring MicroK8s Add-ons"

    print_info "Enabling required add-ons..."
    microk8s enable dashboard storage registry istio
    sudo microk8s enable dns helm3 ingress metallb:$METALLB_RANGE

    print_info "Listing MicroK8s status..."
    microk8s status

    print_success "MicroK8s configured"
}

setup_kubectl_alias() {
    print_header "Setting up kubectl alias"

    print_info "Creating kubectl alias..."
    sudo snap alias microk8s.kubectl kubectl
    print_success "kubectl alias created"
}



display_summary() {
    print_header "Installation Summary"

    echo -e "${GREEN}Installation completed successfully!${NC}\n"

    echo "Installed components:"
    echo "-------------------"

    if [[ "$SKIP_MICROK8S" = false ]]; then
        echo -e "${GREEN}✓${NC} MicroK8s: $(sudo microk8s version | head -n1)"
        echo -e "${GREEN}✓${NC} kubectl: $(kubectl version --client --short 2>/dev/null || echo 'via microk8s alias')"
    fi

    echo ""
    print_header "Next Steps"

    echo "2. Verify MicroK8s status:"
    echo "   microk8s status"
    echo "   kubectl get nodes"
    echo "   kubectl get pods --all-namespaces"
    echo ""

    echo "3. Deploy EASM platform:"
    echo "   See docs/PROXMOX-VM-SETUP.md for deployment instructions"
    echo ""

    print_success "All dependencies installed successfully!"
}

# Main execution
main() {
    print_header "EASM Platform - Setup Script"

    check_root
    check_ubuntu_version
    system_update
    install_basic_tools
    install_microk8s
    configure_microk8s
    setup_kubectl_alias
    display_summary
}

# Run main function
main "$@"
