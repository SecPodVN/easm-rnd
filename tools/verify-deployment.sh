#!/bin/bash
#
# EASM Platform - Deployment Verification Script
# Verifies that all components are installed and running correctly
#
# Usage: ./verify-deployment.sh [OPTIONS]
# Options:
#   --namespace NAMESPACE   Namespace to check (default: easm-platform)
#   --skip-microk8s        Skip MicroK8s checks
#   --skip-argocd          Skip ArgoCD checks
#   --skip-apps            Skip application checks
#   --help                 Show this help message
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
NAMESPACE="easm-platform"
SKIP_MICROK8S=false
SKIP_ARGOCD=false
SKIP_APPS=false

# Counters
CHECKS_PASSED=0
CHECKS_FAILED=0
CHECKS_WARNING=0

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --namespace)
            NAMESPACE="$2"
            shift 2
            ;;
        --skip-microk8s)
            SKIP_MICROK8S=true
            shift
            ;;
        --skip-argocd)
            SKIP_ARGOCD=true
            shift
            ;;
        --skip-apps)
            SKIP_APPS=true
            shift
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
    ((CHECKS_PASSED++))
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
    ((CHECKS_WARNING++))
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
    ((CHECKS_FAILED++))
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

# Determine kubectl command
if command -v microk8s &> /dev/null; then
    KUBECTL="microk8s kubectl"
elif command -v kubectl &> /dev/null; then
    KUBECTL="kubectl"
else
    print_error "kubectl not found"
    exit 1
fi

# Check functions

check_microk8s() {
    if [[ "$SKIP_MICROK8S" = true ]]; then
        print_info "Skipping MicroK8s checks"
        return
    fi

    print_header "Checking MicroK8s"

    if ! command -v microk8s &> /dev/null; then
        print_warning "MicroK8s not found (might be using standard kubectl)"
        return
    fi

    # Check MicroK8s status
    if microk8s status &> /dev/null; then
        print_success "MicroK8s is running"
    else
        print_error "MicroK8s is not running"
        return
    fi

    # Check version
    VERSION=$(microk8s version | head -n1 || echo "unknown")
    print_info "MicroK8s version: $VERSION"

    # Check enabled add-ons
    print_info "Checking MicroK8s add-ons..."

    ADDONS=(dns storage ingress registry helm3)
    for addon in "${ADDONS[@]}"; do
        if microk8s status | grep -q "$addon.*enabled"; then
            print_success "Add-on '$addon' is enabled"
        else
            print_warning "Add-on '$addon' is not enabled"
        fi
    done

    # Check optional add-ons
    OPTIONAL_ADDONS=(dashboard metrics-server metallb prometheus)
    for addon in "${OPTIONAL_ADDONS[@]}"; do
        if microk8s status | grep -q "$addon.*enabled"; then
            print_info "Optional add-on '$addon' is enabled"
        fi
    done
}

check_cluster() {
    print_header "Checking Kubernetes Cluster"

    # Check cluster connection
    if $KUBECTL cluster-info &> /dev/null; then
        print_success "Cluster is accessible"
    else
        print_error "Cannot connect to cluster"
        return
    fi

    # Check nodes
    print_info "Checking cluster nodes..."
    NODE_COUNT=$($KUBECTL get nodes --no-headers 2>/dev/null | wc -l)
    if [[ $NODE_COUNT -gt 0 ]]; then
        print_success "$NODE_COUNT node(s) found"

        # Check node status
        while IFS= read -r line; do
            NAME=$(echo "$line" | awk '{print $1}')
            STATUS=$(echo "$line" | awk '{print $2}')
            if [[ "$STATUS" == "Ready" ]]; then
                print_success "Node '$NAME' is Ready"
            else
                print_error "Node '$NAME' is $STATUS"
            fi
        done < <($KUBECTL get nodes --no-headers)
    else
        print_error "No nodes found"
    fi

    # Check Kubernetes version
    VERSION=$($KUBECTL version --short 2>/dev/null | grep "Server Version" || echo "unknown")
    print_info "$VERSION"
}

