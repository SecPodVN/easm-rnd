# Production Deployment Guide

This guide covers deploying the EASM Django REST API to production environments.

## Table of Contents

1. [Pre-deployment Checklist](#pre-deployment-checklist)
2. [Environment Configuration](#environment-configuration)
3. [Database Setup](#database-setup)
4. [Docker Deployment](#docker-deployment)
5. [Kubernetes Deployment](#kubernetes-deployment)
6. [Monitoring and Logging](#monitoring-and-logging)
7. [Security Hardening](#security-hardening)
8. [Backup and Recovery](#backup-and-recovery)

## Pre-deployment Checklist

- [ ] Change `SECRET_KEY` to a random secure value
- [ ] Set `DEBUG=False`
- [ ] Configure `ALLOWED_HOSTS` with your domain
- [ ] Use strong database passwords
- [ ] Set up SSL/TLS certificates
- [ ] Configure proper CORS settings
- [ ] Set up monitoring and alerting
- [ ] Configure backup strategy
- [ ] Review security settings
- [ ] Test all endpoints
- [ ] Load test the application
- [ ] Set up logging aggregation

## Environment Configuration

### Production Environment Variables

Create a `.env.production` file:

```bash
# Django Settings
DEBUG=False
SECRET_KEY=your-very-long-random-secret-key-here
ALLOWED_HOSTS=yourdomain.com,www.yourdomain.com

# Database (Use managed service)
POSTGRES_DB=easm_production
POSTGRES_USER=easm_prod_user
POSTGRES_PASSWORD=your-strong-password-here
POSTGRES_HOST=your-postgres-host.example.com
POSTGRES_PORT=5432

# Redis (Use managed service)
REDIS_HOST=your-redis-host.example.com
REDIS_PORT=6379
REDIS_DB=0

# JWT Settings
JWT_ACCESS_TOKEN_LIFETIME=15
JWT_REFRESH_TOKEN_LIFETIME=1440

# Additional Settings
SECURE_SSL_REDIRECT=True
SECURE_HSTS_SECONDS=31536000
SECURE_HSTS_INCLUDE_SUBDOMAINS=True
SECURE_HSTS_PRELOAD=True
SESSION_COOKIE_SECURE=True
CSRF_COOKIE_SECURE=True
```

### Generate Secret Key

```python
python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"
```

## Database Setup

### Using Managed PostgreSQL (Recommended)

1. **AWS RDS PostgreSQL**
   ```bash
   # Create RDS instance via AWS Console or CLI
   aws rds create-db-instance \
     --db-instance-identifier easm-postgres \
     --db-instance-class db.t3.micro \
     --engine postgres \
     --master-username easmadmin \
     --master-user-password YourPassword \
     --allocated-storage 20
   ```

2. **Google Cloud SQL**
   ```bash
   gcloud sql instances create easm-postgres \
     --database-version=POSTGRES_15 \
     --tier=db-f1-micro \
     --region=us-central1
   ```

3. **Azure Database for PostgreSQL**
   ```bash
   az postgres server create \
     --resource-group easm-rg \
     --name easm-postgres \
     --location eastus \
     --admin-user easmadmin \
     --admin-password YourPassword \
     --sku-name B_Gen5_1
   ```

### Database Migrations

```bash
# Run migrations
python manage.py migrate

# Create superuser
python manage.py createsuperuser

# Collect static files
python manage.py collectstatic --noinput
```

## Docker Deployment

### Build Production Image

```dockerfile
# Dockerfile.production
FROM python:3.13-slim

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

WORKDIR /app

# Install dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Poetry
RUN pip install poetry==1.7.1

# Copy files
COPY pyproject.toml poetry.lock ./
RUN poetry config virtualenvs.create false \
    && poetry install --only main --no-interaction --no-ansi

COPY . .

# Run as non-root user
RUN useradd -m -u 1000 appuser && chown -R appuser:appuser /app
USER appuser

EXPOSE 8000

CMD ["gunicorn", "src.backend.easm.wsgi:application", \
     "--bind", "0.0.0.0:8000", \
     "--workers", "4", \
     "--timeout", "120", \
     "--access-logfile", "-", \
     "--error-logfile", "-"]
```

### Docker Compose for Production

```yaml
version: '3.9'

services:
  web:
    build:
      context: .
      dockerfile: Dockerfile.production
    restart: always
    env_file:
      - .env.production
    depends_on:
      - postgres
      - redis
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/api/docs/"]
      interval: 30s
      timeout: 10s
      retries: 3
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

  nginx:
    image: nginx:alpine
    restart: always
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - ./certs:/etc/nginx/certs:ro
      - static_volume:/app/staticfiles:ro
    depends_on:
      - web

  postgres:
    image: postgres:18-alpine
    restart: always
    volumes:
      - postgres_data:/var/lib/postgresql/data
    env_file:
      - .env.production
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U $POSTGRES_USER"]
      interval: 10s
      timeout: 5s
      retries: 5

  redis:
    image: redis:8-alpine
    restart: always
    volumes:
      - redis_data:/data
    command: redis-server --appendonly yes

volumes:
  postgres_data:
  redis_data:
  static_volume:
```

## Kubernetes Deployment

### Prerequisites

1. Kubernetes cluster (EKS, GKE, AKS, or self-hosted)
2. kubectl configured
3. Helm 3 installed
4. Container registry (ECR, GCR, ACR, Docker Hub)

### Build and Push Image

```bash
# Build image
docker build -t your-registry/easm-api:v1.0.0 .

# Push to registry
docker push your-registry/easm-api:v1.0.0
```

### Create Namespace

```bash
kubectl create namespace easm-production
```

### Create Secrets

```bash
# Create secret for database credentials
kubectl create secret generic postgres-secret \
  --from-literal=POSTGRES_PASSWORD=your-password \
  --namespace=easm-production

# Create secret for Django
kubectl create secret generic django-secret \
  --from-literal=SECRET_KEY=your-secret-key \
  --namespace=easm-production
```

### Deploy with Helm

```bash
# Update values.yaml with production settings
helm install easm-api ./charts/easm-api \
  --namespace easm-production \
  --values charts/easm-api/values.production.yaml
```

### Production Helm Values

Create `charts/easm-api/values.production.yaml`:

```yaml
replicaCount: 3

image:
  repository: your-registry/easm-api
  tag: v1.0.0
  pullPolicy: Always

resources:
  limits:
    cpu: 1000m
    memory: 1Gi
  requests:
    cpu: 500m
    memory: 512Mi

autoscaling:
  enabled: true
  minReplicas: 3
  maxReplicas: 10
  targetCPUUtilizationPercentage: 70

ingress:
  enabled: true
  className: nginx
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
  hosts:
    - host: api.yourdomain.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: easm-api-tls
      hosts:
        - api.yourdomain.com

postgresql:
  enabled: false  # Use managed service
  host: your-postgres-host.example.com
  port: 5432
  database: easm_production
  username: easm_prod_user

redis:
  enabled: false  # Use managed service
  host: your-redis-host.example.com
  port: 6379

django:
  debug: "False"
  allowedHosts: "api.yourdomain.com"
```

### Deploy Infrastructure

```bash
# Install NGINX Ingress Controller
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm install nginx-ingress ingress-nginx/ingress-nginx \
  --namespace ingress-nginx --create-namespace

# Install cert-manager for SSL
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.0/cert-manager.yaml

# Create ClusterIssuer for Let's Encrypt
kubectl apply -f - <<EOF
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: your-email@example.com
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
        ingress:
          class: nginx
EOF
```

## Monitoring and Logging

### Prometheus and Grafana

```bash
# Install Prometheus
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring --create-namespace

# Access Grafana
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80
```

### Application Logging

Add to `settings.py`:

```python
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'formatters': {
        'verbose': {
            'format': '{levelname} {asctime} {module} {process:d} {thread:d} {message}',
            'style': '{',
        },
    },
    'handlers': {
        'console': {
            'class': 'logging.StreamHandler',
            'formatter': 'verbose',
        },
    },
    'root': {
        'handlers': ['console'],
        'level': 'INFO',
    },
    'loggers': {
        'django': {
            'handlers': ['console'],
            'level': 'INFO',
            'propagate': False,
        },
    },
}
```

## Security Hardening

### Django Security Settings

Add to `settings.py`:

```python
# Security settings for production
SECURE_SSL_REDIRECT = True
SECURE_PROXY_SSL_HEADER = ('HTTP_X_FORWARDED_PROTO', 'https')
SECURE_HSTS_SECONDS = 31536000
SECURE_HSTS_INCLUDE_SUBDOMAINS = True
SECURE_HSTS_PRELOAD = True
SECURE_CONTENT_TYPE_NOSNIFF = True
SECURE_BROWSER_XSS_FILTER = True
SESSION_COOKIE_SECURE = True
CSRF_COOKIE_SECURE = True
X_FRAME_OPTIONS = 'DENY'

# CORS settings
CORS_ALLOWED_ORIGINS = [
    "https://yourdomain.com",
    "https://www.yourdomain.com",
]
```

### Network Policies

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: easm-api-network-policy
  namespace: easm-production
spec:
  podSelector:
    matchLabels:
      app: easm-api
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: ingress-nginx
    ports:
    - protocol: TCP
      port: 8000
  egress:
  - to:
    - podSelector:
        matchLabels:
          app: postgres
    ports:
    - protocol: TCP
      port: 5432
  - to:
    - podSelector:
        matchLabels:
          app: redis
    ports:
    - protocol: TCP
      port: 6379
```

## Backup and Recovery

### Database Backup

```bash
# Automated backup script
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/backups"
DB_NAME="easm_production"

pg_dump -h $POSTGRES_HOST -U $POSTGRES_USER -d $DB_NAME | \
  gzip > $BACKUP_DIR/easm_backup_$DATE.sql.gz

# Upload to S3
aws s3 cp $BACKUP_DIR/easm_backup_$DATE.sql.gz \
  s3://your-backup-bucket/database/

# Keep only last 30 days
find $BACKUP_DIR -name "easm_backup_*.sql.gz" -mtime +30 -delete
```

### CronJob for Backups

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: postgres-backup
  namespace: easm-production
spec:
  schedule: "0 2 * * *"  # Daily at 2 AM
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: backup
            image: postgres:18-alpine
            command:
            - /bin/sh
            - -c
            - |
              pg_dump -h $POSTGRES_HOST -U $POSTGRES_USER -d $POSTGRES_DB | \
              gzip > /backup/easm_backup_$(date +%Y%m%d_%H%M%S).sql.gz
            env:
            - name: POSTGRES_HOST
              value: postgres-service
            - name: POSTGRES_USER
              valueFrom:
                secretKeyRef:
                  name: postgres-secret
                  key: POSTGRES_USER
            - name: POSTGRES_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: postgres-secret
                  key: POSTGRES_PASSWORD
            volumeMounts:
            - name: backup
              mountPath: /backup
          volumes:
          - name: backup
            persistentVolumeClaim:
              claimName: backup-pvc
          restartPolicy: OnFailure
```

## Rollback Strategy

```bash
# Helm rollback
helm rollback easm-api <revision> --namespace easm-production

# Kubernetes rollback
kubectl rollout undo deployment/easm-api -n easm-production

# Check rollout status
kubectl rollout status deployment/easm-api -n easm-production
```

## Health Checks

Add health check endpoints to Django:

```python
# src/backend/easm/views.py
from django.http import JsonResponse
from django.db import connections
from redis import Redis

def health_check(request):
    try:
        # Check database
        connections['default'].cursor()
        
        # Check Redis
        r = Redis(host=settings.REDIS_HOST, port=settings.REDIS_PORT)
        r.ping()
        
        return JsonResponse({'status': 'healthy'}, status=200)
    except Exception as e:
        return JsonResponse({'status': 'unhealthy', 'error': str(e)}, status=503)
```

## Performance Optimization

1. **Enable database connection pooling**
2. **Use Redis for caching**
3. **Enable gzip compression**
4. **Use CDN for static files**
5. **Optimize database queries**
6. **Use database indexes**
7. **Enable query caching**
8. **Use async workers for heavy tasks**

## Post-Deployment

1. Verify all endpoints are working
2. Check logs for errors
3. Monitor resource usage
4. Set up alerts
5. Document the deployment
6. Train the team
7. Create runbooks for common issues

## Troubleshooting

See main README.md for common issues and solutions.

## Support

For production support, refer to your organization's support channels.
