#!/usr/bin/env bash
# Quick start script for deploying EASM with Skaffold
# Compatible with Linux, macOS, and WSL
# Supports auto-reload when .env file changes

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

# Function to load environment variables from .env file
load_env_file() {
    if [ -f ".env" ]; then
        echo "[*] Loading environment variables from .env..."
        while IFS='=' read -r key value; do
            # Skip comments and empty lines
            if [[ ! "$key" =~ ^[[:space:]]*# && -n "$key" ]]; then
                key=$(echo "$key" | xargs)
                value=$(echo "$value" | xargs)
                export "$key=$value"
                echo "  [+] Set $key"
            fi
        done < .env
        echo ""
    else
        echo "[ERROR] Failed to load environment variables from .env file"
    fi
}

load_env_file

# Check if Kubernetes is running
if kubectl cluster-info &> /dev/null; then
    echo "[OK] Kubernetes cluster is running"
else
    echo "[WARNING] Kubernetes cluster is not running!"
    echo ""

    # Check if minikube is available
    if command -v minikube &> /dev/null; then
        echo "[*] Attempting to start Minikube with Docker driver..."
        echo "[*] This may take a few minutes..."

        # Start minikube and wait for it to be ready
        if minikube start --driver=docker; then
            # Wait for kubectl to be able to connect
            echo "[*] Waiting for Kubernetes to be ready..."
            max_retries=30
            retry_count=0
            kubectl_ready=false

            while [ $kubectl_ready = false ] && [ $retry_count -lt $max_retries ]; do
                if kubectl cluster-info &> /dev/null; then
                    kubectl_ready=true
                    echo ""
                    echo "[OK] Minikube started successfully"
                else
                    retry_count=$((retry_count + 1))
                    sleep 2
                    echo -n "."
                fi
            done

            if [ $kubectl_ready = false ]; then
                echo ""
                echo "[ERROR] Kubernetes cluster did not become ready in time"
                echo ""
                echo "Please check the status manually:"
                echo "  - Check Minikube: minikube status"
                echo "  - Check kubectl: kubectl cluster-info"
                exit 1
            fi
        else
            echo ""
            echo "[ERROR] Failed to start Minikube"
            echo ""
            echo "Please start your cluster manually:"
            echo "  - Minikube: minikube start --driver=docker"
            echo "  - Docker Desktop: Enable Kubernetes in settings"
            echo "  - Kind: kind create cluster"
            exit 1
        fi
    else
        echo "[ERROR] Minikube not found!"
        echo "Please install Minikube or start your cluster manually:"
        echo "  - Install Minikube: https://minikube.sigs.k8s.io/docs/start/"
        echo "  - Docker Desktop: Enable Kubernetes in settings"
        echo "  - Kind: kind create cluster"
        exit 1
    fi
fi

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
MONGODB_PORT="${MONGODB_LOCAL_PORT:-27017}"

# Show port configuration
echo "Port Forwarding Configuration:"
echo "   API:        localhost:$API_PORT -> container:8000"
echo "   PostgreSQL: localhost:$POSTGRES_PORT -> container:5432"
echo "   Redis:      localhost:$REDIS_PORT -> container:6379"
echo "   MongoDB:    localhost:$MONGODB_PORT -> container:27017"
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
echo "  5) DEBUG mode (skaffold dev --cleanup=false --status-check=false)"
echo "  6) Auto-watch mode (.env changes trigger redeploy)"
echo ""
read -p "Enter your choice (1-6): " choice

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
    5)
        echo ""
        echo "[>>] Starting Skaffold in DEBUG mode..."
        echo "[*] Cleanup on exit will be DISABLED"
        echo "[*] Press Ctrl+C to stop (resources will remain)"
        echo ""
        skaffold dev --cleanup=false --status-check=false
        echo ""
        echo "[DEBUG] Resources are still running. To debug:"
        echo "  View logs: kubectl logs -f deployment/easm-api"
        echo "  Shell into pod: kubectl exec -it deployment/easm-api -- /bin/bash"
        echo "  Check packages: kubectl exec -it deployment/easm-api -- pip list"
        echo "  Delete when done: skaffold delete"
        ;;
    6)
        echo ""
        echo "[>>] Starting Auto-Watch Mode..."
        echo "[*] Watching .env file for changes..."
        echo "[*] Services will start/stop based on .env flags"
        echo "[*] Then Skaffold dev will manage the deployment"
        echo "[*] Press Ctrl+C to stop"
        echo ""

        # Helper functions for service management
        test_helm_release() {
            local release_name=$1
            local namespace=$2
            helm list -n "$namespace" -o json 2>&1 | grep -q "\"name\":\"$release_name\""
        }

        deploy_postgresql() {
            local namespace=$1
            echo "[+] Starting PostgreSQL..."
            helm upgrade --install postgresql bitnami/postgresql \
                --version 18.1.1 \
                --namespace "$namespace" \
                --create-namespace \
                --set auth.database=easm_db \
                --set auth.username=easm_user \
                --set auth.password=easm_password \
                --set primary.persistence.enabled=false \
                --set image.pullPolicy=IfNotPresent \
                --wait=false &> /dev/null
        }

        deploy_redis() {
            local namespace=$1
            echo "[+] Starting Redis..."
            helm upgrade --install redis bitnami/redis \
                --version 23.2.1 \
                --namespace "$namespace" \
                --create-namespace \
                --set auth.enabled=false \
                --set architecture=standalone \
                --set master.persistence.enabled=false \
                --set image.pullPolicy=IfNotPresent \
                --wait=false &> /dev/null
        }

        deploy_mongodb() {
            local namespace=$1
            echo "[+] Starting MongoDB..."
            helm upgrade --install mongodb bitnami/mongodb \
                --version 16.3.1 \
                --namespace "$namespace" \
                --create-namespace \
                --set auth.rootPassword=easm_password \
                --set auth.username=easm_user \
                --set auth.password=easm_password \
                --set auth.database=easm_db \
                --set persistence.enabled=false \
                --set image.tag=latest \
                --set image.pullPolicy=IfNotPresent \
                --wait=false &> /dev/null
        }

        remove_service() {
            local service_name=$1
            local namespace=$2
            echo "[-] Stopping $service_name..."
            helm uninstall "$service_name" -n "$namespace" &> /dev/null
        }

        reconcile_services() {
            local namespace=$K8S_NAMESPACE
            local changes=()

            # PostgreSQL
            local postgres_enabled=true
            [ "$POSTGRESQL_ENABLED" = "False" ] && postgres_enabled=false

            local postgres_running=false
            if test_helm_release "postgresql" "$namespace"; then
                local pod_count=$(kubectl get pods -n "$namespace" -l app.kubernetes.io/name=postgresql -o json 2>&1 | grep -c "\"phase\":\"Running\"" || echo "0")
                [ "$pod_count" -gt 0 ] && postgres_running=true
            fi

            if [ "$postgres_enabled" = true ] && [ "$postgres_running" = false ]; then
                deploy_postgresql "$namespace"
                changes+=("PostgreSQL STARTED")
            elif [ "$postgres_enabled" = false ] && [ "$postgres_running" = true ]; then
                remove_service "postgresql" "$namespace"
                changes+=("PostgreSQL STOPPED")
            fi

            # Redis
            local redis_enabled=true
            [ "$REDIS_ENABLED" = "False" ] && redis_enabled=false

            local redis_running=false
            if test_helm_release "redis" "$namespace"; then
                local pod_count=$(kubectl get pods -n "$namespace" -l app.kubernetes.io/name=redis -o json 2>&1 | grep -c "\"phase\":\"Running\"" || echo "0")
                [ "$pod_count" -gt 0 ] && redis_running=true
            fi

            if [ "$redis_enabled" = true ] && [ "$redis_running" = false ]; then
                deploy_redis "$namespace"
                changes+=("Redis STARTED")
            elif [ "$redis_enabled" = false ] && [ "$redis_running" = true ]; then
                remove_service "redis" "$namespace"
                changes+=("Redis STOPPED")
            fi

            # MongoDB
            local mongo_enabled=true
            [ "$MONGODB_ENABLED" = "False" ] && mongo_enabled=false

            local mongo_running=false
            if test_helm_release "mongodb" "$namespace"; then
                local pod_count=$(kubectl get pods -n "$namespace" -l app.kubernetes.io/name=mongodb -o json 2>&1 | grep -c "\"phase\":\"Running\"" || echo "0")
                [ "$pod_count" -gt 0 ] && mongo_running=true
            fi

            if [ "$mongo_enabled" = true ] && [ "$mongo_running" = false ]; then
                deploy_mongodb "$namespace"
                changes+=("MongoDB STARTED")
            elif [ "$mongo_enabled" = false ] && [ "$mongo_running" = true ]; then
                remove_service "mongodb" "$namespace"
                changes+=("MongoDB STOPPED")
            fi

            # Return changes
            if [ ${#changes[@]} -gt 0 ]; then
                echo "[OK] Changes applied:"
                for change in "${changes[@]}"; do
                    echo "  $change"
                done
            else
                echo "[OK] All services already in desired state"
            fi
        }

        wait_for_infrastructure() {
            # Only wait if API is enabled
            if [ "$EASM_API_ENABLED" = "False" ]; then
                return 0
            fi

            echo "[*] Waiting for infrastructure services..."
            sleep 10
            echo "[OK] Ready"
        }

        # Initial reconciliation
        echo "[*] Initial service reconciliation..."
        load_env_file
        echo "[DEBUG] POSTGRESQL_ENABLED=$POSTGRESQL_ENABLED, REDIS_ENABLED=$REDIS_ENABLED, MONGODB_ENABLED=$MONGODB_ENABLED, EASM_API_ENABLED=$EASM_API_ENABLED"

        reconcile_services
        echo ""

        # Wait for enabled infrastructure services to be ready before starting API
        wait_for_infrastructure

        # Store the initial hash of .env file
        env_hash=$(md5sum .env 2>/dev/null | awk '{print $1}' || md5 .env 2>/dev/null | awk '{print $1}')
        skaffold_pid=""

        # Cleanup function for auto-watch mode
        cleanup_autowatch() {
            echo ""
            echo "[*] Cleaning up..."

            # Stop Skaffold process
            if [ -n "$skaffold_pid" ] && kill -0 "$skaffold_pid" 2>/dev/null; then
                kill "$skaffold_pid" 2>/dev/null || true
                wait "$skaffold_pid" 2>/dev/null || true
            fi
            pkill -f "skaffold dev" 2>/dev/null || true

            # Delete all running Kubernetes resources
            echo "[*] Removing all running services..."
            kubectl delete all --all -n "$K8S_NAMESPACE" &> /dev/null || true

            echo "[OK] Cleanup complete!"
            cleanup_temp_files
            exit 0
        }

        trap cleanup_autowatch EXIT INT TERM

        while true; do
            # Check if API should be running
            api_enabled=true
            [ "$EASM_API_ENABLED" = "False" ] && api_enabled=false

            # Start skaffold if not running AND API is enabled
            if [ "$api_enabled" = true ] && { [ -z "$skaffold_pid" ] || ! kill -0 "$skaffold_pid" 2>/dev/null; }; then
                echo "[>>] Starting Skaffold dev (EASM API)..."

                # Use API-only config since PostgreSQL/Redis/MongoDB are managed separately
                skaffold dev -f skaffold-api-only.yaml &> /tmp/skaffold-output.log &
                skaffold_pid=$!

                echo "[*] Skaffold started (PID: $skaffold_pid)"
                sleep 3
            elif [ "$api_enabled" = false ] && [ -n "$skaffold_pid" ] && kill -0 "$skaffold_pid" 2>/dev/null; then
                # Stop Skaffold if API is disabled
                echo "[*] API disabled, stopping Skaffold..."
                kill "$skaffold_pid" 2>/dev/null || true
                wait "$skaffold_pid" 2>/dev/null || true
                skaffold_pid=""
            fi

            # Show status if API is disabled
            if [ "$api_enabled" = false ]; then
                echo -ne "\r[*] API disabled - watching for .env changes..."
            fi

            # Check for .env file changes every 2 seconds
            sleep 2

            if [ -f .env ]; then
                current_hash=$(md5sum .env 2>/dev/null | awk '{print $1}' || md5 .env 2>/dev/null | awk '{print $1}')

                if [ "$current_hash" != "$env_hash" ]; then
                    echo ""
                    echo "[!] .env file changed!"

                    # Stop skaffold
                    if [ -n "$skaffold_pid" ] && kill -0 "$skaffold_pid" 2>/dev/null; then
                        kill "$skaffold_pid" 2>/dev/null || true
                        wait "$skaffold_pid" 2>/dev/null || true
                    fi
                    pkill -f "skaffold dev" 2>/dev/null || true

                    # Update hash and reload env
                    env_hash=$current_hash
                    load_env_file

                    # Reconcile services based on new flags
                    echo "[*] Reconciling services..."
                    reconcile_services

                    # Wait for infrastructure to be ready before restarting API
                    wait_for_infrastructure

                    echo "[*] Restarting Skaffold dev..."
                    echo ""
                    sleep 2
                    skaffold_pid=""
                fi
            fi

            # Show job output
            if [ -n "$skaffold_pid" ] && kill -0 "$skaffold_pid" 2>/dev/null; then
                if [ -f /tmp/skaffold-output.log ]; then
                    tail -n 10 /tmp/skaffold-output.log 2>/dev/null || true
                    > /tmp/skaffold-output.log  # Clear the log after displaying
                fi
            fi
        done
        ;;
    *)
        echo "[ERROR] Invalid choice"
        exit 1
        ;;
esac