check_namespaces() {
    print_header "Checking Namespaces"

    REQUIRED_NAMESPACES=("kube-system" "$NAMESPACE")
    if [[ "$SKIP_ARGOCD" = false ]]; then
        REQUIRED_NAMESPACES+=("argocd")
    fi

    for ns in "${REQUIRED_NAMESPACES[@]}"; do
        if $KUBECTL get namespace "$ns" &> /dev/null; then
            print_success "Namespace '$ns' exists"
        else
            if [[ "$ns" == "$NAMESPACE" ]]; then
                print_warning "Namespace '$ns' does not exist (will be created by ArgoCD)"
            else
                print_error "Namespace '$ns' does not exist"
            fi
        fi
    done
}

check_system_pods() {
    print_header "Checking System Pods"

    # Check kube-system pods
    print_info "Checking kube-system pods..."
    SYSTEM_PODS=$($KUBECTL get pods -n kube-system --no-headers 2>/dev/null | wc -l)
    if [[ $SYSTEM_PODS -gt 0 ]]; then
        print_success "$SYSTEM_PODS system pod(s) found"

        # Check if all are running
        NOT_RUNNING=$($KUBECTL get pods -n kube-system --no-headers 2>/dev/null | grep -v "Running\|Completed" | wc -l)
        if [[ $NOT_RUNNING -eq 0 ]]; then
            print_success "All system pods are running"
        else
            print_warning "$NOT_RUNNING system pod(s) are not running"
            $KUBECTL get pods -n kube-system | grep -v "Running\|Completed" || true
        fi
    else
        print_error "No system pods found"
    fi

    # Check ingress controller
    print_info "Checking ingress controller..."
    if $KUBECTL get pods -n ingress --no-headers 2>/dev/null | grep -q "Running"; then
        print_success "Ingress controller is running"
    elif $KUBECTL get pods -n kube-system -l app.kubernetes.io/name=ingress-nginx --no-headers 2>/dev/null | grep -q "Running"; then
        print_success "Ingress controller is running (in kube-system)"
    else
        print_warning "Ingress controller not found or not running"
    fi
}

check_argocd() {
    if [[ "$SKIP_ARGOCD" = true ]]; then
        print_info "Skipping ArgoCD checks"
        return
    fi

    print_header "Checking ArgoCD"

    # Check ArgoCD namespace
    if ! $KUBECTL get namespace argocd &> /dev/null; then
        print_error "ArgoCD namespace does not exist"
        return
    fi

    # Check ArgoCD pods
    print_info "Checking ArgoCD pods..."
    ARGOCD_PODS=$($KUBECTL get pods -n argocd --no-headers 2>/dev/null | wc -l)
    if [[ $ARGOCD_PODS -gt 0 ]]; then
        print_success "$ARGOCD_PODS ArgoCD pod(s) found"

        # Check if all are running
        NOT_RUNNING=$($KUBECTL get pods -n argocd --no-headers 2>/dev/null | grep -v "Running\|Completed" | wc -l)
        if [[ $NOT_RUNNING -eq 0 ]]; then
            print_success "All ArgoCD pods are running"
        else
            print_error "$NOT_RUNNING ArgoCD pod(s) are not running"
            $KUBECTL get pods -n argocd | grep -v "Running\|Completed" || true
        fi
    else
        print_error "No ArgoCD pods found"
        return
    fi

    # Check ArgoCD server
    if $KUBECTL get svc argocd-server -n argocd &> /dev/null; then
        print_success "ArgoCD server service exists"
    else
        print_error "ArgoCD server service not found"
    fi

    # Check ArgoCD CLI
    if command -v argocd &> /dev/null; then
        VERSION=$(argocd version --client --short 2>/dev/null || echo "unknown")
        print_success "ArgoCD CLI is installed ($VERSION)"
    else
        print_warning "ArgoCD CLI not found"
    fi

    # Check ArgoCD applications
    print_info "Checking ArgoCD applications..."
    if command -v argocd &> /dev/null; then
        APP_COUNT=$(argocd app list 2>/dev/null | grep -v "NAME" | wc -l || echo 0)
        if [[ $APP_COUNT -gt 0 ]]; then
            print_info "$APP_COUNT ArgoCD application(s) configured"
            argocd app list 2>/dev/null || true
        else
            print_info "No ArgoCD applications configured yet"
        fi
    fi
}

