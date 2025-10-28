# Skaffold Port Forwarding Solution

## Problem

Skaffold does **not** support the `--port-forward-ports` CLI flag. The error received:

```
unknown flag: --port-forward-ports
See 'skaffold dev --help' for usage.
```

Additionally, Skaffold's `portForward.localPort` field in `skaffold.yaml`:

- Does NOT support template variables (e.g., `{{.API_LOCAL_PORT}}`)
- Requires integer type, parsed before template evaluation
- Cannot be overridden via CLI flags

## Solution

**Generate a temporary `skaffold.yaml` file** with port values substituted from environment variables.

### How It Works

1. **Load environment** from `skaffold.env`
2. **Read port variables**: `API_LOCAL_PORT`, `POSTGRES_LOCAL_PORT`, `REDIS_LOCAL_PORT`
3. **Generate temporary file**: `skaffold.temp.yaml` with ports substituted
4. **Run Skaffold** using `-f skaffold.temp.yaml`
5. **Cleanup** temporary file after execution

### Implementation

#### PowerShell (skaffold.ps1)

```powershell
# Read ports from environment
$apiPort = if ($env:API_LOCAL_PORT) { $env:API_LOCAL_PORT } else { "8000" }
$postgresPort = if ($env:POSTGRES_LOCAL_PORT) { $env:POSTGRES_LOCAL_PORT } else { "5432" }
$redisPort = if ($env:REDIS_LOCAL_PORT) { $env:REDIS_LOCAL_PORT } else { "6379" }

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
# Read ports from environment
API_PORT="${API_LOCAL_PORT:-8000}"
POSTGRES_PORT="${POSTGRES_LOCAL_PORT:-5432}"
REDIS_PORT="${REDIS_LOCAL_PORT:-6379}"

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

## Usage

### Configure Ports in skaffold.env

```env
# Port forwarding (local machine ports)
API_LOCAL_PORT=8000
POSTGRES_LOCAL_PORT=5432
REDIS_LOCAL_PORT=6379
```

### Run Deployment Script

**PowerShell:**

```powershell
powershell -ExecutionPolicy Bypass -File .\skaffold.ps1
```

**Bash/Linux/macOS:**

```bash
./skaffold.sh
```

The script will:

1. Load `skaffold.env`
2. Show port configuration
3. Generate temporary config with your custom ports
4. Run Skaffold
5. Clean up temporary file

## Technical Details

### Why Not Template Variables?

Skaffold's YAML parsing order:

1. **Parse YAML** → Go struct (types enforced)
2. **Unmarshal** into Skaffold config object
3. **Evaluate templates** (too late for `localPort`)

The `localPort` field is defined as `int`, not `string`, so template evaluation never occurs.

### Why Not CLI Flags?

Skaffold v2.16.1 only has:

- `--port-forward=user`: Enable/disable port forwarding
- No flag for custom port mapping

### Alternatives Considered

❌ **Template variables in YAML**: Type mismatch error
❌ **CLI port override flags**: Don't exist
❌ **YAML anchors with templates**: Still type mismatch
❌ **Profiles with different ports**: Requires multiple profiles
✅ **Generate temporary YAML**: Works perfectly

## Files Modified

- `skaffold.ps1` - PowerShell script with temp file generation
- `skaffold.sh` - Bash script with temp file generation
- `.gitignore` - Added `skaffold.temp.yaml`
- `skaffold.yaml` - Added comments marking override points

## Benefits

✅ Uses single environment file (`skaffold.env`)
✅ Ports configurable via environment variables
✅ No manual YAML editing required
✅ Works with all Skaffold commands (dev, run, debug)
✅ Temporary file automatically cleaned up
✅ Cross-platform compatible

## References

- Skaffold Docs: https://skaffold.dev/docs/references/yaml/
- Port Forwarding: https://skaffold.dev/docs/pipeline-stages/port-forwarding/
- Template Support: https://skaffold.dev/docs/environment/templating/
