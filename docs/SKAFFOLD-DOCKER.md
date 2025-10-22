# Skaffold Docker Configuration

This document explains how to use `skaffold-docker.yml` for local development with Docker Compose.

## Overview

`skaffold-docker.yml` provides Skaffold integration with Docker Compose, offering:
- Automatic image building and deployment
- Hot reload during development
- Multiple profiles for different environments
- Health checks and verification
- Automated testing

## Prerequisites

- Docker Desktop installed and running
- Skaffold CLI installed (`choco install skaffold` or download from https://skaffold.dev/)
- Docker Compose (included with Docker Desktop)

## Quick Start

### 1. Development Mode (with hot reload)

```powershell
# Start in development mode with automatic rebuilds
skaffold dev -f skaffold-docker.yml --profile=dev

# Or use the shorter form
skaffold dev -f skaffold-docker.yml -p dev
```

This will:
- Build the Docker image
- Start all services (postgres, redis, api)
- Watch for file changes and sync them to the container
- Automatically rebuild when needed
- Stream logs to your terminal

### 2. Run Mode (one-time deployment)

```powershell
# Run with default settings
skaffold run -f skaffold-docker.yml

# Run in production-like mode
skaffold run -f skaffold-docker.yml --profile=prod

# Run in test mode
skaffold run -f skaffold-docker.yml --profile=test
```

### 3. Build Only

```powershell
# Build the image without deploying
skaffold build -f skaffold-docker.yml
```

### 4. Debug Mode

```powershell
# Run with verbose logging
skaffold dev -f skaffold-docker.yml --profile=dev -v debug
```

## Available Profiles

### 1. **dev** (Development)
- Hot reload enabled
- Debug mode on
- Single replica
- File sync for Python files
- Verbose logging

**Usage:**
```powershell
skaffold dev -f skaffold-docker.yml -p dev
```

**Environment:**
- `DJANGO_DEBUG=True`
- `DJANGO_LOG_LEVEL=DEBUG`
- `GUNICORN_WORKERS=4`

### 2. **prod** (Production-like)
- Debug mode off
- More workers (8)
- No file sync
- Optimized for performance

**Usage:**
```powershell
skaffold run -f skaffold-docker.yml -p prod
```

**Environment:**
- `DJANGO_DEBUG=False`
- `GUNICORN_WORKERS=8`

### 3. **test** (Testing)
- Separate test database
- Debug mode on
- Configured for running tests

**Usage:**
```powershell
skaffold run -f skaffold-docker.yml -p test
```

**Environment:**
- `POSTGRES_DB=easm_test_db`
- `DJANGO_DEBUG=True`

### 4. **ci** (Continuous Integration)
- For automated pipelines
- Debug off
- CI flag set

**Usage:**
```powershell
skaffold run -f skaffold-docker.yml -p ci
```

**Environment:**
- `CI=true`
- `DJANGO_DEBUG=False`

## File Sync (Hot Reload)

When using `skaffold dev`, file changes are automatically synced:

**Watched directories:**
- `src/backend/**/*.py` → `/app/`
- `src/backend/apps/**/*` → `/app/apps/`
- `src/backend/config/**/*` → `/app/config/`

**How it works:**
1. Save a Python file
2. Skaffold detects the change
3. File is synced to the container
4. Gunicorn auto-reloads (with `--reload` flag)
5. Changes are immediately available

## Health Checks & Verification

Skaffold automatically verifies deployment:

```powershell
# Manual verification
skaffold verify -f skaffold-docker.yml
```

**Checks performed:**
1. Django system check (`python manage.py check`)
2. Migrations status (`python manage.py showmigrations`)
3. API health endpoint (`curl http://localhost:8000/health/`)

## Testing

Run tests with Skaffold:

```powershell
# Run all tests
skaffold test -f skaffold-docker.yml
```

**Test suite includes:**
- Django unit tests
- Pytest tests
- Flake8 linting
- Black code formatting check

## Common Commands

### Start development environment
```powershell
skaffold dev -f skaffold-docker.yml -p dev
```

### Stop and clean up
```powershell
# Stop services (Ctrl+C in skaffold dev)
# Then clean up
skaffold delete -f skaffold-docker.yml
docker compose down -v  # Remove volumes too
```

### Rebuild from scratch
```powershell
skaffold delete -f skaffold-docker.yml
docker compose down -v
skaffold dev -f skaffold-docker.yml -p dev --cache-artifacts=false
```

### Check configuration
```powershell
# Diagnose configuration issues
skaffold diagnose -f skaffold-docker.yml

# Render final configuration
skaffold render -f skaffold-docker.yml -p dev
```

### View logs
```powershell
# All services
docker compose logs -f

# Specific service
docker compose logs -f api
docker compose logs -f postgres
docker compose logs -f redis
```

## Port Forwarding

Ports are automatically exposed via Docker Compose:

| Service | Internal Port | External Port | URL |
|---------|--------------|---------------|-----|
| API | 8000 | 8000 | http://localhost:8000 |
| PostgreSQL | 5432 | 5433 | localhost:5433 |
| Redis | 6379 | 6379 | localhost:6379 |

**Access API:**
```powershell
# Health check
curl http://localhost:8000/health/

# API root
curl http://localhost:8000/api/

# Swagger docs
Start-Process http://localhost:8000/api/docs/

# ReDoc
Start-Process http://localhost:8000/api/redoc/
```

## Environment Variables

Create a `.env` file in the root directory:

```env
# Django Settings
DEBUG=True
SECRET_KEY=your-secret-key
ALLOWED_HOSTS=localhost,127.0.0.1

# Database
POSTGRES_DB=easm_rnd
POSTGRES_USER=postgres
POSTGRES_PASSWORD=easm_password
POSTGRES_HOST=postgres
POSTGRES_PORT=5432

# Redis
REDIS_HOST=redis
REDIS_PORT=6379
REDIS_DB=0

# JWT Settings
JWT_ACCESS_TOKEN_LIFETIME=60
JWT_REFRESH_TOKEN_LIFETIME=1440

# Gunicorn
GUNICORN_WORKERS=4
```

## Troubleshooting

### Issue: Port already in use
```powershell
# Check what's using the port
netstat -ano | findstr :8000

# Stop other services
docker compose down

# Or change port in docker-compose.yml
```

### Issue: Permission denied
```powershell
# Run Docker as administrator
# Or add your user to docker-users group
```

### Issue: Build fails
```powershell
# Clear Docker build cache
docker builder prune -a

# Rebuild from scratch
skaffold build -f skaffold-docker.yml --cache-artifacts=false
```

### Issue: File sync not working
```powershell
# Restart skaffold dev
# Check file paths in skaffold-docker.yml sync section
# Ensure files are under src/backend/
```

### Issue: Database connection fails
```powershell
# Check if postgres is running
docker compose ps

# Check logs
docker compose logs postgres

# Wait for health check
docker compose ps | Select-String "healthy"
```

## Comparison: skaffold.yaml vs skaffold-docker.yml

| Feature | skaffold.yaml | skaffold-docker.yml |
|---------|---------------|---------------------|
| Deployment | Kubernetes (Helm) | Docker Compose |
| Use Case | Production/K8s dev | Local development |
| Setup Complexity | Higher | Lower |
| Resource Usage | Higher | Lower |
| Hot Reload | Limited | Full support |
| Service Discovery | Kubernetes DNS | Docker network |
| Best For | K8s deployment | Quick local dev |

## Best Practices

1. **Use dev profile for development**
   ```powershell
   skaffold dev -f skaffold-docker.yml -p dev
   ```

2. **Test in prod profile before deploying**
   ```powershell
   skaffold run -f skaffold-docker.yml -p prod
   ```

3. **Clean up regularly**
   ```powershell
   docker system prune -a --volumes
   ```

4. **Keep .env file secure**
   - Already in `.gitignore`
   - Don't commit sensitive data

5. **Use verify for health checks**
   ```powershell
   skaffold verify -f skaffold-docker.yml
   ```

## Integration with CI/CD

### GitHub Actions Example
```yaml
name: Skaffold CI

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Install Skaffold
        run: |
          curl -Lo skaffold https://storage.googleapis.com/skaffold/releases/latest/skaffold-linux-amd64
          chmod +x skaffold
          sudo mv skaffold /usr/local/bin
      - name: Run tests
        run: skaffold test -f skaffold-docker.yml -p ci
```

## Additional Resources

- [Skaffold Documentation](https://skaffold.dev/docs/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Django Deployment Checklist](https://docs.djangoproject.com/en/stable/howto/deployment/checklist/)

## Support

For issues or questions:
1. Check Docker and Skaffold logs
2. Review this documentation
3. Check `docker-compose.yml` configuration
4. Consult project README.md
