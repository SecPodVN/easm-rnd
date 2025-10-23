# Environment Variables Simplification

## Summary of Changes

We've simplified the environment variable configuration by removing the `_K8S` suffix from PostgreSQL and Redis variables. Now we use the same variable names across all deployment methods (Docker Compose, Kubernetes, local development), with only the **values** changing based on the deployment context.

## Before (Multiple Variable Sets)

```bash
# For Docker Compose
POSTGRES_HOST=postgres
REDIS_HOST=redis

# For Kubernetes/Skaffold
POSTGRES_HOST_K8S=postgresql
REDIS_HOST_K8S=redis-master
```

## After (Single Variable Set)

```bash
# Database Configuration
POSTGRES_HOST=postgresql  # or postgres, or localhost
POSTGRES_PORT=5432
POSTGRES_DB=easm_db
POSTGRES_USER=easm_user
POSTGRES_PASSWORD=your_password

# Redis Configuration
REDIS_HOST=redis-master  # or redis, or localhost
REDIS_PORT=6379
REDIS_DB=0
```

## Environment-Specific Values

### Local Development

```bash
POSTGRES_HOST=localhost
REDIS_HOST=localhost
```

### Docker Compose

```bash
POSTGRES_HOST=postgres
REDIS_HOST=redis
```

### Kubernetes (Skaffold)

```bash
POSTGRES_HOST=postgresql
REDIS_HOST=redis-master
```

## Benefits

1. **Simpler Configuration**: One set of variable names for all environments
2. **Less Confusion**: No need to remember which suffix to use
3. **Easier Maintenance**: Fewer variables to manage
4. **Better Portability**: Same configuration structure across environments
5. **Cleaner Code**: Applications use the same variable names everywhere

## Migration Guide

If you have existing `.env` files, update them as follows:

### Step 1: Update Variable Names

Replace:
```bash
POSTGRES_HOST_K8S=postgresql
POSTGRES_PORT_K8S=5432
REDIS_HOST_K8S=redis-master
REDIS_PORT_K8S=6379
REDIS_DB_K8S=0
```

With:
```bash
POSTGRES_HOST=postgresql
POSTGRES_PORT=5432
REDIS_HOST=redis-master
REDIS_PORT=6379
REDIS_DB=0
```

### Step 2: Remove Duplicate Variables

Before:
```bash
# For Docker Compose
POSTGRES_HOST=postgres
POSTGRES_PORT=5432

# For Kubernetes/Skaffold
POSTGRES_HOST_K8S=postgresql
POSTGRES_PORT_K8S=5432
```

After (choose appropriate values for your deployment):
```bash
# Set values based on deployment method
POSTGRES_HOST=postgresql  # or postgres for Docker Compose
POSTGRES_PORT=5432
```

### Step 3: Copy Updated Example File

```bash
# Copy the updated example file
cp .env.example .env

# Edit with your specific values
nano .env  # or code .env
```

## Files Updated

The following files have been updated to reflect these changes:

1. **Configuration Files:**
   - `.env` - Main environment file
   - `.env.example` - Example/template file
   - `skaffold.yaml` - Removed `_K8S` suffixes

2. **Documentation:**
   - `ENV-CONFIG.md` - Updated variable descriptions
   - `COMPOSE-VS-SKAFFOLD.md` - Already correct (no changes needed)
   - `SKAFFOLD-GUIDE.md` - Already correct (no changes needed)
   - Other docs already used generic variable names

## Verification

After updating your `.env` file, verify the configuration:

### For Docker Compose:
```bash
# Check configuration
docker compose config

# Start services
docker compose up
```

### For Kubernetes/Skaffold:
```bash
# Load environment variables
Get-Content .env | ForEach-Object {
  if ($_ -match '^\s*([^#][^=]+)=(.*)$') {
    $name = $matches[1].Trim()
    $value = $matches[2].Trim()
    Set-Item -Path "env:$name" -Value $value
  }
}

# Verify and deploy
skaffold diagnose
skaffold dev
```

## Troubleshooting

### Issue: Application can't connect to database

**Solution:** Ensure `POSTGRES_HOST` is set correctly for your deployment:
- Docker Compose: `postgres` (service name)
- Kubernetes: `postgresql` (Bitnami chart release name)
- Local: `localhost`

### Issue: Application can't connect to Redis

**Solution:** Ensure `REDIS_HOST` is set correctly for your deployment:
- Docker Compose: `redis` (service name)
- Kubernetes: `redis-master` (Bitnami chart creates this)
- Local: `localhost`

### Issue: Skaffold deployment fails

**Solution:** Verify environment variables are loaded:
```powershell
# Windows PowerShell
echo $env:POSTGRES_HOST
echo $env:REDIS_HOST

# Linux/macOS/Bash
echo $POSTGRES_HOST
echo $REDIS_HOST
```

If not set, reload them:
```powershell
# Windows PowerShell
Get-Content .env | ForEach-Object {
  if ($_ -match '^\s*([^#][^=]+)=(.*)$') {
    Set-Item -Path "env:$($matches[1].Trim())" -Value $matches[2].Trim()
  }
}

# Linux/macOS/Bash
set -a
source .env
set +a
```

## Additional Resources

- [ENV-CONFIG.md](./ENV-CONFIG.md) - Complete environment variable reference
- [COMPOSE-VS-SKAFFOLD.md](./COMPOSE-VS-SKAFFOLD.md) - Deployment comparison
- [CROSS-PLATFORM.md](./CROSS-PLATFORM.md) - Cross-platform development guide
- [.env.example](./.env.example) - Template configuration file

---

**Note:** This change maintains backward compatibility at the application level - your Django settings and application code continue to use the same variable names without any changes needed.
