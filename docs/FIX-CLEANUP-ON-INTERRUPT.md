# Fix: Cleanup Temporary Files on Ctrl+C

## Problem

When pressing **Ctrl+C** to stop `skaffold dev`, the temporary files (`skaffold.temp.yaml` and `skaffold-values.yaml`) were not being cleaned up because the script's normal exit path was interrupted.

## Root Cause

The cleanup code was placed **after** the `skaffold dev` command:

```powershell
# BEFORE (broken)
skaffold dev -f $tempSkaffoldFile
Remove-Item $tempSkaffoldFile -ErrorAction SilentlyContinue  # ❌ Never executed on Ctrl+C
```

When you press Ctrl+C:

1. Skaffold receives the interrupt signal and stops
2. Control returns to the script
3. But the script itself also receives Ctrl+C and terminates immediately
4. The cleanup line never executes

## Solution

Use **trap handlers** (signal handlers) to ensure cleanup runs on any exit condition.

### PowerShell Solution

```powershell
# Cleanup function
function Cleanup-TempFiles {
    Write-Host ""
    Write-Host "[*] Cleaning up temporary files..." -ForegroundColor Yellow
    Remove-Item "skaffold.temp.yaml" -ErrorAction SilentlyContinue
    Remove-Item "skaffold-values.yaml" -ErrorAction SilentlyContinue
}

# Register cleanup on script exit (including Ctrl+C)
trap {
    Cleanup-TempFiles
    break
}
```

The `trap` block catches **any terminating error** including Ctrl+C (which PowerShell treats as a terminating exception).

### Bash Solution

```bash
# Cleanup function
cleanup_temp_files() {
    echo ""
    echo "[*] Cleaning up temporary files..."
    rm -f "skaffold.temp.yaml"
    rm -f "skaffold-values.yaml"
}

# Register cleanup on script exit (including Ctrl+C)
trap cleanup_temp_files EXIT INT TERM
```

The `trap` command registers the cleanup function for:

- `EXIT` - Normal script exit
- `INT` - Interrupt signal (Ctrl+C)
- `TERM` - Termination signal

## How It Works

### PowerShell Flow

```
User presses Ctrl+C
    ↓
PowerShell raises TerminatingError
    ↓
trap { } block executes
    ↓
Cleanup-TempFiles function runs
    ↓
Files deleted
    ↓
Script exits cleanly
```

### Bash Flow

```
User presses Ctrl+C
    ↓
Shell receives SIGINT signal
    ↓
trap handler executes cleanup_temp_files
    ↓
Files deleted
    ↓
Script exits with signal status
```

## Benefits

✅ **Cleanup on normal exit** - Files removed when script completes
✅ **Cleanup on Ctrl+C** - Files removed when interrupted
✅ **Cleanup on errors** - Files removed on script failure
✅ **Clean workspace** - No leftover temporary files
✅ **Consistent behavior** - Works the same in PowerShell and Bash

## Files Modified

1. **skaffold.ps1**

   - Added `Cleanup-TempFiles` function at the top
   - Added `trap { }` block to register cleanup
   - Replaced inline `Remove-Item` calls with `Cleanup-TempFiles`

2. **skaffold.sh**
   - Added `cleanup_temp_files` function at the top
   - Added `trap cleanup_temp_files EXIT INT TERM`
   - Removed inline `rm -f` calls (trap handles it)

## Testing

### Test Normal Exit

```powershell
# Run script and choose option 2 (one-time deployment)
.\skaffold.ps1

# After completion, verify files are deleted:
ls skaffold.temp.yaml, skaffold-values.yaml
# Should show: "Cannot find path..."
```

### Test Ctrl+C Interrupt

```powershell
# Run script and choose option 1 (dev mode)
.\skaffold.ps1

# Press Ctrl+C after a few seconds
# Should see: "[*] Cleaning up temporary files..."

# Verify files are deleted:
ls skaffold.temp.yaml, skaffold-values.yaml
# Should show: "Cannot find path..."
```

### Test Error Exit

```powershell
# Run script and choose invalid option
.\skaffold.ps1
# Enter: 5

# Should show cleanup message
# Verify files are deleted
```

## Technical Details

### PowerShell trap

PowerShell's `trap` is a **statement** that catches exceptions in the current scope:

```powershell
trap {
    # Handle exception
    Cleanup-TempFiles

    # break - Exit script
    # continue - Resume execution (not recommended for cleanup)
    break
}
```

**Important:** Use `break` not `continue` to ensure script terminates after cleanup.

### Bash trap

Bash's `trap` is a **command** that registers signal handlers:

```bash
trap 'commands' SIGNALS
```

Common signals:

- `EXIT` (0) - Executed on any exit
- `INT` (2) - Ctrl+C
- `TERM` (15) - Kill signal
- `ERR` - Command failure (requires `set -E`)

## PowerShell: Combined trap + try-finally Approach

The script uses **both** mechanisms for robust cleanup:

**1. Global trap handler** (catches script-level interrupts):

```powershell
trap {
    Cleanup-TempFiles
    break
}
```

**2. try-finally blocks** (ensures cleanup for each skaffold command):

```powershell
switch ($choice) {
    "1" {
        try {
            skaffold dev -f $tempSkaffoldFile
        }
        finally {
            Cleanup-TempFiles  # Runs even on Ctrl+C
        }
    }
}
```

**Why both?**

- `trap` catches script-level errors and terminations
- `try-finally` ensures cleanup runs when Skaffold exits (including Ctrl+C)
- Together they provide comprehensive coverage

This **does work** with interactive commands like `skaffold dev` - the `finally` block executes after Skaffold is terminated by Ctrl+C.

## Common Pitfalls

❌ **Using exit in trap** - Can cause infinite loop
❌ **Not using -f flag in rm** - Fails if file doesn't exist
❌ **Forgetting ErrorAction in PowerShell** - Shows errors for missing files
❌ **Using continue in trap** - Script continues after Ctrl+C

## Best Practices

✅ Use function for cleanup code (DRY principle)
✅ Register trap/handler early in script
✅ Use `-ErrorAction SilentlyContinue` / `-f` to ignore missing files
✅ Show cleanup message to user
✅ Keep cleanup code simple and fast

## Status

✅ **FIXED** - Both PowerShell and Bash scripts now clean up temporary files on normal exit, Ctrl+C, and errors.
