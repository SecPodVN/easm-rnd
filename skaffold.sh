#!/usr/bin/env bash
# Quick start script for deploying EASM with Skaffold
# Compatible with Linux, macOS, and WSL

set -e

# Cleanup function for temporary files
cleanup_temp_files() {
    echo ""
    echo "[*] Cleaning up temporary files..."
    rm -f "skaffold.temp.yaml"
    rm -f "skaffold-values.yaml"
}

# Register cleanup on script exit (including Ctrl+C)
trap cleanup_temp_files EXIT INT TERM

echo "=== EASM Skaffold Deployment Script ==="
echo ""

# Load environment variables from .env file
if [ -f ".env" ]; then
    ENV_FILE=".env"
else
    ENV_FILE=""
fi

if [ -n "$ENV_FILE" ]; then
    echo "[*] Loading environment variables from $ENV_FILE..."
    set -a
    source "$ENV_FILE"
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

# Get port configuration from environment or use defaults
API_PORT="${API_LOCAL_PORT:-8000}"
POSTGRES_PORT="${POSTGRES_LOCAL_PORT:-5432}"
REDIS_PORT="${REDIS_LOCAL_PORT:-6379}"

# Show port configuration
echo "Port Forwarding Configuration:"
echo "   API:        localhost:$API_PORT -> container:8000"
echo "   PostgreSQL: localhost:$POSTGRES_PORT -> container:5432"
echo "   Redis:      localhost:$REDIS_PORT -> container:6379"
echo ""

# Generate temporary values file for ALLOWED_HOSTS (handles commas properly)
echo "[*] Generating values file for comma-separated configs..."
ALLOWED_HOSTS_VALUE="${ALLOWED_HOSTS:-localhost,127.0.0.1}"
cat > skaffold-values.yaml <<EOF
# Auto-generated from .env
# This file handles values with commas that can't be passed via --set
django:
  allowedHosts: "$ALLOWED_HOSTS_VALUE"
EOF

# Generate temporary skaffold.yaml with custom ports
# (Skaffold doesn't support CLI port override or template variables in localPort)
echo "[*] Generating temporary skaffold config with custom ports..."
TEMP_SKAFFOLD_FILE="skaffold.temp.yaml"
sed -e "s/^\(\s*localPort:\s*\)8000\(.*\)$/\1$API_PORT\2/" \
    -e "s/^\(\s*localPort:\s*\)5432\(.*\)$/\1$POSTGRES_PORT\2/" \
    -e "s/^\(\s*localPort:\s*\)6379\(.*\)$/\1$REDIS_PORT\2/" \
    skaffold.yaml > "$TEMP_SKAFFOLD_FILE"
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
        skaffold dev -f "$TEMP_SKAFFOLD_FILE"
        ;;
    2)
        echo ""
        echo "[>>] Deploying with Skaffold..."
        skaffold run -f "$TEMP_SKAFFOLD_FILE"
        echo ""
        echo "[OK] Deployment complete!"
        echo ""
        echo "Access the application:"
        echo "  API: http://localhost:$API_PORT"
        echo ""
        echo "To view logs: kubectl logs -f deployment/easm-api"
        echo "To delete: skaffold delete"
        ;;
    3)
        echo ""
        echo "[>>] Starting Skaffold with dev profile..."
        echo "[*] Press Ctrl+C to stop"
        echo ""
        skaffold dev --profile=dev -f "$TEMP_SKAFFOLD_FILE"
        ;;
    4)
        echo ""
        echo "[>>] Deploying with production profile..."
        skaffold run --profile=prod -f "$TEMP_SKAFFOLD_FILE"
        echo ""
        echo "[OK] Deployment complete!"
        echo ""
        echo "Access the application:"
        echo "  kubectl port-forward service/easm-api $API_PORT:8000"
        echo ""
        echo "To view logs: kubectl logs -f deployment/easm-api"
        echo "To delete: skaffold delete"
        ;;
    *)
        echo "[ERROR] Invalid choice"
        exit 1
        ;;
esac
