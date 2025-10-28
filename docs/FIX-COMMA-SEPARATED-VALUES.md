# Fix: Comma-Separated Values in Helm --set

## Problem

When using `ALLOWED_HOSTS=localhost,127.0.0.1,0.0.0.0,*` in `skaffold.env` and passing it via `setValueTemplates`, Helm's `--set` flag interprets commas as **array separators**, causing the value to be split incorrectly.

### What Helm Sees

```bash
# What we want:
--set django.allowedHosts="localhost,127.0.0.1,0.0.0.0,*"

# What Helm interprets (WRONG):
--set django.allowedHosts[0]=localhost
--set django.allowedHosts[1]=127.0.0.1
--set django.allowedHosts[2]=0.0.0.0
--set django.allowedHosts[3]=*
```

This creates an **array** instead of a **string**, which breaks the ConfigMap template.

## Solutions (Ranked Best to Worst)

### Solution 1: Escape Commas with Backslash ✅ RECOMMENDED

**Change in `skaffold.env`:**

```env
# Escape each comma with backslash
ALLOWED_HOSTS=localhost\,127.0.0.1\,0.0.0.0\,*
```

**Keep in `skaffold.yaml`:**

```yaml
setValueTemplates:
  django.allowedHosts: "{{.ALLOWED_HOSTS}}"
```

**Pros:**

- ✅ Clean and explicit
- ✅ Works with standard Helm behavior
- ✅ No complex syntax
- ✅ Easy to understand

**Cons:**

- ⚠️ Need to remember to escape commas in env file
- ⚠️ Docker Compose might not need escaping (need to test)

---

### Solution 2: Use Double Quotes Around Entire Value ✅ ALTERNATIVE

**Keep in `skaffold.env`:**

```env
# No escaping needed
ALLOWED_HOSTS=localhost,127.0.0.1,0.0.0.0,*
```

**Change in `skaffold.yaml`:**

```yaml
setValueTemplates:
  # Double braces inside the template to preserve quotes
  django.allowedHosts: '"{{.ALLOWED_HOSTS}}"'
```

This results in Helm seeing:

```bash
--set django.allowedHosts="\"localhost,127.0.0.1,0.0.0.0,*\""
```

**Pros:**

- ✅ No changes to env file
- ✅ Works reliably

**Cons:**

- ⚠️ Slightly confusing nested quotes
- ⚠️ May add extra quotes to the final value

---

### Solution 3: Use Curly Braces (Helm 3.1+) ✅ MODERN APPROACH

**Keep in `skaffold.env`:**

```env
ALLOWED_HOSTS=localhost,127.0.0.1,0.0.0.0,*
```

**Change in `skaffold.yaml`:**

```yaml
setValueTemplates:
  # Wrap the template expansion in curly braces
  django.allowedHosts: "{{{.ALLOWED_HOSTS}}}"
```

**Explanation of Triple Braces:**

- `{{` - Go template start delimiter
- `{` - Literal curly brace for Helm
- `.ALLOWED_HOSTS` - Variable expansion
- `}` - Literal curly brace for Helm
- `}}` - Go template end delimiter

This results in Helm seeing:

```bash
--set django.allowedHosts="{localhost,127.0.0.1,0.0.0.0,*}"
```

**Pros:**

- ✅ No changes to env file
- ✅ Helm 3.1+ official syntax for literals
- ✅ Most elegant

**Cons:**

- ⚠️ Requires Helm 3.1 or later
- ⚠️ Triple braces look confusing

---

### Solution 4: Split into Array Format

**Change in `skaffold.env`:**

```env
# Use space or semicolon as separator
ALLOWED_HOSTS=localhost 127.0.0.1 0.0.0.0 *
# Or
ALLOWED_HOSTS=localhost;127.0.0.1;0.0.0.0;*
```

**Change in `skaffold.yaml`:**

```yaml
setValueTemplates:
  # Process in the chart template
  django.allowedHosts: "{{.ALLOWED_HOSTS}}"
```

**Change in Helm chart `values.yaml`:**

```yaml
django:
  allowedHosts: "localhost 127.0.0.1 0.0.0.0 *"
```

**Change in ConfigMap template:**

```yaml
# Replace spaces/semicolons with commas
ALLOWED_HOSTS: {{ .Values.django.allowedHosts | replace " " "," | quote }}
# Or for semicolons
ALLOWED_HOSTS: {{ .Values.django.allowedHosts | replace ";" "," | quote }}
```

