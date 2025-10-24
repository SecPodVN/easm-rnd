# Skaffold vs Docker Compose Comparison

## Overview

This document compares the Docker Compose and Skaffold configurations for the EASM application.

## Service Mapping

| Component | Docker Compose | Skaffold |
|-----------|----------------|----------|
| **PostgreSQL** | `postgres:18-alpine` image | Bitnami Helm chart `postgresql` v15.5.32 |
| **Redis** | `redis:8-alpine` image | Bitnami Helm chart `redis` v20.2.1 |
| **API** | Built from `./src/backend` | Built from `./src/backend` + local Helm chart |

## Service Names

| Component | Docker Compose | Skaffold/Kubernetes |
|-----------|----------------|---------------------|
| **PostgreSQL Host** | `postgres` | `postgresql` |
| **Redis Host** | `redis` | `redis-master` |
| **API Service** | `api` | `easm-api` |

## Port Mappings

### Docker Compose
```yaml
postgres:
  ports:
    - "5432:5432"  # Host:Container

redis:
  ports:
    - "6379:6379"

api:
  ports:
    - "8000:8000"
```

### Skaffold (Port Forward)
```yaml
portForward:
  - resourceName: postgresql
    port: 5432
    localPort: 5432

  - resourceName: redis-master
    port: 6379
    localPort: 6379

  - resourceName: easm-api
    port: 8000
    localPort: 8000
```

## Environment Variables

### Docker Compose (.env file)
```properties
DEBUG=True
SECRET_KEY=django-insecure-development-key-change-in-production
POSTGRES_DB=easm_db
POSTGRES_USER=easm_user
POSTGRES_PASSWORD=easm_password
POSTGRES_HOST=postgres
POSTGRES_PORT=5432
REDIS_HOST=redis
REDIS_PORT=6379
```

### Skaffold (ConfigMap + Secret)

**ConfigMap:**
```yaml
POSTGRES_HOST: postgresql
POSTGRES_PORT: "5432"
POSTGRES_DB: easm_db
POSTGRES_USER: easm_user
REDIS_HOST: redis-master
REDIS_PORT: "6379"
DEBUG: "True"
ALLOWED_HOSTS: "*"
```

**Secret:**
```yaml
SECRET_KEY: django-insecure-development-key-change-in-production
POSTGRES_PASSWORD: easm_password
```

## Volume Persistence

### Docker Compose
```yaml
volumes:
  postgres_data:      # Named volume
  redis_data:         # Named volume
  static_volume:      # Named volume
```

### Skaffold (PersistentVolumeClaims)
```yaml
# PostgreSQL
primary.persistence.enabled: true
primary.persistence.size: 1Gi

# Redis
master.persistence.enabled: true
master.persistence.size: 500Mi
```

## Health Checks

### Docker Compose
```yaml
postgres:
  healthcheck:
    test: ["CMD-SHELL", "pg_isready -U easm_user -d easm_db"]
    interval: 10s
    timeout: 5s
    retries: 5

redis:
  healthcheck:
    test: ["CMD", "redis-cli", "ping"]
    interval: 10s
    timeout: 5s
    retries: 5
```

### Skaffold (Kubernetes Probes)
```yaml
# Built into Bitnami charts
# PostgreSQL: Uses pg_isready
# Redis: Uses redis-cli ping

# API deployment
livenessProbe:
  httpGet:
    path: /api/docs/
    port: http
  initialDelaySeconds: 30
  periodSeconds: 10

readinessProbe:
  httpGet:
    path: /api/docs/
    port: http
  initialDelaySeconds: 20
  periodSeconds: 10
```

## Startup Commands

### Docker Compose
```yaml
api:
  command: sh /app/start-api.sh
```

### Skaffold
```yaml
# Uses default CMD from Dockerfile
# Or can override in Helm chart values:
command: ["sh", "/app/start-api.sh"]
```

## Scaling

### Docker Compose
```bash
# Manual scaling
docker compose up --scale api=3
```

### Skaffold
```yaml
# Manual scaling
kubectl scale deployment/easm-api --replicas=3

# Auto-scaling (HPA)
autoscaling:
  enabled: true
  minReplicas: 1
  maxReplicas: 5
  targetCPUUtilizationPercentage: 80
```

## Resource Limits

### Docker Compose
```yaml
# Not configured by default
# Can add:
api:
  deploy:
    resources:
      limits:
        cpus: '0.5'
        memory: 512M
```

### Skaffold
```yaml
resources:
  limits:
    cpu: 500m
    memory: 512Mi
  requests:
    cpu: 250m
    memory: 256Mi
```

## Networking

### Docker Compose
- Single bridge network (`easm-rnd_default`)
- Services communicate via service names
- Simple DNS resolution

