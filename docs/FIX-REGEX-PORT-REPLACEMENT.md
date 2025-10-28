# Fix: Regex Pattern for Port Replacement

## Issue

After fixing the `--port-forward-ports` flag issue, a new error appeared when running the scripts:

```
parsing skaffold config: error parsing skaffold configuration file: unable to parse config: yaml: unmarshal errors:
  line 72: cannot unmarshal !!str `8000 wi...` into int
  line 77: cannot unmarshal !!str `5432 wi...` into int
  line 82: cannot unmarshal !!str `6379 wi...` into int
```

## Root Cause

The initial regex patterns were **too greedy** and matched more than intended:

### Broken Pattern (PowerShell)

```powershell
# WRONG - Replaces entire match including comment
$modifiedContent = $originalContent -replace 'localPort: 8000 # Override', "localPort: $apiPort"
```

When applied to:

```yaml
localPort: 8000 # Override with skaffold.ps1/sh or CLI flags
```

Result:

```yaml
localPort: 8000 # <-- CORRECT, but comment is gone
```

The pattern `'localPort: 8000 # Override'` matched `localPort: 8000 # Override` literally, but the full line in the YAML was `localPort: 8000 # Override with skaffold.ps1/sh or CLI flags`, causing the replacement to only replace the matched portion and corrupt the line.

## Solution

Use **capture groups** to preserve everything except the port number itself.

### Fixed Pattern (PowerShell)

```powershell
# CORRECT - Captures and preserves whitespace and comments
$modifiedContent = $originalContent -replace '(?m)(^\s+localPort:\s+)8000(\s+#.*)?$', "`${1}$apiPort`$2"
```

**Pattern Breakdown:**

- `(?m)` - Multiline mode (^ and $ match line boundaries)
- `(^\s+localPort:\s+)` - **Capture Group 1**: Leading whitespace + "localPort:" + spaces
- `8000` - The port number to replace (literal match)
- `(\s+#.*)?` - **Capture Group 2**: Optional whitespace + comment to end of line
- `$` - End of line
- Replacement: `` `${1}$apiPort`$2 `` - Reconstruct with new port

### Fixed Pattern (Bash)

```bash
# CORRECT - Uses sed capture groups
sed -e "s/^\(\s*localPort:\s*\)8000\(.*\)$/\1$API_PORT\2/"
```

**Pattern Breakdown:**

- `^\(\s*localPort:\s*\)` - **Capture Group 1**: Start of line + whitespace + "localPort:" + spaces
- `8000` - Port number to replace
- `\(.*\)` - **Capture Group 2**: Everything else on the line (including comments)
- `$` - End of line
- Replacement: `\1$API_PORT\2` - Reconstruct with new port

## Verification

### Test Case

```yaml
Input: "    localPort: 8000 # Override with skaffold.ps1/sh or CLI flags"
Output: "    localPort: 9000 # Override with skaffold.ps1/sh or CLI flags"
```

### PowerShell Test

```powershell
$test = "    localPort: 8000 # Override with skaffold.ps1/sh or CLI flags"
$result = $test -replace '(?m)(^\s+localPort:\s+)8000(\s+#.*)?$', '${1}9000$2'
# Result: "    localPort: 9000 # Override with skaffold.ps1/sh or CLI flags"
# ✅ Whitespace preserved
# ✅ Port replaced
# ✅ Comment preserved
```

### Generated YAML Validation

```bash
# Run script and verify generated temp file
powershell -ExecutionPolicy Bypass -File .\skaffold.ps1

# In temp file, should see:
#     localPort: 8000 # Override with skaffold.ps1/sh or CLI flags
#     localPort: 5432 # Override with skaffold.ps1/sh or CLI flags
#     localPort: 6379 # Override with skaffold.ps1/sh or CLI flags
# All with proper YAML indentation and comments intact
```

## Files Modified

1. **skaffold.ps1** - Updated regex patterns with proper capture groups
2. **skaffold.sh** - Updated sed patterns with proper capture groups
3. **docs/FIX-REGEX-PORT-REPLACEMENT.md** - This documentation

## Before vs After

### Before (Broken)

```powershell
# PowerShell
$modifiedContent = $originalContent -replace 'localPort: 8000 # Override', "localPort: $apiPort"

# Bash
sed -e "s/localPort: 8000 # Override.*/localPort: $API_PORT/"
```

**Problem:**

- PowerShell: Only matches partial comment, leaves rest of line
- Bash: `.*` eats the entire comment

### After (Fixed)

```powershell
# PowerShell - Preserves structure with capture groups
$modifiedContent = $originalContent -replace '(?m)(^\s+localPort:\s+)8000(\s+#.*)?$', "`${1}$apiPort`$2"

# Bash - Preserves structure with capture groups
sed -e "s/^\(\s*localPort:\s*\)8000\(.*\)$/\1$API_PORT\2/"
```

**Benefits:**

- ✅ Preserves indentation
- ✅ Preserves comments
- ✅ Only replaces port number
- ✅ Generates valid YAML

## Testing Commands

```powershell
# Test PowerShell script
powershell -ExecutionPolicy Bypass -File .\skaffold.ps1

# Should show:
# [*] Generating temporary skaffold config with custom ports...
# No YAML parsing errors
# Skaffold builds and deploys successfully
```

```bash
# Test Bash script
./skaffold.sh

# Should show:
# [*] Generating temporary skaffold config with custom ports...
# No YAML parsing errors
# Skaffold builds and deploys successfully
```

## Key Takeaways

1. **Use capture groups** to preserve structure when doing partial replacements
2. **Test regex patterns** with sample input before applying to real files
3. **PowerShell regex** uses .NET syntax with `(?m)` for multiline mode
4. **Bash sed** uses different syntax for capture groups: `\(\)` instead of `()`
5. **YAML is whitespace-sensitive** - preserve indentation

## Status

✅ **FIXED** - Both PowerShell and Bash scripts now correctly generate temporary `skaffold.yaml` files with proper port replacements while preserving comments and structure.
