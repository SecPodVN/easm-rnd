# Environment Variables with Skaffold Docker

## How .env File Loading Works

The `skaffold-docker.yaml` configuration automatically loads environment variables from the `.env` file in the root directory through Docker Compose.

### Automatic .env Loading

Docker Compose (which Skaffold uses with `useCompose: true`) automatically:

1. **Reads `.env` file** from the project root directory
2. **Loads all variables** defined in the file
3. **Makes them available** to all services in docker-compose.yml

**No additional configuration needed!**

## .env File Location

```
easm-rnd/
├── .env                    ← Environment variables loaded automatically
├── docker-compose.yml      ← References ${VAR} from .env
├── skaffold-docker.yaml    ← Uses Docker Compose
└── src/
    └── backend/
```

## How It Works

### 1. Base Configuration (All Profiles)

```yaml
# skaffold-docker.yaml
deploy:
  docker:
    useCompose: true  # ← Automatically loads .env file
```

Docker Compose reads `.env` and substitutes variables in `docker-compose.yml`:

```yaml
# docker-compose.yml
services:
  postgres:
    environment:
      - POSTGRES_DB=${POSTGRES_DB:-easm_db}      # ← From .env
      - POSTGRES_USER=${POSTGRES_USER:-postgres}  # ← From .env
  
  api:
    env_file:
      - .env  # ← Explicit reference to .env
```

### 2. Profile-Specific Overrides

Each profile can override variables using patches:

```yaml
profiles:
  - name: dev
    patches:
      - op: add
        path: /deploy/docker/env
        value:
          - DJANGO_DEBUG=True        # ← Overrides .env value
          - DJANGO_LOG_LEVEL=DEBUG   # ← Adds new variable
```

**Priority (highest to lowest):**
1. Profile patches (in skaffold-docker.yaml)
2. Environment variables from .env file
3. Default values in docker-compose.yml

## Example .env File

```env
# Django Settings
DEBUG=True
SECRET_KEY=django-insecure-development-key
ALLOWED_HOSTS=localhost,127.0.0.1,0.0.0.0

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

## Usage Examples

### Development Mode
```powershell
# Uses .env + dev profile overrides
skaffold dev -f .\skaffold-docker.yaml -p dev

# Variables loaded:
# - All from .env
# - DJANGO_DEBUG=True (overridden)
# - DJANGO_LOG_LEVEL=DEBUG (added)
```

### Production Mode
```powershell
# Uses .env + prod profile overrides
ENV=production skaffold run -f .\skaffold-docker.yaml -p prod

# Variables loaded:
# - All from .env
# - DJANGO_DEBUG=False (overridden)
# - GUNICORN_WORKERS=8 (overridden)
```

### Test Mode
```powershell
# Uses .env + test profile overrides
ENV=test skaffold run -f .\skaffold-docker.yaml -p test

# Variables loaded:
# - All from .env
# - DJANGO_DEBUG=True (kept)
# - POSTGRES_DB=easm_test_db (overridden for test DB)
```

## Variable Override Examples

### Example 1: Override Single Variable
```powershell
# Override DJANGO_DEBUG from command line
DJANGO_DEBUG=False skaffold dev -f .\skaffold-docker.yaml
```

### Example 2: Use Different .env File
```powershell
# Create .env.production
cp .env .env.production
# Edit .env.production with production values

# Use it (Docker Compose only reads .env by default)
# Option 1: Rename before running
mv .env .env.backup
mv .env.production .env
skaffold run -f .\skaffold-docker.yaml -p prod

# Option 2: Set variables directly
$env:POSTGRES_PASSWORD="secure_prod_password"
skaffold run -f .\skaffold-docker.yaml -p prod
```

## Profile Environment Overrides

### Dev Profile
```yaml
patches:
  - op: add
    path: /deploy/docker/env
    value:
      - DJANGO_DEBUG=True
      - DJANGO_LOG_LEVEL=DEBUG
```

**Result:** Development settings with verbose logging

### Prod Profile
```yaml
patches:
  - op: add
    path: /deploy/docker/env
    value:
      - DJANGO_DEBUG=False
      - GUNICORN_WORKERS=8
```

**Result:** Production-ready with more workers

### Test Profile
```yaml
patches:
  - op: add
    path: /deploy/docker/env
    value:
      - DJANGO_SETTINGS_MODULE=config.settings
      - DJANGO_DEBUG=True
      - POSTGRES_DB=easm_test_db
```

**Result:** Separate test database

### CI Profile
```yaml
patches:
  - op: add
    path: /deploy/docker/env
    value:
      - DJANGO_DEBUG=False
      - CI=true
```

**Result:** CI/CD optimized settings

## Verification

Check which variables are loaded:

```powershell
# View environment in running container
docker compose exec api env

# Check specific variable
docker compose exec api printenv DJANGO_DEBUG

# View all Django settings
docker compose exec api python manage.py diffsettings
```

## Security Best Practices

### 1. Never Commit .env
```gitignore
# .gitignore
.env
.env.*
!.env.example
```

### 2. Provide .env.example
```env
# .env.example
DEBUG=True
SECRET_KEY=change-this-in-production
POSTGRES_PASSWORD=change-this
```

### 3. Use Secrets for Production
```powershell
# For production, use environment variables or secrets manager
# Don't rely on .env file in production
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
# Check .env file exists in root
ls .env

# Check .env file format (no spaces around =)
cat .env

# Restart services
skaffold delete -f .\skaffold-docker.yaml
skaffold dev -f .\skaffold-docker.yaml -p dev
```

### Issue: Wrong variable value
```powershell
# Check variable in container
docker compose exec api printenv VARIABLE_NAME

# Check docker-compose processes .env correctly
docker compose config
```

### Issue: Profile override not working
```powershell
# Verify patch syntax in skaffold-docker.yaml
skaffold diagnose -f .\skaffold-docker.yaml

# Check profile is active
skaffold dev -f .\skaffold-docker.yaml -p dev -v debug
```

## Summary

✅ `.env` file automatically loaded by Docker Compose
✅ Place `.env` in project root (same level as docker-compose.yml)
✅ Use profiles to override specific variables
✅ Command-line variables override both .env and profiles
✅ Keep `.env` in `.gitignore` for security

**Load Order (highest priority first):**
1. Command-line environment variables
2. Skaffold profile patches
3. `.env` file
4. docker-compose.yml defaults
