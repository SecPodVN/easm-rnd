# Fix: Unknown Flag --port-forward-ports

## Issue

When running `skaffold.ps1` or `skaffold.sh` and choosing option 1 (Development mode), the following error occurred:

```
unknown flag: --port-forward-ports
See 'skaffold dev --help' for usage.
```

## Root Cause

The previous implementation incorrectly assumed Skaffold supported a `--port-forward-ports` CLI flag for overriding port forwarding configuration. **This flag does not exist in Skaffold v2.16.1.**

Investigation revealed:

- Skaffold's `--port-forward` flag only controls **whether** to enable port forwarding (values: `off`, `user`, `services`, `debug`, `pods`)
- There is **no CLI flag** to specify custom port mappings
- The `portForward.localPort` field in `skaffold.yaml` cannot use template variables due to type constraints (requires `int`, not `string`)

## Solution

**Generate a temporary `skaffold.yaml` file** with port values substituted from environment variables before running Skaffold.

### How It Works

1. Load environment variables from `skaffold.env`
2. Read port configuration: `API_LOCAL_PORT`, `POSTGRES_LOCAL_PORT`, `REDIS_LOCAL_PORT`
3. Create `skaffold.temp.yaml` by replacing localPort values in the original `skaffold.yaml`
4. Run Skaffold with `-f skaffold.temp.yaml`
5. Clean up temporary file after execution completes

### Implementation Details

#### PowerShell (skaffold.ps1)

```powershell
# Generate temporary config
$tempSkaffoldFile = "skaffold.temp.yaml"
$originalContent = Get-Content "skaffold.yaml" -Raw
$modifiedContent = $originalContent -replace 'localPort: 8000 # Override', "localPort: $apiPort"
$modifiedContent = $modifiedContent -replace 'localPort: 5432 # Override', "localPort: $postgresPort"
$modifiedContent = $modifiedContent -replace 'localPort: 6379 # Override', "localPort: $redisPort"
$modifiedContent | Set-Content $tempSkaffoldFile

# Run with temporary file
skaffold dev -f $tempSkaffoldFile

# Cleanup
Remove-Item $tempSkaffoldFile -ErrorAction SilentlyContinue
```

#### Bash (skaffold.sh)

```bash
# Generate temporary config
TEMP_SKAFFOLD_FILE="skaffold.temp.yaml"
sed -e "s/localPort: 8000 # Override.*/localPort: $API_PORT/" \
    -e "s/localPort: 5432 # Override.*/localPort: $POSTGRES_PORT/" \
    -e "s/localPort: 6379 # Override.*/localPort: $REDIS_PORT/" \
    skaffold.yaml > "$TEMP_SKAFFOLD_FILE"

# Run with temporary file
skaffold dev -f "$TEMP_SKAFFOLD_FILE"

# Cleanup
rm -f "$TEMP_SKAFFOLD_FILE"
```

## Files Modified

1. **skaffold.ps1** - Replaced invalid `--port-forward-ports` flag with temp file generation
2. **skaffold.sh** - Same fix for Bash version
3. **.gitignore** - Added `skaffold.temp.yaml` to ignore temporary files
4. **README.md** - Updated documentation to reflect correct approach
5. **docs/SKAFFOLD-PORT-FORWARDING-SOLUTION.md** - New comprehensive documentation

## Testing

```powershell
# Test PowerShell script
powershell -ExecutionPolicy Bypass -File .\skaffold.ps1

# Output shows:
# ✅ Loads 26 environment variables from skaffold.env
# ✅ Shows port configuration
# ✅ Generates temporary skaffold.temp.yaml
# ✅ Presents deployment options
# ✅ Runs Skaffold without errors
```

## Benefits

✅ **Works correctly** - No more "unknown flag" errors
✅ **Configurable ports** - Via `skaffold.env` variables
✅ **Automatic cleanup** - Temporary file removed after use
✅ **Cross-platform** - Both PowerShell and Bash versions
✅ **Single source of truth** - All config in `skaffold.env`

## Previous Attempts (Failed)

❌ **CLI flag `--port-forward-ports`** - Flag doesn't exist
❌ **Template variables in localPort** - Type mismatch (int vs string)
❌ **YAML anchors with templates** - Still requires int type
❌ **atoi function in templates** - Evaluated too late in parsing

## Verification

```bash
# Check available port-related flags
skaffold dev --help | grep port

# Output:
#   --port-forward=user: Port-forward exposes service ports...
#   (No --port-forward-ports flag exists)
```

## Related Documentation

- `docs/SKAFFOLD-PORT-FORWARDING-SOLUTION.md` - Comprehensive technical explanation
- `docs/SKAFFOLD-LOCALPORT-COMPLETE-ANALYSIS.md` - Research on template variable limitations
- `docs/ENHANCED-SKAFFOLD-SCRIPTS.md` - Previous (incorrect) approach documentation

## Lessons Learned

1. **Always verify CLI flags exist** before using them in scripts
2. **Skaffold's template system has limitations** - not all fields support templates
3. **File generation** is a reliable workaround for configuration limitations
4. **Test assumptions** - don't rely on incomplete documentation or AI hallucinations

## Status

✅ **FIXED** - Both PowerShell and Bash scripts now work correctly with custom ports from environment variables.
