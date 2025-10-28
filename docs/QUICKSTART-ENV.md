# Quick Start Guide - Single Environment File

## Overview

This project now uses **ONE environment file** (`skaffold.env`) for all deployments:

- ✅ Skaffold (Kubernetes)
- ✅ Docker Compose
- ✅ Local development

## Setup (2 Steps)

### 1. Create Your Environment File

```bash
# Copy the example
cp skaffold.env.example skaffold.env
```

### 2. Start Your Application

**With Docker Compose:**

```bash
docker-compose up -d
```

**With Skaffold:**

```bash
skaffold dev
```

That's it! 🎉

## What's in skaffold.env?

All configuration in one place:

```env
# Django Settings
DEBUG=True
SECRET_KEY=your-secret-key
ALLOWED_HOSTS=localhost,127.0.0.1,*

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

# JWT (in minutes)
JWT_ACCESS_TOKEN_LIFETIME=60
JWT_REFRESH_TOKEN_LIFETIME=1440

# Application Version
API_APP_VERSION=0.1.0

# Docker Image
API_IMAGE=easm-api
API_IMAGE_TAG=latest

# Kubernetes
K8S_NAMESPACE=easm-rnd
K8S_REPLICA_COUNT=1

# Chart Versions
POSTGRESQL_CHART_VERSION=18.1.1
REDIS_CHART_VERSION=23.2.1
BITNAMI_REPO_URL=https://charts.bitnami.com/bitnami

# Gunicorn
GUNICORN_WORKERS=4
```

## Common Tasks

### Change Database Password

```env
# Edit skaffold.env
POSTGRES_PASSWORD=my-new-password
```

### Enable Production Mode

```env
# Edit skaffold.env
DEBUG=False
SECRET_KEY=your-production-secret-key-here
ALLOWED_HOSTS=yourdomain.com
```

### Upgrade PostgreSQL Chart

```env
# Edit skaffold.env
POSTGRESQL_CHART_VERSION=18.2.0
```

### Add Custom Domain

```env
# Edit skaffold.env - supports comma-separated values
ALLOWED_HOSTS=localhost,127.0.0.1,example.com,*.example.com
```

## Important Notes

### ⚠️ Security

- **NEVER commit `skaffold.env`** to git (already in .gitignore)
- Always use strong passwords in production
- Change `SECRET_KEY` from the default

### 📝 For Different Hosts

Set these values based on where you're running:

**Docker Compose:**

```env
POSTGRES_HOST=postgres
REDIS_HOST=redis
```

**Kubernetes (Skaffold):**

```env
POSTGRES_HOST=postgresql
REDIS_HOST=redis-master
```

**Local (direct Python):**

```env
POSTGRES_HOST=localhost
REDIS_HOST=localhost
```

## Troubleshooting

### Variables not loading?

```bash
# 1. Check file exists
ls skaffold.env

# 2. Check file format (no spaces around =)
cat skaffold.env

# 3. Restart services
docker-compose down
docker-compose up -d
# or
skaffold delete
skaffold dev
```

### Wrong values?

```bash
# Check what the container sees
docker-compose exec api env | grep POSTGRES

# For Kubernetes
kubectl get configmap easm-api -n easm-rnd -o yaml
```

## File Structure

```
easm-rnd/
├── skaffold.env          ← YOUR environment (gitignored, edit this!)
├── skaffold.env.example  ← Template (don't edit directly)
├── values.yaml           ← Helm defaults (rarely edit)
├── skaffold.yaml         ← Loads from skaffold.env
└── docker-compose.yml    ← Loads from skaffold.env
```

## Need More Info?

- **Detailed docs:** `docs/ENV-VARIABLES.md`
- **Migration guide:** `docs/ENVIRONMENT-MIGRATION.md`
- **Full README:** `README.md`

## Quick Commands

```bash
# Setup
cp skaffold.env.example skaffold.env

# Run with Docker Compose
docker-compose up -d
docker-compose logs -f api

# Run with Skaffold
skaffold dev

# Check environment
docker-compose exec api env

# Restart
docker-compose restart
# or
skaffold delete && skaffold dev
```

## Example Workflow

```bash
# 1. Clone repo
git clone <repo-url>
cd easm-rnd

# 2. Setup environment
cp skaffold.env.example skaffold.env

# 3. (Optional) Customize
nano skaffold.env  # Edit as needed

# 4. Start developing
skaffold dev
# or
docker-compose up -d

# 5. Make changes
# Edit skaffold.env anytime
# Restart services to apply changes

# 6. Deploy to production
# Create skaffold.env with production values
# Run skaffold run or docker-compose up
```

## What Changed?

If you were using `.env` before:

**Old way:**

- Multiple possible `.env` files
- Hardcoded values in `skaffold.yaml`
- ALLOWED_HOSTS didn't work with commas
- values.yaml in nested folder

**New way:**

- Single `skaffold.env` file
- All values configurable via environment
- ALLOWED_HOSTS works perfectly
- values.yaml in root directory

Simply rename your `.env` to `skaffold.env` and add the new variables from `skaffold.env.example`.