### Skaffold
- Kubernetes Services (ClusterIP)
- Services communicate via service names
- Advanced DNS with namespaces
- Can expose via NodePort, LoadBalancer, or Ingress

## Commands Comparison

| Task | Docker Compose | Skaffold |
|------|----------------|----------|
| **Start** | `docker compose up` | `skaffold dev` or `skaffold run` |
| **Stop** | `docker compose down` | `skaffold delete` or `Ctrl+C` |
| **Build** | `docker compose build` | `skaffold build` |
| **Logs** | `docker compose logs -f` | `kubectl logs -f deployment/easm-api` |
| **Shell** | `docker compose exec api bash` | `kubectl exec -it deployment/easm-api -- bash` |
| **Scale** | `docker compose up --scale api=3` | `kubectl scale deployment/easm-api --replicas=3` |
| **Restart** | `docker compose restart api` | `kubectl rollout restart deployment/easm-api` |

## Migration Path

### From Docker Compose to Skaffold

1. **Install prerequisites:**
   ```powershell
   minikube start
   helm repo add bitnami https://charts.bitnami.com/bitnami
   helm repo update
   ```

2. **Update environment variables:**
   - Change `POSTGRES_HOST` from `postgres` to `postgresql`
   - Change `REDIS_HOST` from `redis` to `redis-master`

3. **Deploy with Skaffold:**
   ```powershell
   skaffold dev
   ```

4. **Verify services:**
   ```powershell
   kubectl get pods
   kubectl get services
   ```

5. **Access application:**
   - Skaffold automatically port-forwards
   - Or manually: `kubectl port-forward service/easm-api 8000:8000`

## When to Use Each

### Use Docker Compose When:
- ✅ Local development on a single machine
- ✅ Simple multi-container applications
- ✅ Quick prototyping
- ✅ No need for orchestration features
- ✅ Team is familiar with Docker only
- ✅ Limited resources (no Kubernetes cluster needed)

### Use Skaffold When:
- ✅ Production-like local environment
- ✅ Need Kubernetes features (scaling, health checks, rolling updates)
- ✅ Multi-node deployments
- ✅ CI/CD pipeline integration
- ✅ Team uses Kubernetes in production
- ✅ Need advanced networking (Ingress, NetworkPolicies)
- ✅ Require high availability
- ✅ Complex microservices architecture

## Key Differences

### Advantages of Docker Compose:
1. **Simpler** - Easier to learn and use
2. **Faster startup** - No Kubernetes overhead
3. **Less resource intensive** - Runs on local Docker
4. **Better for simple apps** - Perfect for monoliths
5. **Easier debugging** - Direct container access

### Advantages of Skaffold:
1. **Production-like** - Mirrors production environment
2. **Scalable** - Easy horizontal scaling
3. **High availability** - Built-in health checks and restarts
4. **Advanced features** - Ingress, NetworkPolicies, RBAC
5. **Cloud-ready** - Works with GKE, EKS, AKS
6. **Better CI/CD** - Native Kubernetes integration
7. **Service mesh** - Can integrate with Istio, Linkerd

## Configuration Files

### Docker Compose
- `docker-compose.yml` - Service definitions
- `.env` - Environment variables
- `Dockerfile` - Image build instructions

### Skaffold
- `skaffold.yaml` - Build and deploy configuration
- `src/charts/easm-api/Chart.yaml` - Helm chart metadata
- `src/charts/easm-api/values.yaml` - Configuration values
- `src/charts/easm-api/templates/*.yaml` - Kubernetes manifests
- `Dockerfile` - Image build instructions

## Database Initialization

### Docker Compose
```bash
# Migrations run automatically on startup via start-api.sh
docker compose up
```

### Skaffold
```bash
# Migrations need to be run manually
kubectl exec -it deployment/easm-api -- python manage.py migrate

# Or add init container to Helm chart
initContainers:
  - name: migrations
    image: easm-api:latest
    command: ["python", "manage.py", "migrate"]
```

## Development Workflow

### Docker Compose
```bash
# Make code changes
# Rebuild and restart
docker compose up --build

# Or with volumes (hot reload)
docker compose up  # Changes reflected immediately
```

### Skaffold
```bash
# Make code changes
# Skaffold auto-rebuilds and redeploys
skaffold dev  # Changes reflected automatically

# Hot reload via file sync (faster)
# Configure in skaffold.yaml:
build:
  artifacts:
    - image: easm-api
      sync:
        manual:
          - src: 'src/**/*.py'
            dest: /app
```

## Summary

Both configurations provide similar functionality but with different approaches:

- **Docker Compose** is simpler and faster for local development
- **Skaffold** provides production-like environment with Kubernetes features

Choose based on your team's needs, infra, and production environment.
