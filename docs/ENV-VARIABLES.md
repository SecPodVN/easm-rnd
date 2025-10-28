# Environment Variables Configuration

## Overview

The EASM-RND project uses a **single environment file** (`skaffold.env`) for both:

- **Skaffold** (Kubernetes deployments)
- **Docker Compose** (local development)

This unified approach eliminates confusion and ensures consistency across all deployment methods.

## How Environment File Loading Works

### For Skaffold (skaffold.yaml)

Skaffold loads environment variables from `skaffold.env` using the `envTemplate` configuration:

```yaml
# skaffold.yaml
deploy:
  envTemplate: skaffold.env
```

Variables are then used in Helm chart deployments via template syntax `{{.VARIABLE_NAME}}`.

### For Docker Compose (docker-compose.yml)

Docker Compose automatically reads `skaffold.env` when specified in the service configuration:

```yaml
# docker-compose.yml
services:
  api:
    env_file:
      - skaffold.env
```

## Environment File Location

```
easm-rnd/
├── skaffold.env           ← Single environment variable file (gitignored)
├── skaffold.env.example   ← Example template (committed to git)
├── values.yaml            ← Helm chart default values (committed to git)
├── skaffold.yaml          ← Skaffold configuration
├── docker-compose.yml     ← Docker Compose configuration
└── src/
    └── backend/
```

## How It Works

### 1. Skaffold Configuration

```yaml
# skaffold.yaml
deploy:
  envTemplate: skaffold.env # ← Loads environment variables

  helm:
    releases:
      - name: postgresql
        setValues:
          auth.database: "{{.POSTGRES_DB}}" # ← Uses variable from skaffold.env
          auth.username: "{{.POSTGRES_USER}}"
          auth.password: "{{.POSTGRES_PASSWORD}}"
```

### 2. Docker Compose Configuration

```yaml
# docker-compose.yml
services:
  postgres:
    environment:
      - POSTGRES_DB=${POSTGRES_DB:-easm_db} # ← From skaffold.env
      - POSTGRES_USER=${POSTGRES_USER:-postgres} # ← From skaffold.env

  api:
    env_file:
      - skaffold.env # ← Explicit reference to environment file
```

### 3. Helm Chart Values

The `values.yaml` file in the root directory provides default values for the Helm chart.
These defaults are overridden by Skaffold using variables from `skaffold.env`:

```yaml
# values.yaml (defaults)
postgresql:
  host: postgresql
  port: 5432
  database: easm_db
# Overridden by skaffold.yaml using skaffold.env values
```

**Priority (highest to lowest):**

1. Skaffold `setValueTemplates` (using `skaffold.env` variables)
2. Skaffold `setValues` (static overrides)
3. `values.yaml` file (defaults)

## Example skaffold.env File

```env
# Django Settings
DEBUG=True
SECRET_KEY=django-insecure-development-key
ALLOWED_HOSTS=localhost,127.0.0.1,0.0.0.0,*

# Database
POSTGRES_DB=easm_db
POSTGRES_USER=easm_user
POSTGRES_PASSWORD=easm_password
POSTGRES_HOST=postgresql
POSTGRES_PORT=5432

# Redis
REDIS_HOST=redis-master
REDIS_PORT=6379
REDIS_DB=0

# Port Forwarding Configuration
API_PORT=8000
API_LOCAL_PORT=8000
POSTGRES_LOCAL_PORT=5432
REDIS_LOCAL_PORT=6379

# JWT Settings (in minutes)
JWT_ACCESS_TOKEN_LIFETIME=60
JWT_REFRESH_TOKEN_LIFETIME=1440

# Application Version
API_APP_VERSION=0.1.0

# Docker Image Configuration
API_IMAGE=easm-api
API_IMAGE_TAG=latest

# Kubernetes/Skaffold Settings
K8S_NAMESPACE=easm-rnd
K8S_REPLICA_COUNT=1

# Bitnami Chart Versions
POSTGRESQL_CHART_VERSION=18.1.1
REDIS_CHART_VERSION=23.2.1
BITNAMI_REPO_URL=https://charts.bitnami.com/bitnami

# Gunicorn (for Docker Compose)
GUNICORN_WORKERS=4
```

## Special Handling for ALLOWED_HOSTS

The `ALLOWED_HOSTS` variable can contain comma-separated values:

```env
# skaffold.env
ALLOWED_HOSTS=localhost,127.0.0.1,example.com,*.example.com
```

This value is properly handled by:

- **Skaffold**: Passed to Helm as a quoted string via `setValueTemplates`
- **Docker Compose**: Directly injected into the container environment
- **Django**: Parsed and split by commas in the settings

**Note**: Previously, comma-separated values in ALLOWED_HOSTS caused issues with Helm's `--set`
command parsing. This is now resolved by using Skaffold's `envTemplate` feature which properly
quotes and escapes values.

## Usage Examples

### Development with Docker Compose

