# Environment Configuration Migration

## Summary of Changes

This document describes the migration from using multiple environment files to a **single unified environment file** (`skaffold.env`) for both Skaffold and Docker Compose deployments.

## What Changed

### 1. Single Environment File

**Before:**

- `.env` - Environment file (unclear purpose)
- `.env.example` - Example template
- Multiple potential environment files

**After:**

- `skaffold.env` - **Single source of truth** for all environment variables
- `skaffold.env.example` - Example template with all variables documented

### 2. File Locations

**Before:**

```
easm-rnd/
├── .env
├── .env.example
└── src/
    └── charts/
        └── easm-api/
            └── values.yaml
```

**After:**

```
easm-rnd/
├── skaffold.env           # Single environment file (gitignored)
├── skaffold.env.example   # Template (committed)
├── values.yaml            # Helm defaults (moved to root, committed)
├── skaffold.yaml          # Updated to use envTemplate
└── src/
    └── charts/
        └── easm-api/
            └── values.yaml  # Original (kept for backward compatibility)
```

### 3. Configuration Updates

#### skaffold.yaml

**Added:**

```yaml
# Load environment variables from skaffold.env
deploy:
  envTemplate: skaffold.env
```

**Changed hardcoded values to variables:**

```yaml
# Before
version: "18.1.1"
auth.database: easm_db
auth.username: easm_user
auth.password: easm_password

# After
version: "{{.POSTGRESQL_CHART_VERSION}}"
auth.database: "{{.POSTGRES_DB}}"
auth.username: "{{.POSTGRES_USER}}"
auth.password: "{{.POSTGRES_PASSWORD}}"
```

**Enabled ALLOWED_HOSTS:**

```yaml
# Before
#django.allowedHosts: "{{.ALLOWED_HOSTS}}"  # Commented out

# After
django.allowedHosts: "{{.ALLOWED_HOSTS}}" # Now works with comma-separated values
```

**Updated values file path:**

```yaml
# Before
valuesFiles:
  - src/charts/easm-api/values.yaml

# After
valuesFiles:
  - values.yaml  # Now in root directory
```

#### docker-compose.yml

**Changed:**

```yaml
# Before
env_file:
  - .env

# After
env_file:
  - skaffold.env
```

#### values.yaml

- **Copied** from `src/charts/easm-api/values.yaml` to root directory
- **Added** documentation header explaining its purpose
- Serves as Helm chart defaults (overridden by Skaffold using `skaffold.env`)

### 4. New Environment Variables

Added to `skaffold.env`:

```env
# Previously hardcoded, now configurable
ALLOWED_HOSTS=localhost,127.0.0.1,0.0.0.0,*
POSTGRESQL_CHART_VERSION=18.1.1
REDIS_CHART_VERSION=23.2.1
GUNICORN_WORKERS=4
```

### 5. Documentation Updates

**Updated files:**

- `README.md` - New "Environment Configuration" section
- `docs/ENV-VARIABLES.md` - Complete rewrite for new approach
- `.gitignore` - Updated to ignore `skaffold.env` and variations

## Benefits

### ✅ Single Source of Truth

- One file (`skaffold.env`) for all environment variables
- No confusion about which file to edit
- Consistent across Skaffold and Docker Compose

### ✅ No More Hardcoded Values

- All configuration is externalized
- Easy to change database credentials, chart versions, etc.
- No need to edit YAML files for common changes

### ✅ ALLOWED_HOSTS Fixed

- Now supports comma-separated values properly
- Works with both Skaffold/Helm and Docker Compose
- No more parsing issues with Helm's `--set` command

### ✅ Centralized Configuration

- `values.yaml` moved to root for consistency
- All configuration files (`skaffold.yaml`, `values.yaml`, `skaffold.env`) in one place
- Easier to understand project structure

### ✅ Better Developer Experience

- Clear instructions in `README.md`
- Comprehensive documentation in `ENV-VARIABLES.md`
- Example file with all variables documented

## Migration Guide

### For Existing Developers

If you already have a `.env` file:

```bash
# 1. Rename your existing .env to skaffold.env
mv .env skaffold.env

# 2. Add new variables to skaffold.env
# Open skaffold.env and add:
# ALLOWED_HOSTS=localhost,127.0.0.1,0.0.0.0,*
# POSTGRESQL_CHART_VERSION=18.1.1
# REDIS_CHART_VERSION=23.2.1
# GUNICORN_WORKERS=4

# 3. Pull the latest changes
git pull

# 4. You're ready to go!
skaffold dev
# or
docker-compose up
```

### For New Developers

```bash
# 1. Clone the repository
git clone <repository-url>
cd easm-rnd

# 2. Copy the example environment file
cp skaffold.env.example skaffold.env

# 3. (Optional) Edit skaffold.env for your needs

# 4. Start development
skaffold dev
# or
docker-compose up
```

## Technical Details

### How Environment Variables Flow

#### Skaffold → Kubernetes

1. Skaffold reads `skaffold.env` via `envTemplate` configuration
2. Variables are substituted in `setValueTemplates` using `{{.VAR_NAME}}` syntax
3. Helm chart receives values and creates ConfigMap/Secret
4. Pods read environment variables from ConfigMap/Secret

#### Docker Compose → Containers

1. Docker Compose reads `skaffold.env` via `env_file` directive
2. Variables are injected directly into containers
3. Application reads from environment variables

### ALLOWED_HOSTS Solution

**Problem:** Comma-separated values in `ALLOWED_HOSTS` caused Helm parsing errors with `--set`.

**Solution:** Using Skaffold's `envTemplate` properly quotes and escapes values:

```yaml
# Skaffold handles this correctly
setValueTemplates:
  django.allowedHosts: "{{.ALLOWED_HOSTS}}"
```

The value `localhost,127.0.0.1,example.com` is passed to Helm as a properly quoted string.

### Chart Version Variables

**Why:** Allows easy upgrades of PostgreSQL and Redis without editing `skaffold.yaml`.

**Usage:**

```env
# In skaffold.env
POSTGRESQL_CHART_VERSION=18.1.1
REDIS_CHART_VERSION=23.2.1
```

```yaml
# In skaffold.yaml
version: "{{.POSTGRESQL_CHART_VERSION}}"
```

## Rollback Plan

If you need to rollback to the old approach:

```bash
# Restore .env file
git checkout HEAD~1 -- .env .env.example

# Restore old skaffold.yaml
git checkout HEAD~1 -- skaffold.yaml

# Restore old docker-compose.yml
git checkout HEAD~1 -- docker-compose.yml

# Remove new files
rm skaffold.env skaffold.env.example values.yaml
```

## Future Improvements

Potential enhancements:

1. **Environment-specific files** - `skaffold.env.dev`, `skaffold.env.prod`
2. **Secrets management** - Integration with Kubernetes Secrets or external secrets managers
3. **Validation script** - Ensure all required variables are set
4. **Docker Compose override** - `docker-compose.override.yml` for local customizations

## Questions?

For questions or issues:

1. Check `docs/ENV-VARIABLES.md` for detailed documentation
2. Review `skaffold.env.example` for all available variables
3. See `README.md` for quick start instructions
4. Create an issue in the repository