check_applications() {
    if [[ "$SKIP_APPS" = true ]]; then
        print_info "Skipping application checks"
        return
    fi

    print_header "Checking EASM Applications"

    # Check if namespace exists
    if ! $KUBECTL get namespace "$NAMESPACE" &> /dev/null; then
        print_warning "Application namespace '$NAMESPACE' does not exist yet"
        print_info "Deploy applications with: kubectl apply -k k8s/argocd/"
        return
    fi

    # Check pods
    print_info "Checking application pods in namespace '$NAMESPACE'..."
    POD_COUNT=$($KUBECTL get pods -n "$NAMESPACE" --no-headers 2>/dev/null | wc -l)
    if [[ $POD_COUNT -gt 0 ]]; then
        print_success "$POD_COUNT application pod(s) found"

        # Check if all are running
        NOT_RUNNING=$($KUBECTL get pods -n "$NAMESPACE" --no-headers 2>/dev/null | grep -v "Running\|Completed" | wc -l)
        if [[ $NOT_RUNNING -eq 0 ]]; then
            print_success "All application pods are running"
        else
            print_warning "$NOT_RUNNING application pod(s) are not running"
            $KUBECTL get pods -n "$NAMESPACE" | grep -v "Running\|Completed" || true
        fi

        # Show pod details
        echo ""
        $KUBECTL get pods -n "$NAMESPACE"
    else
        print_info "No application pods found in namespace '$NAMESPACE'"
    fi

    # Check services
    print_info "Checking services..."
    SERVICES=$($KUBECTL get svc -n "$NAMESPACE" --no-headers 2>/dev/null | wc -l)
    if [[ $SERVICES -gt 0 ]]; then
        print_success "$SERVICES service(s) found"
        $KUBECTL get svc -n "$NAMESPACE"
    else
        print_info "No services found"
    fi

    # Check ingress
    print_info "Checking ingress..."
    INGRESSES=$($KUBECTL get ingress -n "$NAMESPACE" --no-headers 2>/dev/null | wc -l)
    if [[ $INGRESSES -gt 0 ]]; then
        print_success "$INGRESSES ingress(es) found"
        echo ""
        $KUBECTL get ingress -n "$NAMESPACE"

        # Extract hosts
        echo ""
        print_info "Ingress hosts configured:"
        $KUBECTL get ingress -n "$NAMESPACE" -o jsonpath='{range .items[*]}{.spec.rules[*].host}{"\n"}{end}' | while read -r host; do
            if [[ -n "$host" ]]; then
                echo "  - http://$host"
            fi
        done
    else
        print_info "No ingress resources found"
    fi
}

check_docker() {
    print_header "Checking Docker"

    if command -v docker &> /dev/null; then
        VERSION=$(docker --version)
        print_success "Docker is installed: $VERSION"

        # Check if user can run docker
        if docker ps &> /dev/null; then
            print_success "Docker is accessible (user in docker group)"
        else
            print_warning "Cannot access Docker (may need to logout/login or run: newgrp docker)"
        fi
    else
        print_warning "Docker not found"
    fi
}