```powershell
# Setup environment
cp skaffold.env.example skaffold.env
# Edit skaffold.env with your values

# Start services
docker-compose up -d

# Variables loaded from skaffold.env
```

### Development with Skaffold

```powershell
# Setup environment (if not done already)
cp skaffold.env.example skaffold.env

# Start Skaffold
skaffold dev

# Variables loaded:
# - All from skaffold.env
# - Applied to Helm charts via setValueTemplates
```

### Production Deployment

```powershell
# Create production environment file
cp skaffold.env.example skaffold.env.prod

# Edit skaffold.env.prod with production values
# Update SECRET_KEY, POSTGRES_PASSWORD, etc.

# Use production environment
cp skaffold.env.prod skaffold.env
skaffold run
```

## Variable Override Examples

### Example 1: Override Single Variable via Environment

```powershell
# Windows PowerShell
$env:DEBUG="False"
skaffold dev

# Linux/macOS
DEBUG=False skaffold dev
```

### Example 2: Use Different Environment File

```powershell
# Create environment-specific files
cp skaffold.env.example skaffold.env.staging
cp skaffold.env.example skaffold.env.production

# Edit with appropriate values
# Then swap as needed
cp skaffold.env.staging skaffold.env
skaffold run
```

### Example 3: Override in docker-compose.yml

```yaml
# docker-compose.yml
services:
  api:
    env_file:
      - skaffold.env
    environment:
      # These override values from skaffold.env
      - DEBUG=False
      - GUNICORN_WORKERS=8
```

## Verification

Check which variables are loaded:

```powershell
# View environment in running container (Docker Compose)
docker-compose exec api env

# Check specific variable
docker-compose exec api printenv DEBUG

# View all Django settings
docker-compose exec api python manage.py diffsettings

# For Kubernetes (after skaffold dev), check pod environment
kubectl get configmap -n easm-rnd
kubectl describe configmap easm-api -n easm-rnd
```

## Security Best Practices

### 1. Never Commit skaffold.env

```gitignore
# .gitignore
skaffold.env
skaffold.env.*
!skaffold.env.example
```

### 2. Provide skaffold.env.example

```env
# skaffold.env.example
DEBUG=True
SECRET_KEY=change-this-in-production
POSTGRES_PASSWORD=change-this
ALLOWED_HOSTS=localhost,127.0.0.1
```

### 3. Use Secrets for Production

```powershell
# For production, use Kubernetes Secrets or external secrets management
# Don't rely solely on environment files in production
```

### 4. Validate Required Variables

```python
# config/settings.py
import os

REQUIRED_ENV_VARS = [
    'SECRET_KEY',
    'POSTGRES_PASSWORD',
]

for var in REQUIRED_ENV_VARS:
    if not os.getenv(var):
        raise ValueError(f"Required environment variable {var} is not set")
```

## Troubleshooting

### Issue: Variables not loaded

```powershell
# Check skaffold.env file exists in root
ls skaffold.env

# Check file format (no spaces around =)
cat skaffold.env

# Verify Skaffold loads the file
skaffold diagnose

# For Docker Compose, check configuration
docker-compose config
```

### Issue: Wrong variable value

```powershell
# Check variable in container
docker-compose exec api printenv VARIABLE_NAME

# Check Docker Compose processes skaffold.env correctly
docker-compose config

# For Skaffold, check rendered manifests
skaffold render
```

### Issue: ALLOWED_HOSTS with commas not working

```powershell
# Verify the value in skaffold.env
cat skaffold.env | grep ALLOWED_HOSTS

# Check how it's rendered in Kubernetes
skaffold render | grep -A 5 ALLOWED_HOSTS

# The value should be properly quoted in the ConfigMap
```

### Issue: Chart version variables not applied

```powershell
# Verify variables are in skaffold.env
cat skaffold.env | grep CHART_VERSION

# Check Skaffold renders the correct version
skaffold render | grep "chart:"
```

## Summary

✅ **Single environment file** (`skaffold.env`) for both Skaffold and Docker Compose
✅ Place `skaffold.env` in project root (same level as skaffold.yaml)
✅ Skaffold loads via `envTemplate` configuration
✅ Docker Compose loads via `env_file` directive
✅ ALLOWED_HOSTS supports comma-separated values
✅ Chart versions and all configurations centralized
✅ Keep `skaffold.env` in `.gitignore` for security

**File Structure:**

```
easm-rnd/
├── skaffold.env          # Your environment (gitignored)
├── skaffold.env.example  # Template (committed)
├── values.yaml           # Helm defaults (committed)
├── skaffold.yaml         # Skaffold config (uses envTemplate)
└── docker-compose.yml    # Docker Compose (uses env_file)
```

**Load Priority (highest to lowest):**

1. Environment variables set in shell/system
2. docker-compose.yml `environment` section (for Docker Compose only)
3. Skaffold `setValueTemplates` (using skaffold.env variables)
4. `skaffold.env` file
5. `values.yaml` defaults (for Helm/Skaffold)