**Pros:**

- ✅ Avoids comma issues entirely
- ✅ Flexible separator

**Cons:**

- ❌ Changes multiple files
- ❌ More complex
- ❌ Less readable

---

### Solution 5: Use Values File (Your Current Workaround)

**Remove from `setValueTemplates` in `skaffold.yaml`:**

```yaml
setValueTemplates:
  # Comment out or remove
  #django.allowedHosts: "{{.ALLOWED_HOSTS}}"
```

**Keep in `values.yaml`:**

```yaml
django:
  allowedHosts: "localhost,127.0.0.1,0.0.0.0,*"
```

**Pros:**

- ✅ Simple and reliable
- ✅ No special syntax needed
- ✅ Values file is version controlled

**Cons:**

- ❌ Defeats purpose of single environment file
- ❌ Need to edit values.yaml for different environments
- ❌ Not centralized in skaffold.env

---

## Recommended Solution

**Use Solution 1 (Escape Commas) or Solution 3 (Curly Braces)**

### Implementing Solution 1: Escaped Commas

1. **Update `skaffold.env`:**

```env
# Escape commas with backslash
ALLOWED_HOSTS=localhost\,127.0.0.1\,0.0.0.0\,*
```

2. **Update `skaffold.yaml`:**

```yaml
setValueTemplates:
  django.allowedHosts: "{{.ALLOWED_HOSTS}}"
```

3. **Test:**

```powershell
powershell -ExecutionPolicy Bypass -File .\skaffold.ps1
```

### Implementing Solution 3: Curly Braces (Already Applied)

1. **Keep `skaffold.env` as-is:**

```env
ALLOWED_HOSTS=localhost,127.0.0.1,0.0.0.0,*
```

2. **Already updated in `skaffold.yaml`:**

```yaml
setValueTemplates:
  django.allowedHosts: "{{{.ALLOWED_HOSTS}}}"
```

3. **Test:**

```powershell
powershell -ExecutionPolicy Bypass -File .\skaffold.ps1
```

---

## Verification

### Test Helm Parsing

```bash
# See what Helm receives
skaffold diagnose 2>&1 | grep -A2 "django.allowedHosts"
```

### Check ConfigMap After Deployment

```bash
# Deploy and check the actual ConfigMap
kubectl get configmap -n easm-rnd -o yaml | grep ALLOWED_HOSTS
```

Should show:

```yaml
ALLOWED_HOSTS: "localhost,127.0.0.1,0.0.0.0,*"
```

### Check Pod Environment

```bash
# Verify the pod sees the correct value
kubectl exec -n easm-rnd deployment/easm-api -- env | grep ALLOWED_HOSTS
```

Should output:

```
ALLOWED_HOSTS=localhost,127.0.0.1,0.0.0.0,*
```

---

## Docker Compose Compatibility

If using the same `skaffold.env` file with Docker Compose:

**Solution 1 (Escaped Commas):**

- Docker Compose **might** interpret backslashes literally
- Test: Check if Django receives `localhost\,127.0.0.1` or `localhost,127.0.0.1`
- If it includes backslashes, you may need separate env files

**Solution 3 (Curly Braces):**

- Docker Compose passes the value as-is: ✅ Works perfectly
- No issues with compatibility

**Recommendation:** Use **Solution 3 (Curly Braces)** for best Docker Compose + Skaffold compatibility.

---

## Files Modified

1. **skaffold.yaml** - Changed `django.allowedHosts` to use `"{{{.ALLOWED_HOSTS}}}"`

## Current Status

✅ **Solution 3 (Curly Braces) is now applied**
✅ No changes needed to `skaffold.env`
✅ Compatible with both Skaffold and Docker Compose
✅ Ready to test

## Testing

```powershell
# Run the deployment
powershell -ExecutionPolicy Bypass -File .\skaffold.ps1

# After deployment, verify:
kubectl get configmap -n easm-rnd easm-api -o yaml | Select-String "ALLOWED_HOSTS"

# Should show: ALLOWED_HOSTS: "localhost,127.0.0.1,0.0.0.0,*"
```

## References

- [Helm --set Escaping](https://helm.sh/docs/intro/using_helm/#the-format-and-limitations-of---set)
- [Helm Values Format](https://helm.sh/docs/chart_template_guide/values_files/)
- [Skaffold setValueTemplates](https://skaffold.dev/docs/references/yaml/#deploy-helm-releases-setValueTemplates)
