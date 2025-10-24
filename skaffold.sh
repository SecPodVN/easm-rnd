#!/usr/bin/env bash
# Quick start script for deploying EASM with Skaffold
# Compatible with Linux, macOS, and WSL

set -e

echo "=== EASM Skaffold Deployment Script ==="
echo ""

# Load environment variables from .env file
if [ -f .env ]; then
    echo "[*] Loading environment variables from .env file..."
    set -a
    source .env
    set +a
    echo "  [+] Environment variables loaded"
    echo ""
else
    echo "[!] Warning: .env file not found!"
    echo "    Copy .env.example to .env and configure your environment"
    echo ""
fi

# Check if Kubernetes is running
if ! kubectl cluster-info &> /dev/null; then
    echo "[ERROR] Kubernetes cluster is not running!"
    echo "Please start your cluster first:"
    echo "  - Minikube: minikube start"
    echo "  - Docker Desktop: Enable Kubernetes in settings"
    echo "  - Kind: kind create cluster"
    exit 1
fi

echo "[OK] Kubernetes cluster is running"
echo ""

# Add Bitnami repo if not already added
if ! helm repo list | grep -q bitnami; then
    echo "[*] Adding Bitnami Helm repository..."
    helm repo add bitnami https://charts.bitnami.com/bitnami
fi

echo "[*] Updating Helm repositories..."
helm repo update

echo ""
echo "Choose deployment mode:"
echo "  1) Development (skaffold dev - with hot reload)"
echo "  2) One-time deployment (skaffold run)"
echo "  3) Development profile (no persistence)"
echo "  4) Production profile (with persistence and scaling)"
echo ""
read -p "Enter your choice (1-4): " choice

case $choice in
    1)
        echo ""
        echo "[>>] Starting Skaffold in development mode..."
        echo "[*] Press Ctrl+C to stop"
        echo ""
        skaffold dev
        ;;
    2)
        echo ""
        echo "[>>] Deploying with Skaffold..."
        skaffold run
        echo ""
        echo "[OK] Deployment complete!"
        echo ""
        echo "Access the application:"
        echo "  API: http://localhost:8000"
        echo ""
        echo "To view logs: kubectl logs -f deployment/easm-api"
        echo "To delete: skaffold delete"
        ;;
    3)
        echo ""
        echo "[>>] Starting Skaffold with dev profile..."
        echo "[*] Press Ctrl+C to stop"
        echo ""
        skaffold dev --profile=dev
        ;;
    4)
        echo ""
        echo "[>>] Deploying with production profile..."
        skaffold run --profile=prod
        echo ""
        echo "[OK] Deployment complete!"
        echo ""
        echo "Access the application:"
        echo "  kubectl port-forward service/easm-api 8000:8000"
        echo ""
        echo "To view logs: kubectl logs -f deployment/easm-api"
        echo "To delete: skaffold delete"
        ;;
    *)
        echo "[ERROR] Invalid choice"
        exit 1
        ;;
esac
