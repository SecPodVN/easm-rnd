# Environment Variables for Skaffold Port Forwarding - Research & Solutions

## Question

**Can we use environment variables to declare `localPort` in Skaffold's `portForward` section?**

## TL;DR - The Answer

**❌ No, template variables don't work in `portForward.localPort`**
**✅ But here are 3 working alternatives:**

1. **Use CLI flags with env vars** (Recommended, most flexible)
2. **Use Skaffold Profiles** (Good for predefined port sets)
3. **Edit `skaffold.yaml` directly** (Simple, manual)

---

## Research Process

### Attempt 1: Direct Template Variable ❌

```yaml
portForward:
  - localPort: "{{.API_LOCAL_PORT}}" # ❌ Fails
```

**Error:**

```
cannot unmarshal !!str `{{.API_...` into int
```

**Why it fails:** `localPort` expects `int` type, template returns `string`.

---

### Attempt 2: Sprig's `atoi` Function ❌

**Research Found:**

- Skaffold uses [Sprig template library](http://masterminds.github.io/sprig/)
- Sprig provides [`atoi` function](http://masterminds.github.io/sprig/conversion.html) for string→int conversion
- Sprig functions work in other Skaffold fields (e.g., `setValueTemplates`)

**Tested Syntax:**

```yaml
# Attempt 2a: Pipeline style
localPort: {{.API_LOCAL_PORT | default "8000" | atoi}}

# Attempt 2b: Function style
localPort: {{atoi (default .API_LOCAL_PORT "8000")}}
```

**Error:**

```
error parsing skaffold configuration file: unable to re-marshal YAML without dotted keys:
unable to parse YAML: yaml: invalid map key
```

**Why it fails:** Template evaluation happens AFTER YAML parsing. YAML parser sees invalid integer field before templates are processed.

---

### Attempt 3: YAML Anchors ❌

```yaml
.ports:
  api: &api_port 8000

portForward:
  - localPort: *api_port # ✅ This works syntactically
```

**Why it doesn't solve the problem:** YAML anchors are static values, can't read environment variables.

---

### Root Cause Analysis

**From Skaffold Documentation:**

[Templated Fields List](https://skaffold.dev/docs/environment/templating/):

```
portForward.namespace       ✅ Supports templates
portForward.resourceName    ✅ Supports templates
portForward.localPort       ❌ NOT in the list
```

**Technical Reason:**

1. Skaffold parses `skaffold.yaml` as pure YAML first
2. YAML parser expects `localPort: <integer>`
3. Template engine runs AFTER YAML parsing
4. By the time templates are evaluated, YAML parser has already failed

**Go Type Definition** (in Skaffold source):

```go
type PortForwardResource struct {
    LocalPort int  // Not *string, so no template support
    // ...
}
```

---

## Working Solutions

### Solution 1: CLI Flags with Environment Variables ✅ (RECOMMENDED)

**PowerShell:**

```powershell
# Load environment file
Get-Content skaffold.env | Where-Object { $_ -notmatch '^\s*#' } | ForEach-Object {
    $k,$v = $_ -split '=',2
    [Environment]::SetEnvironmentVariable($k.Trim(),$v.Trim(),'Process')
}

# Run with environment variables
skaffold dev --port-forward-ports="$env:API_LOCAL_PORT:8000,$env:POSTGRES_LOCAL_PORT:5432,$env:REDIS_LOCAL_PORT:6379"
```

**Bash:**

```bash
source skaffold.env && skaffold dev --port-forward-ports="${API_LOCAL_PORT}:8000,${POSTGRES_LOCAL_PORT}:5432,${REDIS_LOCAL_PORT}:6379"
```

**Advantages:**

- ✅ Uses environment file
- ✅ Flexible and dynamic
- ✅ No config file changes needed
- ✅ Works with CI/CD

**Disadvantages:**

- ❌ Longer command
- ❌ Must remember the syntax

---

### Solution 2: Skaffold Profiles ✅

Add to `skaffold.yaml`:

```yaml
profiles:
  - name: custom-ports
    patches:
      - op: replace
        path: /portForward/0/localPort
        value: 8080 # API port from env
      - op: replace
        path: /portForward/1/localPort
        value: 5433 # PostgreSQL port from env
      - op: replace
        path: /portForward/2/localPort
        value: 6380 # Redis port from env
```

**Usage:**

```bash
skaffold dev -p custom-ports
```

**Advantages:**

- ✅ Named configurations
- ✅ Easy to switch between port sets
- ✅ Self-documented in config

**Disadvantages:**

- ❌ Still static (can't read env vars)
- ❌ Must manually update profile values
- ❌ Need separate profile for each port combination

---

### Solution 3: Edit `skaffold.yaml` Directly ✅

Just change the values manually:

```yaml
portForward:
  - localPort: 8080 # Change from 8000
```

**Advantages:**

- ✅ Simplest approach
- ✅ No command-line complexity
- ✅ Clear and explicit

**Disadvantages:**

- ❌ Manual editing required
- ❌ Not dynamic
- ❌ Must commit changes or gitignore the file

---

## Comparison Table

| Solution        | Dynamic | Uses Env File | Complexity | Best For                  |
| --------------- | ------- | ------------- | ---------- | ------------------------- |
| **CLI Flags**   | ✅ Yes  | ✅ Yes        | Medium     | Development, CI/CD        |
| **Profiles**    | ❌ No   | ❌ No         | Low        | Predefined configurations |
| **Direct Edit** | ❌ No   | ❌ No         | Very Low   | One-time changes          |

---

## Why Other Skaffold Fields Support Templates But `localPort` Doesn't

### Fields That Support Templates:

```yaml
deploy:
  helm:
    releases:
      - name: "{{.RELEASE_NAME}}" # ✅ String field
        namespace: "{{.K8S_NAMESPACE}}" # ✅ String field
        version: "{{.CHART_VERSION}}" # ✅ String field (versions are strings!)
        setValueTemplates:
          replicaCount: "{{.REPLICA}}" # ✅ Helm receives as string, converts later
```

### Why These Work:

- **Type:** All are `string` in Go
- **Evaluation:** Templates expand to strings, which these fields accept
- **Conversion:** Helm/Kubectl handle type conversion downstream

### Why `portForward.localPort` Doesn't Work:

```yaml
portForward:
  - localPort: { { .PORT } } # ❌ Field is `int` in Go, not `string`
```

- **Type:** Go struct field is `int`, not `string`
- **Parsing Order:** YAML→Go struct happens BEFORE template evaluation
- **No Conversion:** Skaffold doesn't convert templates to integers for this field

---

## Official Skaffold Documentation References

1. **Templated Fields List:**
   https://skaffold.dev/docs/environment/templating/

   - Lists all supported template fields
   - `portForward.localPort` is NOT listed

2. **Port Forwarding:**
   https://skaffold.dev/docs/port-forwarding/

   - Shows static integer values only
   - No mention of template support

3. **CLI Flags:**
   https://skaffold.dev/docs/references/cli/

   - `--port-forward-ports` flag documented
   - Accepts `localPort:containerPort` format

4. **Sprig Functions:**
   http://masterminds.github.io/sprig/
   - `atoi` exists but can't be used for `localPort`

---

## Recommendation

### For Your Use Case (Development with Environment File):

**Use Solution 1 (CLI Flags)** with a simple wrapper alias:

**PowerShell** (`$PROFILE` or workspace script):

```powershell
function skdev {
    Get-Content skaffold.env | Where-Object { $_ -notmatch '^\s*#' } | ForEach-Object {
        $k,$v = $_ -split '=',2; [Environment]::SetEnvironmentVariable($k.Trim(),$v.Trim(),'Process')
    }
    skaffold dev --port-forward-ports="$env:API_LOCAL_PORT:8000,$env:POSTGRES_LOCAL_PORT:5432,$env:REDIS_LOCAL_PORT:6379" @args
}
```

**Usage:**

```powershell
skdev  # That's it!
```

**Bash** (`.bashrc` or `.bash_aliases`):

```bash
alias skdev='source skaffold.env && skaffold dev --port-forward-ports="${API_LOCAL_PORT}:8000,${POSTGRES_LOCAL_PORT}:5432,${REDIS_LOCAL_PORT}:6379"'
```

**Usage:**

```bash
skdev  # Done!
```

---

## Summary

**Question:** Can we use environment variables for `portForward.localPort` in Skaffold?

**Answer:**

- ❌ **Not directly in YAML** - Skaffold limitation, field doesn't support templates
- ✅ **Yes via CLI** - Use `--port-forward-ports` with shell env var expansion
- ✅ **Partial via Profiles** - Static values, but easily switchable

**Best Practice:**
Create a simple alias/function that combines:

1. Loading `skaffold.env`
2. Expanding env vars in CLI flags
3. Running `skaffold dev`

**Result:** Single command (`skdev`) that reads ports from environment file! 🎯

---

## Appendix: Tested Approaches

| #   | Approach        | Syntax                                                                  | Result               |
| --- | --------------- | ----------------------------------------------------------------------- | -------------------- |
| 1   | Direct template | `localPort: "{{.PORT}}"`                                                | ❌ Type mismatch     |
| 2   | atoi pipeline   | `localPort: {{.PORT \| atoi}}`                                          | ❌ YAML parse error  |
| 3   | atoi function   | `localPort: {{atoi .PORT}}`                                             | ❌ YAML parse error  |
| 4   | default + atoi  | `localPort: {{.PORT \| default "8000" \| atoi}}`                        | ❌ YAML parse error  |
| 5   | YAML anchor     | `localPort: *port`                                                      | ✅ Works but static  |
| 6   | Profile patch   | `patches: [{op: replace, path: /portForward/0/localPort, value: 8080}]` | ✅ Works but static  |
| 7   | CLI override    | `--port-forward-ports="${PORT}:8000"`                                   | ✅ Works dynamically |

**Conclusion:** Only #7 (CLI override) provides true dynamic environment variable support.
