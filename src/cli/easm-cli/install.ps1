# EASM CLI Installation Script (PowerShell)

param(
    [switch]$Global,
    [switch]$Uninstall
)

$ScriptDir = $PSScriptRoot
$ProjectRoot = Split-Path (Split-Path (Split-Path $ScriptDir -Parent) -Parent) -Parent

function Write-SuccessMessage {
    Write-Host "✓ " -ForegroundColor Green -NoNewline
    Write-Host $args
}

function Write-InfoMessage {
    Write-Host "ℹ " -ForegroundColor Cyan -NoNewline
    Write-Host $args
}

function Write-WarningMessage {
    Write-Host "⚠ " -ForegroundColor Yellow -NoNewline
    Write-Host $args
}

function Write-ErrorMessage {
    Write-Host "✗ " -ForegroundColor Red -NoNewline
    Write-Host $args
}

Write-Host "`n═══════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  EASM CLI Installation" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════`n" -ForegroundColor Cyan

# Check Python
Write-InfoMessage "Checking Python installation..."
try {
    $pythonVersion = python --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-SuccessMessage "Python found: $pythonVersion"
    } else {
        throw "Python not found"
    }
} catch {
    Write-ErrorMessage "Python is not installed or not in PATH"
    Write-Host "`nPlease install Python 3.8+ from https://www.python.org/"
    exit 1
}

if ($Uninstall) {
    Write-InfoMessage "Uninstalling EASM CLI..."

    # Remove from user PATH (both old and new locations)
    $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
    $projectRoot = Split-Path (Split-Path (Split-Path $ScriptDir -Parent) -Parent) -Parent
    $pathsToRemove = @(
        $ScriptDir,
        (Join-Path $projectRoot "cli")  # Old location
    )
    $pathChanged = $false

    foreach ($pathToRemove in $pathsToRemove) {
        if ($userPath -like "*$pathToRemove*") {
            $userPath = ($userPath.Split(';') | Where-Object {
                $_ -ne $pathToRemove
            }) -join ';'
            $pathChanged = $true
            Write-InfoMessage "Removing: $pathToRemove"
        }
    }

    if ($pathChanged) {
        [Environment]::SetEnvironmentVariable("Path", $userPath, "User")
        Write-SuccessMessage "Removed from PATH"
    } else {
        Write-InfoMessage "Not found in PATH"
    }

    # Remove alias from PowerShell profile
    if (Test-Path $PROFILE) {
        $profileContent = Get-Content $PROFILE -Raw -ErrorAction SilentlyContinue
        if ($profileContent -match "# EASM CLI") {
            # Remove the EASM CLI section
            $lines = Get-Content $PROFILE
            $newLines = @()
            $skip = $false
            foreach ($line in $lines) {
                if ($line -match "^# EASM CLI") {
                    $skip = $true
                } elseif ($line -match "^# End EASM CLI") {
                    $skip = $false
                    continue
                } elseif (-not $skip) {
                    $newLines += $line
                }
            }
            $newLines | Set-Content $PROFILE
            Write-SuccessMessage "Removed from PowerShell profile"
        } else {
            Write-InfoMessage "Alias not found in profile"
        }
    }

    Write-SuccessMessage "EASM CLI uninstalled"
    Write-InfoMessage "Please restart your terminal for changes to take effect"
    Write-Host ""
    Write-InfoMessage "Note: If 'easm' still works in THIS session,"
    Write-Host "       it's a session function. Close this terminal or run:"
    Write-Host "       Remove-Item Function:\easm" -ForegroundColor Gray
    exit 0
}Write-InfoMessage "Installation type: $(if ($Global) { 'Global (requires admin)' } else { 'User' })"

# Option 1: Add to PATH
Write-InfoMessage "Adding CLI directory to PATH..."
try {
    $scope = if ($Global) { "Machine" } else { "User" }
    $currentPath = [Environment]::GetEnvironmentVariable("Path", $scope)

    if ($currentPath -notlike "*$ScriptDir*") {
        $newPath = "$currentPath;$ScriptDir"
        [Environment]::SetEnvironmentVariable("Path", $newPath, $scope)
        Write-SuccessMessage "Added to PATH ($scope)"
    } else {
        Write-InfoMessage "Already in PATH"
    }
} catch {
    Write-WarningMessage "Could not modify PATH: $_"
    Write-InfoMessage "You can manually add this to your PATH: $ScriptDir"
}

# Option 2: Create PowerShell alias
Write-InfoMessage "Creating PowerShell alias..."
try {
    if (-not (Test-Path $PROFILE)) {
        New-Item -Path $PROFILE -ItemType File -Force | Out-Null
    }

    $aliasCode = @"

# EASM CLI
function easm {
    python "$ScriptDir\easm.py" `$args
}
# End EASM CLI
"@

    $profileContent = Get-Content $PROFILE -Raw -ErrorAction SilentlyContinue
    if ($profileContent -notlike "*# EASM CLI*") {
        Add-Content -Path $PROFILE -Value $aliasCode
        Write-SuccessMessage "Added 'easm' function to PowerShell profile"
    } else {
        Write-InfoMessage "Alias already exists in profile"
    }
} catch {
    Write-WarningMessage "Could not modify PowerShell profile: $_"
}

Write-Host "`n═══════════════════════════════════════" -ForegroundColor Green
Write-Host "  Installation Complete!" -ForegroundColor Green
Write-Host "═══════════════════════════════════════`n" -ForegroundColor Green

Write-Host "You can now use the CLI in the following ways:`n"
Write-Host "  1. Direct:        " -NoNewline
Write-Host "python src\cli\easm-cli\easm.py <command>" -ForegroundColor Yellow
Write-Host "  2. Batch wrapper: " -NoNewline
Write-Host ".\src\cli\easm-cli\easm.bat <command>" -ForegroundColor Yellow
Write-Host "  3. Function:      " -NoNewline
Write-Host "easm <command>" -ForegroundColor Yellow -NoNewline
Write-Host " (reload profile first)"

Write-Host "`n" -NoNewline
Write-WarningMessage "The 'easm' function won't work in THIS terminal session"
Write-Host ""
Write-Host "To use the 'easm' function, do ONE of the following:"
Write-Host "  A. Reload your profile:  " -NoNewline
Write-Host ". `$PROFILE" -ForegroundColor Green
Write-Host "  B. Open a new terminal" -ForegroundColor Green

Write-Host "`nExamples (after reloading):"
Write-Host "  easm dev start" -ForegroundColor Cyan
Write-Host "  easm --help" -ForegroundColor Cyan
Write-Host "  easm dev logs -f" -ForegroundColor Cyan

Write-Host "`nFor immediate use (no reload needed):"
Write-Host "  python src\cli\easm-cli\easm.py dev start" -ForegroundColor Yellow
Write-Host ""
