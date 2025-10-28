# Enhanced skaffold.ps1 and skaffold.sh Scripts

## Summary of Changes

The existing `skaffold.ps1` and `skaffold.sh` deployment scripts have been enhanced to support **dynamic port forwarding** from the `skaffold.env` file.

---

## What Was Changed

### 1. Environment File Loading

**Before:**

- Only loaded `.env` file
- Used `Set-Item` (PowerShell) which could cause issues

**After:**

- Prioritizes `skaffold.env` (new standard)
- Falls back to `.env` if `skaffold.env` not found
- Uses `[Environment]::SetEnvironmentVariable()` for better reliability

### 2. Port Configuration

**NEW Feature:** Automatic port forwarding based on environment variables

The scripts now:

1. Read `API_LOCAL_PORT`, `POSTGRES_LOCAL_PORT`, `REDIS_LOCAL_PORT` from environment
2. Use defaults (8000, 5432, 6379) if variables not set
3. Display the port configuration before deployment
4. Pass ports to Skaffold via `--port-forward-ports` CLI flag

### 3. All Deployment Modes Support Custom Ports

Every deployment option now uses environment-based ports:

- ✅ Development mode (`skaffold dev`)
- ✅ One-time deployment (`skaffold run`)
- ✅ Development profile (`--profile=dev`)
- ✅ Production profile (`--profile=prod`)

---

## How It Works

### PowerShell (`skaffold.ps1`)

```powershell
# 1. Load environment from skaffold.env
Get-Content skaffold.env | ForEach-Object {
    # Parse KEY=VALUE and set as environment variable
    [Environment]::SetEnvironmentVariable($name, $value, 'Process')
}

# 2. Get port values or use defaults
$apiPort = if ($env:API_LOCAL_PORT) { $env:API_LOCAL_PORT } else { "8000" }

# 3. Build CLI arguments
$portForwardArgs = "${apiPort}:8000,${postgresPort}:5432,${redisPort}:6379"

# 4. Pass to Skaffold
skaffold dev --port-forward-ports=$portForwardArgs
```

### Bash (`skaffold.sh`)

```bash
# 1. Load environment from skaffold.env
set -a
source skaffold.env
set +a

# 2. Get port values or use defaults
API_PORT="${API_LOCAL_PORT:-8000}"

# 3. Build CLI arguments
PORT_FORWARD_ARGS="${API_PORT}:8000,${POSTGRES_PORT}:5432,${REDIS_PORT}:6379"

# 4. Pass to Skaffold
skaffold dev --port-forward-ports="$PORT_FORWARD_ARGS"
```

---

## Usage

### Step 1: Configure Ports

Edit `skaffold.env`:

```bash
# Change these if you have port conflicts
API_LOCAL_PORT=8080
POSTGRES_LOCAL_PORT=5433
REDIS_LOCAL_PORT=6380
```

### Step 2: Run the Script

**PowerShell:**

```powershell
.\skaffold.ps1
```

**Bash:**

```bash
./skaffold.sh
```

### Step 3: See Port Configuration

The script will display:

```
🔌 Port Forwarding Configuration:
   API:        localhost:8080 → container:8000
   PostgreSQL: localhost:5433 → container:5432
   Redis:      localhost:6380 → container:6379
```

### Step 4: Choose Deployment Mode

```
Choose deployment mode:
  1) Development (skaffold dev - with hot reload)
  2) One-time deployment (skaffold run)
  3) Development profile (no persistence)
  4) Production profile (with persistence and scaling)

Enter your choice (1-4):
```

---

## Benefits

### ✅ Single Configuration Source

- All environment variables in `skaffold.env`
- No need to edit multiple files

### ✅ Automatic Port Handling

- Script reads ports from environment
- Applies them via CLI flags automatically
- No manual command construction needed

### ✅ Visual Confirmation

- See which ports will be used before deployment
- Prevents confusion and errors

### ✅ Works with All Modes

- Development, production, profiles - all support custom ports
- Consistent behavior across all deployment types

### ✅ Backward Compatible

- Still works if you don't set port variables (uses defaults)
- Falls back to `.env` if `skaffold.env` doesn't exist

---

## Technical Details

### Why CLI Flags Instead of YAML?

As explained in `docs/SKAFFOLD-LOCALPORT-COMPLETE-ANALYSIS.md`:

- ❌ `skaffold.yaml` cannot use template variables in `portForward.localPort`
- ❌ This is a Skaffold architectural limitation (field is `int`, not `string`)
- ✅ CLI flags (`--port-forward-ports`) is the official workaround
- ✅ Shell scripts expand environment variables before passing to Skaffold

### Port Mapping Format

```
<local-port>:<container-port>
```

Example:

```bash
--port-forward-ports="8080:8000,5433:5432,6380:6379"
#                      ^^^^ ^^^^  ^^^^ ^^^^  ^^^^ ^^^^
#                      |    |     |    |     |    |
#                      |    |     |    |     |    └─ Redis container port (fixed)
#                      |    |     |    |     └────── Redis local port (from env)
#                      |    |     |    └──────────── PostgreSQL container port (fixed)
#                      |    |     └───────────────── PostgreSQL local port (from env)
#                      |    └─────────────────────── API container port (fixed)
#                      └──────────────────────────── API local port (from env)
```

**Container ports are always fixed** (8000, 5432, 6379) - these are the ports services listen on inside containers.

**Local ports are configurable** - these are the ports you use on your machine to access the services.

---

## Files Changed

1. ✅ `skaffold.ps1` - Enhanced with port forwarding
2. ✅ `skaffold.sh` - Enhanced with port forwarding
3. ✅ `README.md` - Updated with new usage instructions
4. ❌ `skdev.ps1` - Removed (functionality merged into `skaffold.ps1`)
5. ❌ `skdev.sh` - Removed (functionality merged into `skaffold.sh`)

---

## Example Session

```powershell
PS> .\skaffold.ps1

=== EASM Skaffold Deployment Script ===

[*] Loading environment variables from skaffold.env...
  [+] Set DEBUG
  [+] Set SECRET_KEY
  [+] Set ALLOWED_HOSTS
  [+] Set POSTGRES_DB
  ... (all variables loaded)

[OK] Kubernetes cluster is running

[*] Updating Helm repositories...
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "bitnami" chart repository

🔌 Port Forwarding Configuration:
   API:        localhost:8080 → container:8000
   PostgreSQL: localhost:5433 → container:5432
   Redis:      localhost:6380 → container:6379

Choose deployment mode:
  1) Development (skaffold dev - with hot reload)
  2) One-time deployment (skaffold run)
  3) Development profile (no persistence)
  4) Production profile (with persistence and scaling)

Enter your choice (1-4): 1

[>>] Starting Skaffold in development mode...
[*] Press Ctrl+C to stop

Generating tags...
 - easm-api -> easm-api:be06eff
...
Port forwarding service/easm-api in namespace easm-rnd, remote port 8000 -> 127.0.0.1:8080
Port forwarding service/postgresql in namespace easm-rnd, remote port 5432 -> 127.0.0.1:5433
Port forwarding service/redis-master in namespace easm-rnd, remote port 6379 -> 127.0.0.1:6380
...
```

---

## Conclusion

The enhanced scripts provide a **seamless way to use environment-based port configuration** with Skaffold, solving the technical limitation that `skaffold.yaml` cannot directly read environment variables for port forwarding.

**Key Takeaway:** You can now configure all ports in `skaffold.env` and the scripts will handle everything automatically! 🎯
