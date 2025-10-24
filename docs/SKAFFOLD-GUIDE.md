# Skaffold Deployment Guide

This guide explains how to deploy the EASM application using Skaffold with Kubernetes.

## Architecture

The Skaffold configuration deploys three components:

1. **PostgreSQL** - From Bitnami Helm chart (external dependency)
2. **Redis** - From Bitnami Helm chart (external dependency)
3. **EASM API** - From local Helm chart at `./src/charts/easm-api`

## Prerequisites

1. **Kubernetes cluster** (one of):
   - Minikube: `minikube start`
   - Docker Desktop with Kubernetes enabled
   - Kind: `kind create cluster`
   - Cloud provider (GKE, EKS, AKS)

2. **Required tools**:
   ```powershell
   # Install Skaffold
   choco install skaffold
   
   # Install Helm (if not already installed)
   choco install kubernetes-helm
   
   # Install kubectl (if not already installed)
   choco install kubernetes-cli
   ```

3. **Add Bitnami Helm repository**:
   ```powershell
   helm repo add bitnami https://charts.bitnami.com/bitnami
   helm repo update
   ```

## Quick Start

### 1. Start Minikube (if using Minikube)
```powershell
minikube start
```

### 2. Deploy with Skaffold

**Development mode** (with hot reload):
```powershell
skaffold dev
```

**One-time deployment**:
```powershell
skaffold run
```

**Using a specific profile**:
```powershell
# Development profile (no persistence)
skaffold dev --profile=dev

# Production profile (with persistence and scaling)
skaffold run --profile=prod
```

### 3. Access the application

Skaffold will automatically set up port forwarding:
- **API**: http://localhost:8000
- **PostgreSQL**: localhost:5432
- **Redis**: localhost:6379

Or manually:
```powershell
kubectl port-forward service/easm-api 8000:8000
kubectl port-forward service/postgresql 5432:5432
kubectl port-forward service/redis-master 6379:6379
```

### 4. Verify deployment

```powershell
# Check all pods are running
kubectl get pods

# Check services
kubectl get services

# Check Helm releases
helm list

# View API logs
kubectl logs -f deployment/easm-api

# View PostgreSQL logs
kubectl logs -f statefulset/postgresql

# View Redis logs
kubectl logs -f statefulset/redis-master
```

## Profiles

### Default Profile
- PostgreSQL with 1Gi persistence
- Redis with 500Mi persistence
- API with 1 replica
- Debug mode enabled

### Dev Profile (`--profile=dev`)
- PostgreSQL without persistence (faster startup)
- Redis without persistence
- API with 1 replica
- Debug mode enabled
- Hot reload enabled with `skaffold dev`

### Prod Profile (`--profile=prod`)
- PostgreSQL with 10Gi persistence
- Redis with 2Gi persistence and authentication
- API with 3 replicas
- Autoscaling enabled (1-5 replicas)
- Debug mode disabled
- Resource limits configured

## Configuration

### Database Credentials (Default)
- **Database**: `easm_db`
- **Username**: `easm_user`
- **Password**: `easm_password`
- **Host**: `postgresql` (internal) or `localhost:5432` (port-forward)

### Redis Configuration (Default)
- **Host**: `redis-master` (internal) or `localhost:6379` (port-forward)
- **Port**: `6379`
- **Auth**: Disabled (dev), Enabled (prod)

### Customizing Values

You can override Helm values in `skaffold.yaml` under `deploy.helm.releases[].setValues`:

```yaml
- name: easm-api
  chartPath: src/charts/easm-api
  setValues:
    postgresql.database: my_custom_db
    postgresql.username: my_user
    postgresql.password: my_secure_password
    django.debug: "False"
    replicaCount: 2
```

Or create a custom values file:
```powershell
# Create custom values
cat > my-values.yaml <<EOF
postgresql:
  database: my_db
django:
  debug: "False"
replicaCount: 3
EOF

# Deploy with custom values
skaffold run -f skaffold.yaml --set-value-file=my-values.yaml
```

## Troubleshooting

### Pods not starting
```powershell
# Check pod status
kubectl get pods

# Describe pod to see events
kubectl describe pod <pod-name>

# View pod logs
kubectl logs <pod-name>

# View previous container logs (if crashed)
kubectl logs <pod-name> --previous
```

### Database connection errors
```powershell
# Check PostgreSQL is running
kubectl get pods -l app.kubernetes.io/name=postgresql

# Test database connection
kubectl run -it --rm debug --image=postgres:15-alpine --restart=Never -- \
  psql -h postgresql -U easm_user -d easm_db

# Check service endpoints
kubectl get endpoints postgresql
```

### Redis connection errors
```powershell
# Check Redis is running
kubectl get pods -l app.kubernetes.io/name=redis

# Test Redis connection
kubectl run -it --rm debug --image=redis:7-alpine --restart=Never -- \
  redis-cli -h redis-master ping

# Check service endpoints
kubectl get endpoints redis-master
```

### Image not found
```powershell
# Build and load image to Minikube
eval $(minikube docker-env)
docker build -t easm-api:latest ./src/backend

# Or use Skaffold to build
skaffold build
```

### Helm release conflicts
```powershell
# List all releases
helm list --all-namespaces

# Delete a release
helm uninstall <release-name>

# Clean up Skaffold deployments
skaffold delete
```

