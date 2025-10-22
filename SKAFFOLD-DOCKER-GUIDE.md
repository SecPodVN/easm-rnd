# Skaffold Docker Configuration - Quick Reference

## What is skaffold-docker.yml?

A Skaffold configuration file that uses Docker Compose instead of Kubernetes for local development. It provides:

- ✅ Automatic Docker image building
- ✅ Docker Compose orchestration (postgres, redis, api)
- ✅ Hot reload for Python files
- ✅ Multiple environment profiles
- ✅ Health checks and verification
- ✅ Automated testing support

## Quick Start Commands

```powershell
# Development mode with hot reload (recommended)
skaffold dev -f skaffold-docker.yml -p dev

# Production-like mode
skaffold run -f skaffold-docker.yml -p prod

# Test mode
skaffold run -f skaffold-docker.yml -p test

# Stop and cleanup
# Press Ctrl+C then run:
skaffold delete -f skaffold-docker.yml
```

## Key Features

### 1. Multi-Stage Build Support
- Uses the secure multi-stage Dockerfile
- BuildKit enabled for faster builds
- Proper caching for dependencies

### 2. Hot Reload (Dev Profile)
Files automatically synced to container:
- `src/backend/**/*.py` → `/app/`
- `src/backend/apps/**/*` → `/app/apps/`
- `src/backend/config/**/*` → `/app/config/`

### 3. Environment Profiles

| Profile | Purpose | Debug | Workers | Use Case |
|---------|---------|-------|---------|----------|
| dev | Development | On | 4 | Local coding |
| prod | Production-like | Off | 8 | Pre-deploy test |
| test | Testing | On | 4 | Running tests |
| ci | CI/CD | Off | 4 | Automated builds |

### 4. Automatic Verification
Three health checks:
1. Django system check
2. Database migrations status
3. API health endpoint

### 5. Testing Integration
Runs multiple test suites:
- Django unit tests
- Pytest
- Flake8 linting
- Black formatting check

## Architecture

```
skaffold-docker.yml
       ↓
   Docker Compose (docker-compose.yml)
       ↓
   ┌─────────────────────────────────┐
   │  postgres:18  │  redis:8  │  api  │
   └─────────────────────────────────┘
```

## Comparison with skaffold.yaml

| Aspect | skaffold.yaml | skaffold-docker.yml |
|--------|---------------|---------------------|
| Deployment | Kubernetes (Helm) | Docker Compose |
| Complexity | High | Low |
| Resources | More | Less |
| Setup Time | 5-10 min | 1-2 min |
| Hot Reload | Limited | Full |
| Best For | K8s deployment | Local dev |

## When to Use Which?

**Use `skaffold-docker.yml`** when:
- 🔧 Local development
- 🚀 Quick prototyping
- 🧪 Testing features
- 💻 Limited resources
- 👥 New to the project

**Use `skaffold.yaml`** when:
- ☸️ Deploying to Kubernetes
- 🏭 Production environment
- 📊 Testing K8s configs
- 🔄 CI/CD pipeline
- 🎯 Minikube/K8s dev

## File Structure

```
easm-rnd/
├── skaffold.yaml           # Kubernetes/Helm deployment
├── skaffold-docker.yml     # Docker Compose deployment (NEW)
├── docker-compose.yml      # Service definitions
├── .env                    # Environment variables
├── src/
│   └── backend/
│       ├── Dockerfile      # Multi-stage secure build
│       ├── start-api.sh    # Startup script
│       └── ...
└── docs/
    └── SKAFFOLD-DOCKER.md  # Detailed documentation
```

## Environment Variables

Controlled via `.env` file:

```env
# Django
DEBUG=True
SECRET_KEY=your-secret-key

# Database  
POSTGRES_DB=easm_rnd
POSTGRES_USER=postgres
POSTGRES_PASSWORD=easm_password

# Redis
REDIS_HOST=redis
REDIS_PORT=6379

# Gunicorn
GUNICORN_WORKERS=4
```

## Common Workflows

### Daily Development
```powershell
# Start dev environment
skaffold dev -f skaffold-docker.yml -p dev

# Code changes auto-sync
# Press Ctrl+C when done
```

### Testing Changes
```powershell
# Run tests
skaffold test -f skaffold-docker.yml

# Or manually
docker compose exec api python manage.py test
docker compose exec api pytest
```

### Pre-Deployment Check
```powershell
# Test in prod mode
skaffold run -f skaffold-docker.yml -p prod

# Verify health
skaffold verify -f skaffold-docker.yml

# Cleanup
skaffold delete -f skaffold-docker.yml
```

### Clean Rebuild
```powershell
# Full cleanup
skaffold delete -f skaffold-docker.yml
docker compose down -v
docker system prune -a

# Rebuild from scratch
skaffold dev -f skaffold-docker.yml -p dev --cache-artifacts=false
```

## Troubleshooting Quick Fixes

### Build fails
```powershell
docker builder prune -a
skaffold build -f skaffold-docker.yml --cache-artifacts=false
```

### Port in use
```powershell
docker compose down
netstat -ano | findstr :8000
```

### Sync not working
```powershell
# Restart skaffold dev
# Check file is under src/backend/
```

### Database connection error
```powershell
docker compose ps  # Check if postgres is healthy
docker compose logs postgres
```

## Benefits Over Plain Docker Compose

| Feature | Docker Compose | Skaffold Docker |
|---------|----------------|-----------------|
| Build automation | Manual | Automatic |
| Image tagging | Manual | Automatic |
| Hot reload | Manual sync | Built-in |
| Health checks | Manual | Automatic |
| Profiles | Limited | Multiple |
| Testing | Manual | Integrated |
| Verification | Manual | Automatic |

## Next Steps

1. **Read full documentation**: `docs/SKAFFOLD-DOCKER.md`
2. **Try dev mode**: `skaffold dev -f skaffold-docker.yml -p dev`
3. **Run tests**: `skaffold test -f skaffold-docker.yml`
4. **Deploy to K8s**: Use `skaffold.yaml` instead

## Support

- 📖 Full docs: `docs/SKAFFOLD-DOCKER.md`
- 🐳 Docker Compose: `docker-compose.yml`
- ☸️ Kubernetes: `skaffold.yaml`
- 📝 Main README: `README.md`