check_registry() {
    print_header "Checking Container Registry"

    # Check MicroK8s registry
    if command -v microk8s &> /dev/null && microk8s status | grep -q "registry.*enabled"; then
        print_success "MicroK8s registry is enabled"

        # Try to query registry
        if curl -s http://localhost:32000/v2/_catalog &> /dev/null; then
            print_success "MicroK8s registry is accessible"

            # List images
            IMAGES=$(curl -s http://localhost:32000/v2/_catalog | jq -r '.repositories[]' 2>/dev/null || echo "")
            if [[ -n "$IMAGES" ]]; then
                print_info "Images in registry:"
                echo "$IMAGES" | while read -r img; do
                    echo "  - $img"
                done
            else
                print_info "No images in registry yet"
            fi
        else
            print_warning "MicroK8s registry not accessible at localhost:32000"
        fi
    else
        print_info "MicroK8s registry not enabled or not using MicroK8s"
    fi
}

check_connectivity() {
    print_header "Checking Network Connectivity"

    # Check if can reach ingress hosts
    if [[ "$SKIP_APPS" = false ]] && $KUBECTL get namespace "$NAMESPACE" &> /dev/null; then
        HOSTS=$($KUBECTL get ingress -n "$NAMESPACE" -o jsonpath='{range .items[*]}{.spec.rules[*].host}{"\n"}{end}' 2>/dev/null || echo "")

        if [[ -n "$HOSTS" ]]; then
            print_info "Testing ingress host resolution..."
            echo "$HOSTS" | while read -r host; do
                if [[ -n "$host" ]]; then
                    if host "$host" &> /dev/null || grep -q "$host" /etc/hosts; then
                        print_success "Host '$host' resolves"
                    else
                        print_warning "Host '$host' does not resolve (add to /etc/hosts)"
                    fi
                fi
            done
        fi
    fi
}

display_summary() {
    print_header "Verification Summary"

    TOTAL=$((CHECKS_PASSED + CHECKS_FAILED + CHECKS_WARNING))

    echo -e "${GREEN}Passed:  $CHECKS_PASSED${NC}"
    echo -e "${YELLOW}Warnings: $CHECKS_WARNING${NC}"
    echo -e "${RED}Failed:  $CHECKS_FAILED${NC}"
    echo -e "Total:   $TOTAL"
    echo ""

    if [[ $CHECKS_FAILED -eq 0 ]]; then
        print_success "All critical checks passed! ✓"

        if [[ $CHECKS_WARNING -gt 0 ]]; then
            print_info "There are some warnings, but the system should be functional"
        fi

        echo ""
        print_header "Next Steps"

        if [[ "$SKIP_APPS" = false ]] && ! $KUBECTL get namespace "$NAMESPACE" &> /dev/null; then
            echo "1. Deploy EASM applications:"
            echo "   kubectl apply -k k8s/argocd/"
            echo ""
            echo "2. Monitor deployment:"
            echo "   argocd app list"
            echo "   watch kubectl get pods -n $NAMESPACE"
            echo ""
        fi

        echo "Access your services:"
        if $KUBECTL get namespace argocd &> /dev/null 2>&1; then
            echo "  ArgoCD UI: http://argocd.local"
        fi
        if $KUBECTL get namespace "$NAMESPACE" &> /dev/null 2>&1; then
            echo "  EASM API: http://easm-api.local"
            echo "  EASM Frontend: http://easm-frontend.local"
        fi

        return 0
    else
        print_error "Some critical checks failed"
        echo ""
        echo "Review the errors above and:"
        echo "1. Check system logs: journalctl -xe"
        echo "2. Check Kubernetes logs: $KUBECTL logs -n kube-system <pod-name>"
        echo "3. Check MicroK8s status: microk8s inspect"
        echo ""
        return 1
    fi
}

# Main execution
main() {
    print_header "EASM Platform - Deployment Verification"

    print_info "Checking deployment in namespace: $NAMESPACE"
    echo ""

    # Run all checks
    check_microk8s
    check_cluster
    check_namespaces
    check_system_pods
    check_argocd
    check_applications
    check_docker
    check_registry
    check_connectivity

    # Display summary
    display_summary
}

# Run main function
main "$@"