## Database Migrations

Run migrations on first deployment or after model changes:

```powershell
# Create migrations (if needed)
kubectl exec -it deployment/easm-api -- python manage.py makemigrations

# Apply migrations
kubectl exec -it deployment/easm-api -- python manage.py migrate

# Create superuser
kubectl exec -it deployment/easm-api -- python manage.py createsuperuser
```

Or add an init container to the deployment that runs migrations automatically.

## Cleanup

### Remove Skaffold deployment
```powershell
skaffold delete
```

### Remove specific Helm releases
```powershell
helm uninstall easm-api
helm uninstall postgresql
helm uninstall redis
```

### Remove persistent volumes
```powershell
kubectl delete pvc --all
kubectl delete pv --all
```

### Stop Minikube
```powershell
minikube stop
```

## Environment Variables

The API pod receives environment variables from:

1. **ConfigMap** (`easm-api`):
   - `POSTGRES_HOST`, `POSTGRES_PORT`, `POSTGRES_DB`, `POSTGRES_USER`
   - `REDIS_HOST`, `REDIS_PORT`, `REDIS_DB`
   - `DEBUG`, `ALLOWED_HOSTS`
   - `JWT_ACCESS_TOKEN_LIFETIME`, `JWT_REFRESH_TOKEN_LIFETIME`

2. **Secret** (`easm-api`):
   - `SECRET_KEY`
   - `POSTGRES_PASSWORD`

3. **Additional env vars** (in `values.yaml`):
   ```yaml
   env:
     - name: CUSTOM_VAR
       value: "custom-value"
   ```

## Continuous Development

For continuous development with auto-reload:

```powershell
# Start development mode
skaffold dev --port-forward

# Skaffold will:
# 1. Build the image when Dockerfile or source changes
# 2. Deploy to Kubernetes
# 3. Stream logs from all pods
# 4. Set up port forwarding
# 5. Rebuild and redeploy on file changes
```

## Monitoring

### View logs from all pods
```powershell
skaffold dev  # Streams logs automatically

# Or manually
kubectl logs -f deployment/easm-api
kubectl logs -f statefulset/postgresql
kubectl logs -f statefulset/redis-master
```

### Access pod shell
```powershell
# API pod
kubectl exec -it deployment/easm-api -- /bin/bash

# PostgreSQL pod
kubectl exec -it statefulset/postgresql -- /bin/bash

# Redis pod
kubectl exec -it statefulset/redis-master -- /bin/bash
```

## Production Considerations

1. **Use secrets management**: Replace plaintext passwords with Kubernetes Secrets or external secret managers (Vault, AWS Secrets Manager, etc.)

2. **Enable persistence**: Always enable persistence in production with appropriate storage class and size

3. **Configure resource limits**: Set appropriate CPU/memory limits based on your workload

4. **Enable autoscaling**: Configure HPA for the API deployment

5. **Set up ingress**: Configure ingress for external access instead of port forwarding

6. **Enable monitoring**: Add Prometheus metrics and Grafana dashboards

7. **Configure backups**: Set up regular database backups

8. **Use namespaces**: Deploy to a dedicated namespace instead of `default`

## Comparison with Docker Compose

| Feature | Docker Compose | Skaffold + Kubernetes |
|---------|----------------|----------------------|
| **Orchestration** | Single host | Multi-node cluster |
| **Scaling** | Manual | Automatic (HPA) |
| **High Availability** | No | Yes (multiple replicas) |
| **Service Discovery** | DNS | Kubernetes Services |
| **Persistence** | Named volumes | PersistentVolumes |
| **Configuration** | .env files | ConfigMaps/Secrets |
| **Networking** | Bridge network | CNI plugins |
| **Load Balancing** | Round-robin | Service/Ingress |
| **Development** | Fast startup | Slower, but production-like |

## Next Steps

1. Customize Helm chart values in `src/charts/easm-api/values.yaml`
2. Add health checks and readiness probes
3. Configure ingress for external access
4. Set up CI/CD pipeline with Skaffold
5. Add monitoring and logging (Prometheus, Grafana, ELK)
6. Configure backup and disaster recovery
7. Implement GitOps with ArgoCD or Flux

## Useful Commands

```powershell
# Skaffold
skaffold dev                    # Development mode with hot reload
skaffold run                    # One-time deployment
skaffold delete                 # Remove deployment
skaffold build                  # Build images only
skaffold deploy                 # Deploy only (no build)
skaffold diagnose               # Check configuration

# Kubectl
kubectl get all                 # List all resources
kubectl get pods -w             # Watch pods
kubectl describe pod <name>     # Pod details
kubectl logs -f <pod>           # Stream logs
kubectl exec -it <pod> -- bash  # Shell access
kubectl port-forward <pod> 8000:8000  # Port forward

# Helm
helm list                       # List releases
helm status <release>           # Release status
helm get values <release>       # Show values
helm upgrade <release> <chart>  # Upgrade release
helm rollback <release>         # Rollback release
helm uninstall <release>        # Remove release

# Minikube
minikube start                  # Start cluster
minikube stop                   # Stop cluster
minikube dashboard              # Open dashboard
minikube service list           # List services
minikube tunnel                 # Create tunnel for LoadBalancer
```
