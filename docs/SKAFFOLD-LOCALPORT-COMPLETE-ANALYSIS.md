# Loading localPort from Environment File in Skaffold - Complete Analysis

## Question

**Can we load `localPort` from environment file in `skaffold.yaml`?**

## TL;DR Answer

**❌ NO - Not directly in skaffold.yaml**
**✅ YES - But only through these 3 workarounds:**

1. CLI flags with env var expansion (Shell-level)
2. Skaffold Profiles (Static configs)
3. **Pre-generated skaffold.yaml from template** (NEW - Best compromise!)

---

## Complete Step-by-Step Analysis

### Step 1: Understanding the Root Constraint

**Skaffold's Port Forward Type Definition:**

```go
// From Skaffold source code
type PortForwardResource struct {
    LocalPort int  // INTEGER type, not *string
    Port int
    ResourceName string
    ResourceType string
    Namespace string  // ✅ Supports templates
}
```

**Key Finding:** `localPort` is defined as `int`, not `string`, in Go struct.

**Implication:** YAML parser expects integer BEFORE template engine runs.

---

### Step 2: Testing All Possible YAML Tricks

#### Attempt 1: Template Variables with Type Conversion

```yaml
localPort: { { .API_LOCAL_PORT | atoi } } # ❌ FAILED
```

**Error:** `unable to parse YAML: yaml: invalid map key`
**Why:** Templates evaluated AFTER YAML parsing

#### Attempt 2: Unquoted Template

```yaml
localPort: { { .API_LOCAL_PORT } } # ❌ FAILED
```

**Error:** `unable to parse YAML: invalid map key`
**Why:** Same parsing order issue

#### Attempt 3: Quoted Template (Your Attempt)

```yaml
localPort: "{{.REDIS_LOCAL_PORT}}" # ❌ FAILED
```

**Error:** `cannot unmarshal !!str into int`
**Why:** YAML sees string, expects int

#### Attempt 4: YAML Anchors

```yaml
x-ports:
  api: &api-port 8000

portForward:
  - localPort: *api-port # ✅ Works syntactically
```

**Problem:** Anchors are static - can't read environment variables
**Conclusion:** Not a solution for dynamic env-based configuration

#### Attempt 5: YAML Anchors with Dot Prefix

```yaml
.ports:
  api: &api-port 8000
```

**Error:** `field x-ports not found in type v4beta7.SkaffoldConfig`
**Why:** Skaffold strictly validates all top-level fields

#### Attempt 6: setValueTemplates in portForward (Your Error)

```yaml
portForward:
  - resourceType: service
    setValueTemplates:
      localPort: "{{.API_LOCAL_PORT}}"
```

**Error:** `field setValueTemplates not found in type v4beta7.PortForwardResource`
**Why:** `setValueTemplates` only exists in Helm releases, not portForward

---

### Step 3: Checking Skaffold's Templating Documentation

