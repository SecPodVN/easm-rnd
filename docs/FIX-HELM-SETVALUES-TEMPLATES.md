# Fix: Helm setValues vs setValueTemplates

## Issue

When running `skaffold dev`, the PostgreSQL installation failed with the error:

```
Error: INSTALLATION FAILED: failed parsing --set data: key "}" has no value
deploying "postgresql": install: exit status 1
```

Additionally, cleanup errors appeared:

```
Error: uninstall: Release not loaded: postgresql: release: not found
Error: uninstall: Release not loaded: redis: release: not found
Error: uninstall: Release not loaded: easm-api: release: not found
```

## Root Cause

In the Skaffold Helm configuration, **`setValues`** does NOT support template variable expansion. When we used:

```yaml
setValues:
  auth.database: "{{.POSTGRES_DB}}"
  auth.username: "{{.POSTGRES_USER}}"
  auth.password: "{{.POSTGRES_PASSWORD}}"
```

Skaffold passed the **literal strings** `'{{.POSTGRES_DB}}'` to Helm's `--set` flag instead of evaluating them. This caused Helm to receive malformed arguments like:

```bash
helm install postgresql bitnami/postgresql \
  --set auth.database='{{.POSTGRES_DB}}' \
  --set auth.username='{{.POSTGRES_USER}}' \
  --set auth.password='{{.POSTGRES_PASSWORD}}'
```

The curly braces `{{}}` confused Helm's parser, resulting in the error.

## Solution

Use **`setValueTemplates`** for any values that contain Skaffold template variables, and keep **`setValues`** only for literal/static values.

### Fixed Configuration

```yaml
deploy:
  helm:
    releases:
      - name: postgresql
        remoteChart: postgresql
        repo: "{{.BITNAMI_REPO_URL}}"
        version: "{{.POSTGRESQL_CHART_VERSION}}"
        namespace: "{{.K8S_NAMESPACE}}"
        createNamespace: true
        # Template variables MUST use setValueTemplates
        setValueTemplates:
          auth.database: "{{.POSTGRES_DB}}"
          auth.username: "{{.POSTGRES_USER}}"
          auth.password: "{{.POSTGRES_PASSWORD}}"
        # Static/literal values use setValues
        setValues:
          primary.persistence.enabled: false
          image.pullPolicy: IfNotPresent
        wait: false
```

## Difference Between setValues and setValueTemplates

| Field               | Purpose                       | Example                         | When Evaluated               |
| ------------------- | ----------------------------- | ------------------------------- | ---------------------------- |
| `setValues`         | Static, literal values        | `debug: false`<br>`replicas: 3` | Never - passed as-is to Helm |
| `setValueTemplates` | Dynamic values with templates | `database: "{{.POSTGRES_DB}}"`  | Before passing to Helm       |

### Rule of Thumb

- **Contains `{{.VARIABLE}}`?** → Use `setValueTemplates`
- **Static/hardcoded value?** → Use `setValues`

## Examples

### ✅ Correct Usage

```yaml
# PostgreSQL with mixed values
- name: postgresql
  setValueTemplates:
    # Template variables
    auth.database: "{{.POSTGRES_DB}}"
    auth.username: "{{.POSTGRES_USER}}"
    auth.password: "{{.POSTGRES_PASSWORD}}"
  setValues:
    # Static values
    primary.persistence.enabled: false
    image.pullPolicy: IfNotPresent
    architecture: standalone
```

```yaml
# Redis with only static values
- name: redis
  setValues:
    # No template variables, all static
    auth.enabled: false
    architecture: standalone
    master.persistence.enabled: false
    image.pullPolicy: IfNotPresent
```

```yaml
# EASM API with many template variables
- name: easm-api
  setValueTemplates:
    # All dynamic from environment
    image.repository: "{{.API_IMAGE}}"
    image.tag: "{{.API_IMAGE_TAG}}"
    postgresql.host: "{{.POSTGRES_HOST}}"
    postgresql.database: "{{.POSTGRES_DB}}"
    django.secretKey: "{{.SECRET_KEY}}"
  setValues:
    # Static overrides
    image.pullPolicy: Never
    postgresql.enabled: false
    redis.enabled: false
```

### ❌ Incorrect Usage

```yaml
# WRONG - Template variables in setValues
- name: postgresql
  setValues:
    auth.database: "{{.POSTGRES_DB}}" # ❌ Won't be expanded!
    auth.username: "{{.POSTGRES_USER}}" # ❌ Passed as literal string
```

## Verification

### Before Fix

```bash
$ skaffold diagnose 2>&1 | grep -A3 "name: postgresql"
- name: postgresql
  setValues:
    auth.database: '{{.POSTGRES_DB}}'      # ❌ Literal string!
    auth.username: '{{.POSTGRES_USER}}'    # ❌ Literal string!
```

### After Fix

```bash
$ skaffold diagnose 2>&1 | grep -A5 "name: postgresql"
- name: postgresql
  setValues:
    image.pullPolicy: IfNotPresent
    primary.persistence.enabled: "false"
  setValueTemplates:                       # ✅ Correct!
    auth.database: '{{.POSTGRES_DB}}'      # ✅ Will be expanded
    auth.username: '{{.POSTGRES_USER}}'    # ✅ Will be expanded
```

## About the Cleanup Errors

The "Release not loaded" errors during cleanup are **normal** when:

1. No releases are currently installed
2. This is the first deployment
3. Skaffold tries to clean up before deploying

These errors are **harmless** and can be safely ignored. Skaffold will proceed with the installation after showing these messages.

To suppress cleanup errors (optional):

```bash
skaffold dev --cleanup=false
```

## Files Modified

1. **skaffold.yaml** - Moved template variables from `setValues` to `setValueTemplates` for PostgreSQL release

## Testing

```powershell
# Test the fix
powershell -ExecutionPolicy Bypass -File .\skaffold.ps1

# Choose option 1 (Development mode)
# Should now see:
# ✅ Generating tags...
# ✅ Checking cache...
# ✅ Starting deploy...
# ✅ Helm release postgresql not installed. Installing...
# ✅ Installation proceeds without parser errors
```

## Documentation References

- [Skaffold Helm Deployer](https://skaffold.dev/docs/deployers/helm/)
- [Template Support](https://skaffold.dev/docs/environment/templating/)
- [Helm setValues vs setValueTemplates](https://skaffold.dev/docs/references/yaml/#deploy-helm-releases-setValues)

## Key Takeaways

1. **`setValues`** passes values as-is to Helm without template expansion
2. **`setValueTemplates`** evaluates Skaffold templates before passing to Helm
3. **Template variables** (`{{.VAR}}`) MUST use `setValueTemplates`
4. **Static values** (booleans, numbers, strings) use `setValues`
5. **Cleanup errors** on first run are normal and harmless

## Status

✅ **FIXED** - PostgreSQL now installs correctly using `setValueTemplates` for dynamic values from `skaffold.env`.
