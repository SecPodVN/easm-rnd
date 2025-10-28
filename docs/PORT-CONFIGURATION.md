# Port Configuration Guide

## Quick Summary

**Docker Compose:** Ports configurable via `skaffold.env` ✅
**Skaffold:** Use CLI flags with environment variables ✅

---

## Docker Compose (Environment Variables)

Edit `skaffold.env`:

```bash
API_LOCAL_PORT=8080
POSTGRES_LOCAL_PORT=5433
REDIS_LOCAL_PORT=6380
```

Run:

```bash
docker-compose up
```

---

## Skaffold (CLI Override)

### Option 1: Use Default Ports (8000, 5432, 6379)

```bash
skaffold dev
```

### Option 2: Use Custom Ports from Environment File

**PowerShell:**

```powershell
# Load environment file first
Get-Content skaffold.env | Where-Object { $_ -notmatch '^\s*#' } | ForEach-Object {
    $k,$v = $_ -split '=',2; [Environment]::SetEnvironmentVariable($k.Trim(),$v.Trim(),'Process')
}

# Run with environment variables
skaffold dev --port-forward-ports="$env:API_LOCAL_PORT:8000,$env:POSTGRES_LOCAL_PORT:5432,$env:REDIS_LOCAL_PORT:6379"
```

**Bash:**

```bash
# Load and run in one command
source skaffold.env && skaffold dev --port-forward-ports="${API_LOCAL_PORT}:8000,${POSTGRES_LOCAL_PORT}:5432,${REDIS_LOCAL_PORT}:6379"
```

### Option 3: Override Manually

```bash
skaffold dev --port-forward-ports=8080:8000,5433:5432,6380:6379
```

---

## Why Can't Skaffold Read Variables Directly?

Skaffold's `portForward.localPort` field expects **integer values**, not template strings. This is a Skaffold limitation, not a configuration issue.

**What works:** `localPort: 8000` ✅
**What doesn't work:** `localPort: "{{.API_LOCAL_PORT}}"` ❌

---

## Port Architecture

**Internal Ports (Fixed):**

- API: `8000` (Django default)
- PostgreSQL: `5432` (PostgreSQL standard)
- Redis: `6379` (Redis standard)

**External Ports (Configurable):**

- Control what port on your machine maps to the service
- Format: `<your-port>:<container-port>`
- Example: `8080:8000` → Access API on `localhost:8080`

---

## ALLOWED_HOSTS Question

**Q: Why is `allowedHosts` in both `values.yaml` and `skaffold.env`?**

**A:** They serve different purposes:

1. **`values.yaml`** → Default value for standalone Helm deployments
2. **`skaffold.env`** → Override for Skaffold development (wins when using Skaffold)

**When using Skaffold:**

```
values.yaml (default) → skaffold.env (override) → Final value
```

**When using Helm alone:**

```
values.yaml (used directly) → Final value
```

**Keep both for maximum compatibility!**

**What happens:**

```yaml
# docker-compose.yml
ports:
  - "8080:8000"
    #  ↑    ↑
    #  |    └─ Container internal port (8000) - FIXED
    #  └────── Your local port (8080) - CONFIGURABLE
```

**Result:**

- Inside container: Django still listens on port `8000` ✅
- From your machine: Access via `http://localhost:8080` ✅
- No app configuration changes needed ✅

## Environment Variables

### Added to skaffold.env

```env
# Exposed Ports Configuration (External/Local Ports Only)
# These are the ports you use to access services from your machine
# Internal container ports remain at their defaults (8000, 5432, 6379)
API_LOCAL_PORT=8000
POSTGRES_LOCAL_PORT=5432
REDIS_LOCAL_PORT=6379
```

### Internal Ports (Not in Environment File)

These are **hardcoded** in YAML files:

- API internal port: `8000`
- PostgreSQL internal port: `5432`
- Redis internal port: `6379`

## How It Works

### For Skaffold (Kubernetes Port Forwarding)

The `portForward` section in `skaffold.yaml` uses **fixed internal ports** with **configurable local ports**:

```yaml
portForward:
  - resourceType: service
    resourceName: easm-api
    namespace: "{{.K8S_NAMESPACE}}"
    port: 8000 # ← Fixed internal port
    localPort: "{{.API_LOCAL_PORT}}" # ← Configurable from skaffold.env

  - resourceType: service
    resourceName: postgresql
    namespace: "{{.K8S_NAMESPACE}}"
    port: 5432 # ← Fixed internal port
    localPort: "{{.POSTGRES_LOCAL_PORT}}" # ← Configurable from skaffold.env

  - resourceType: service
    resourceName: redis-master
    namespace: "{{.K8S_NAMESPACE}}"
    port: 6379 # ← Fixed internal port
    localPort: "{{.REDIS_LOCAL_PORT}}" # ← Configurable from skaffold.env
```

### For Docker Compose

The `docker-compose.yml` uses **fixed internal ports** with **configurable external ports**:

```yaml
services:
  postgres:
    ports:
      - "${POSTGRES_LOCAL_PORT:-5432}:5432"
      #        ↑                        ↑
      #        |                        └─ Internal port (FIXED)
      #        └─────────────────────────── External port (CONFIGURABLE)

  redis:
    ports:
      - "${REDIS_LOCAL_PORT:-6379}:6379"

  api:
    ports:
      - "${API_LOCAL_PORT:-8000}:8000"
```

**Format:** `"${EXTERNAL_PORT:-default}:INTERNAL_PORT"`

- Left side (external): Configurable via environment
- Right side (internal): Fixed/hardcoded

## Use Cases

### 1. Avoid Port Conflicts (Most Common)

If port 8000 is already in use on your machine:

```env
# skaffold.env
API_LOCAL_PORT=8080  # Use different external port
```

**Result:**

- Container: Django listens on `8000` (unchanged)
- Your machine: Access via `http://localhost:8080`
- **No application changes needed!**

### 2. Run Multiple Environments Simultaneously

Run dev and staging environments at the same time:

**Development (skaffold.env):**

```env
API_LOCAL_PORT=8000
POSTGRES_LOCAL_PORT=5432
REDIS_LOCAL_PORT=6379
```

**Staging (skaffold.env.staging):**

```env
API_LOCAL_PORT=8001       # Different external ports
POSTGRES_LOCAL_PORT=5433
REDIS_LOCAL_PORT=6380
```

**Result:** Both environments run without conflicts!

### 3. Standard Development Ports

Use common development ports:

```env
# skaffold.env
API_LOCAL_PORT=3000        # Common for Node.js devs
POSTGRES_LOCAL_PORT=5432   # Keep standard
REDIS_LOCAL_PORT=6379      # Keep standard
```

## Configuration Examples

### Default Configuration

```env
# Default ports (standard)
API_PORT=8000
API_LOCAL_PORT=8000
POSTGRES_LOCAL_PORT=5432
REDIS_LOCAL_PORT=6379
```

Access:

- API: `http://localhost:8000`
- PostgreSQL: `localhost:5432`
- Redis: `localhost:6379`

### Custom Ports (Development)

```env
# Custom ports to avoid conflicts
API_PORT=8000
API_LOCAL_PORT=8080      # Different from container
POSTGRES_LOCAL_PORT=15432
REDIS_LOCAL_PORT=16379
```

Access:

- API: `http://localhost:8080`
- PostgreSQL: `localhost:15432`
- Redis: `localhost:16379`

### Production-like Setup

```env
# Production uses standard ports
API_PORT=8000
API_LOCAL_PORT=80        # Standard HTTP port (requires admin/sudo)
POSTGRES_LOCAL_PORT=5432
REDIS_LOCAL_PORT=6379
```

## Port Variables Reference

| Variable              | Default | Scope    | Description                               |
| --------------------- | ------- | -------- | ----------------------------------------- |
| `API_LOCAL_PORT`      | 8000    | External | Port on your machine to access API        |
| `POSTGRES_LOCAL_PORT` | 5432    | External | Port on your machine to access PostgreSQL |
| `REDIS_LOCAL_PORT`    | 6379    | External | Port on your machine to access Redis      |

**Internal Ports (Fixed):**

- API Container: `8000` (Django default)
- PostgreSQL Container: `5432` (PostgreSQL standard)
- Redis Container: `6379` (Redis standard)

**Why separate?**

- **External ports** - You control these, change freely
- **Internal ports** - Application controls these, should remain fixed

## Testing

### Test with Docker Compose

1. Edit `skaffold.env`:

```env
API_LOCAL_PORT=8080
```

2. Start services:

```bash
docker-compose up -d
```

3. Verify:

```bash
# Check if port is mapped correctly
docker-compose ps

# Test API access
curl http://localhost:8080/health/
```

### Test with Skaffold

1. Edit `skaffold.env`:

```env
API_LOCAL_PORT=8080
POSTGRES_LOCAL_PORT=15432
```

2. Run Skaffold:

```bash
skaffold dev
```

3. Verify port forwarding:

```bash
# Check forwarded ports
kubectl get svc -n easm-rnd

# Test connectivity
curl http://localhost:8080/health/
psql -h localhost -p 15432 -U easm_user -d easm_db
```

## Important Notes

### Container vs Local Ports

- **Container Port (`API_PORT`, `POSTGRES_PORT`, `REDIS_PORT`):**

  - The port the service listens on INSIDE the container
  - Usually should stay at default values
  - Changed only if you modify the application configuration

- **Local Port (`*_LOCAL_PORT`):**
  - The port exposed on YOUR local machine
  - Can be changed freely to avoid conflicts
  - This is what you connect to from your browser/tools

### Default Values

Docker Compose uses the `:-` syntax for defaults:

```yaml
"${API_LOCAL_PORT:-8000}:${API_PORT:-8000}"
```

This means:

- If `API_LOCAL_PORT` is not set, use `8000`
- If `API_PORT` is not set, use `8000`

### Port Conflicts

If you see errors like:

```
Error: port is already allocated
```

Solution:

1. Find which port is in use
2. Change the `*_LOCAL_PORT` variable in `skaffold.env`
3. Restart the services

### Checking Port Availability

**Windows (PowerShell):**

```powershell
# Check if port 8000 is in use
Get-NetTCPConnection -LocalPort 8000 -ErrorAction SilentlyContinue

# Find what's using the port
netstat -ano | findstr :8000
```

**Linux/Mac:**

```bash
# Check if port 8000 is in use
lsof -i :8000

# Or
netstat -an | grep 8000
```

## Troubleshooting

### Issue: Port Already in Use

**Error:**

```
Error starting userland proxy: listen tcp4 0.0.0.0:8000: bind: address already in use
```

**Solution:**

```env
# Change local port in skaffold.env
API_LOCAL_PORT=8001  # Or any available port
```

### Issue: Can't Connect After Changing Ports

**Problem:** Changed `API_LOCAL_PORT` but still trying to access old port.

**Solution:** Use the new port:

```bash
# If you set API_LOCAL_PORT=8080
curl http://localhost:8080/health/  # ✅ Correct
curl http://localhost:8000/health/  # ❌ Wrong (old port)
```

### Issue: Application Can't Connect to Database

**Problem:** Changed `POSTGRES_PORT` but application still uses 5432.

**Solution:** `POSTGRES_PORT` is used by the application internally. If you change it, you must also update the PostgreSQL configuration. Usually you only need to change `POSTGRES_LOCAL_PORT`.

## Best Practices

### 1. Only Change Local Ports

For most use cases, only modify the `*_LOCAL_PORT` variables:

```env
# ✅ Good - only change what you expose
API_PORT=8000              # Keep default
API_LOCAL_PORT=8080        # Change for your machine

# ❌ Avoid - changing container ports requires app config changes
API_PORT=9000              # Now you need to reconfigure Django
API_LOCAL_PORT=9000
```

### 2. Document Custom Ports

If using non-standard ports, document them:

```env
# Port Configuration
# Note: Using port 8080 because 8000 conflicts with local server
API_PORT=8000
API_LOCAL_PORT=8080
```

### 3. Keep Staging/Prod Standard

For staging and production, use standard ports:

```env
# Production - standard ports
API_LOCAL_PORT=8000
POSTGRES_LOCAL_PORT=5432
REDIS_LOCAL_PORT=6379
```

### 4. Environment-Specific Files

For different environments:

```bash
# Development
cp skaffold.env.example skaffold.env
# Edit with custom ports if needed

# Staging
cp skaffold.env.example skaffold.env.staging
# Keep standard ports

# Production
cp skaffold.env.example skaffold.env.prod
# Keep standard ports
```

## Summary

✅ All ports now configurable via `skaffold.env`
✅ Easy to avoid port conflicts
✅ Support for multiple environments
✅ Works with both Skaffold and Docker Compose
✅ Default values ensure backward compatibility

### Quick Reference

```env
# Add these to your skaffold.env
API_PORT=8000
API_LOCAL_PORT=8000
POSTGRES_LOCAL_PORT=5432
REDIS_LOCAL_PORT=6379

# POSTGRES_PORT and REDIS_PORT already exist in Database/Redis sections
```