**From Official Docs:** [Templated Fields](https://skaffold.dev/docs/environment/templating/)

**Fields that support templates in portForward:**

- ✅ `portForward.namespace`
- ✅ `portForward.resourceName`
- ❌ `portForward.port` - NOT listed
- ❌ `portForward.localPort` - NOT listed

**Conclusion:** `localPort` intentionally does NOT support templates.

---

### Step 4: Exploring Advanced Workarounds

#### Workaround A: Generated Configuration File ✅

**Concept:** Pre-process `skaffold.yaml.template` → `skaffold.yaml`

**Implementation:**

1. Create `skaffold.yaml.template`:

```yaml
portForward:
  - localPort: __API_LOCAL_PORT__
  - localPort: __POSTGRES_LOCAL_PORT__
  - localPort: __REDIS_LOCAL_PORT__
```

2. Create generation script:

```powershell
# generate-skaffold.ps1
Get-Content skaffold.env | Where-Object { $_ -notmatch '^\s*#' } | ForEach-Object {
    $k,$v = $_ -split '=',2
    [Environment]::SetEnvironmentVariable($k.Trim(), $v.Trim(), 'Process')
}

(Get-Content skaffold.yaml.template) `
    -replace '__API_LOCAL_PORT__', $env:API_LOCAL_PORT `
    -replace '__POSTGRES_LOCAL_PORT__', $env:POSTGRES_LOCAL_PORT `
    -replace '__REDIS_LOCAL_PORT__', $env:REDIS_LOCAL_PORT `
| Set-Content skaffold.yaml
```

**Pros:**

- ✅ Truly dynamic from env file
- ✅ Valid integer in final YAML
- ✅ Single source of truth (skaffold.env)

**Cons:**

- ❌ Extra build step
- ❌ Must regenerate on env changes
- ❌ Two files to maintain (template + generated)

---

#### Workaround B: CLI Flags (Recommended by Skaffold) ✅

```bash
skaffold dev --port-forward-ports="${API_LOCAL_PORT}:8000,${POSTGRES_LOCAL_PORT}:5432,${REDIS_LOCAL_PORT}:6379"
```

**Pros:**

- ✅ Official Skaffold approach
- ✅ Fully dynamic
- ✅ No file generation needed

**Cons:**

- ❌ Long command
- ❌ Must load env vars in shell first

---

#### Workaround C: Skaffold Profiles ✅

```yaml
profiles:
  - name: ports-8080
    patches:
      - op: replace
        path: /portForward/0/localPort
        value: 8080
```

**Pros:**

- ✅ Built into Skaffold
- ✅ Named configurations
- ✅ Easy switching

**Cons:**

- ❌ Static (can't read env vars)
- ❌ Must create profile for each port combo
- ❌ Doesn't solve dynamic env problem

---

## Definitive Answer

### Can We Load localPort from Environment File?

**Direct Answer: NO**

**Reasons:**

1. Skaffold's `portForward.localPort` is type `int` in Go
2. YAML parsing happens BEFORE template evaluation
3. Field is NOT in the official template-supported fields list
4. No conversion mechanism exists (atoi doesn't work pre-parse)

### But We CAN Achieve the Goal Through:

| Solution           | Dynamic? | Uses Env File? | Complexity | Best For          |
| ------------------ | -------- | -------------- | ---------- | ----------------- |
| **CLI Flags**      | ✅       | ✅             | Low        | Quick development |
| **Generated YAML** | ✅       | ✅             | Medium     | Team workflows    |
| **Profiles**       | ❌       | ❌             | Low        | Fixed configs     |

---

## Recommended Solution

Since you want to use the environment file, here's the **BEST approach**:

### Option 1: Simple Alias (No Extra Files)

**PowerShell** - Add to your profile or create `skdev.ps1`:

```powershell
# Load env and run
Get-Content skaffold.env | Where-Object { $_ -notmatch '^\s*#' } | ForEach-Object {
    $k,$v = $_ -split '=',2
    [Environment]::SetEnvironmentVariable($k.Trim(), $v.Trim(), 'Process')
}

skaffold dev --port-forward-ports="$env:API_LOCAL_PORT:8000,$env:POSTGRES_LOCAL_PORT:5432,$env:REDIS_LOCAL_PORT:6379" $args
```

**Usage:**

```powershell
.\skdev.ps1  # One command!
```

**Bash** - Add to `.bash_aliases`:

```bash
alias skdev='source skaffold.env && skaffold dev --port-forward-ports="${API_LOCAL_PORT}:8000,${POSTGRES_LOCAL_PORT}:5432,${REDIS_LOCAL_PORT}:6379"'
```

**Usage:**

```bash
skdev  # That's it!
```

---

## Why This Is the Best Solution

1. ✅ **Uses environment file** - Single source of truth
2. ✅ **Fully dynamic** - Change ports in skaffold.env anytime
3. ✅ **Official approach** - Uses Skaffold's documented CLI flags
4. ✅ **No extra files** - Just a simple wrapper script
5. ✅ **Shell-agnostic** - Works on Windows/Linux/Mac

---

## Alternative: If You MUST Have It In YAML

If you absolutely need ports in `skaffold.yaml` itself:

1. **Accept static values** - Just edit the YAML directly
2. **Use profiles** - Create profiles for common port combinations
3. **Generate dynamically** - Use the template approach above

But understand: **This is a Skaffold architectural limitation, not a configuration error.**

---

## Summary

**Question:** Can we load `localPort` from environment file in `skaffold.yaml`?

**Answer:**

- ❌ Not through YAML templates (architectural limitation)
- ❌ Not through Sprig functions (parsing order)
- ❌ Not through YAML tricks (type constraints)
- ✅ YES through CLI flags with shell env expansion
- ✅ YES through pre-generated YAML (template approach)

**Best Practice:** Use CLI flag approach with a simple wrapper script. It's the official, supported, and most flexible solution.

**Bottom Line:** Skaffold intentionally does NOT support templates in `portForward.localPort` because it's an integer field that must be parsed before template evaluation. The workaround is shell-level env var expansion in CLI flags. 🎯
