#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Enable PowerShell autocomplete and predictive IntelliSense features.

.DESCRIPTION
    This script configures PSReadLine for enhanced command-line autocomplete:
    - Predictive IntelliSense based on command history
    - Tab completion with list view
    - Smart history search with arrow keys
    - Word completion with Ctrl+Space

    The configuration is added to your PowerShell profile for persistence.

.PARAMETER Scope
    Installation scope for PSReadLine module (CurrentUser or AllUsers).
    Default: CurrentUser

.EXAMPLE
    .\enable-autocomplete.ps1
    Enable autocomplete with default settings

.EXAMPLE
    .\enable-autocomplete.ps1 -Scope AllUsers
    Enable autocomplete system-wide (requires admin)

.NOTES
    Author: EASM Team
    Requires: PowerShell 7+ recommended, PSReadLine 2.1+
#>

[CmdletBinding()]
param(
    [Parameter()]
    [ValidateSet('CurrentUser', 'AllUsers')]
    [string]$Scope = 'CurrentUser'
)

# Color output helpers
function Write-Status {
    param([string]$Message, [string]$Type = 'Info')
    $colors = @{
        'Info'    = 'Cyan'
        'Success' = 'Green'
        'Warning' = 'Yellow'
        'Error'   = 'Red'
    }
    Write-Host "[$Type] " -ForegroundColor $colors[$Type] -NoNewline
    Write-Host $Message
}

# Check PowerShell version
Write-Status "Checking PowerShell version..." -Type 'Info'
$psVersion = $PSVersionTable.PSVersion
Write-Host "  PowerShell version: $($psVersion.Major).$($psVersion.Minor).$($psVersion.Patch)"

if ($psVersion.Major -lt 5) {
    Write-Status "PowerShell 5.0+ required. Please upgrade PowerShell." -Type 'Error'
    exit 1
}

# Check and update PSReadLine module
Write-Status "Checking PSReadLine module..." -Type 'Info'
$currentModule = Get-Module PSReadLine -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1

if ($currentModule) {
    Write-Host "  Current version: $($currentModule.Version)"
} else {
    Write-Host "  PSReadLine not found"
}

# Check for latest version from PowerShell Gallery
try {
    $latestModule = Find-Module PSReadLine -ErrorAction Stop
    Write-Host "  Latest version: $($latestModule.Version)"

    if (-not $currentModule -or $currentModule.Version -lt $latestModule.Version) {
        Write-Status "Installing/updating PSReadLine to version $($latestModule.Version)..." -Type 'Info'

        try {
            Install-Module -Name PSReadLine -Force -SkipPublisherCheck -Scope $Scope -AllowClobber -ErrorAction Stop
            Write-Status "PSReadLine updated successfully!" -Type 'Success'
        } catch {
            Write-Status "Failed to install PSReadLine: $_" -Type 'Error'
            Write-Status "Continuing with existing version..." -Type 'Warning'
        }
    } else {
        Write-Status "PSReadLine is up to date" -Type 'Success'
    }
} catch {
    Write-Status "Could not check for updates: $_" -Type 'Warning'
}

# Import the latest version
Write-Status "Loading PSReadLine module..." -Type 'Info'
try {
    # Remove existing module first to avoid conflicts
    Remove-Module PSReadLine -Force -ErrorAction SilentlyContinue

    # Import the latest version
    Import-Module PSReadLine -ErrorAction Stop
    $loadedVersion = (Get-Module PSReadLine).Version
    Write-Host "  Loaded version: $loadedVersion"
} catch {
    Write-Status "Failed to load PSReadLine: $_" -Type 'Error'
    exit 1
}

# Configure PSReadLine for autocomplete
Write-Status "Configuring autocomplete features..." -Type 'Info'

try {
    # Enable predictive IntelliSense with history
    Set-PSReadLineOption -PredictionSource History
    Write-Host "  ✓ Predictive IntelliSense enabled (history-based)"

    # Set prediction view to ListView for better visibility
    Set-PSReadLineOption -PredictionViewStyle ListView
    Write-Host "  ✓ Prediction view set to ListView"

    # Enable history search cursor movement
    Set-PSReadLineOption -HistorySearchCursorMovesToEnd
    Write-Host "  ✓ History search cursor movement enabled"

    # Configure keyboard shortcuts
    Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
    Write-Host "  ✓ Up/Down arrows configured for history search"

    # Tab completion
    Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
    Write-Host "  ✓ Tab completion with menu enabled"

    # Ctrl+Spacebar for IntelliSense (using Ctrl+@ as alternative)
    try {
        Set-PSReadLineKeyHandler -Key 'Ctrl+Spacebar' -Function Complete
        Write-Host "  ✓ Ctrl+Spacebar for word completion"
    } catch {
        # Fallback to Ctrl+@ which works on most systems
        Set-PSReadLineKeyHandler -Key 'Ctrl+@' -Function Complete
        Write-Host "  ✓ Ctrl+@ for word completion (Ctrl+Spacebar alternative)"
    }

    # Enable colors for parameters and operators
    Set-PSReadLineOption -Colors @{
        Command   = 'Yellow'
        Parameter = 'Gray'
        Operator  = 'Magenta'
        Variable  = 'Green'
        String    = 'Cyan'
        Number    = 'White'
        Type      = 'DarkGray'
        Comment   = 'DarkGreen'
    }
    Write-Host "  ✓ Syntax highlighting enabled"

    Write-Status "Autocomplete configured successfully!" -Type 'Success'
} catch {
    Write-Status "Error configuring PSReadLine: $_" -Type 'Error'
    exit 1
}

# Add to PowerShell profile for persistence
Write-Status "Updating PowerShell profile..." -Type 'Info'

$profileConfig = @'

# ============================================
# PSReadLine Autocomplete Configuration
# Generated by enable-autocomplete.ps1
# ============================================

# Import PSReadLine module
Import-Module PSReadLine

# Enable predictive IntelliSense
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView

# History search
Set-PSReadLineOption -HistorySearchCursorMovesToEnd
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

# Tab completion
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete

# Ctrl+Spacebar for IntelliSense
try {
    Set-PSReadLineKeyHandler -Key 'Ctrl+Spacebar' -Function Complete
} catch {
    Set-PSReadLineKeyHandler -Key 'Ctrl+@' -Function Complete
}

# Syntax highlighting
Set-PSReadLineOption -Colors @{
    Command   = 'Yellow'
    Parameter = 'Gray'
    Operator  = 'Magenta'
    Variable  = 'Green'
    String    = 'Cyan'
    Number    = 'White'
    Type      = 'DarkGray'
    Comment   = 'DarkGreen'
}
'@

# Create profile if it doesn't exist
if (-not (Test-Path -Path $PROFILE)) {
    Write-Host "  Creating new PowerShell profile: $PROFILE"
    New-Item -ItemType File -Path $PROFILE -Force | Out-Null
}

# Check if configuration already exists
$profileContent = Get-Content -Path $PROFILE -Raw -ErrorAction SilentlyContinue

if ($profileContent -match 'PSReadLine Autocomplete Configuration') {
    Write-Status "Autocomplete configuration already exists in profile" -Type 'Warning'
    Write-Host "  Profile path: $PROFILE"

    $response = Read-Host "Do you want to update it? (Y/N)"
    if ($response -eq 'Y' -or $response -eq 'y') {
        # Remove old configuration
        $profileContent = $profileContent -replace '(?s)# ={44}.*?# ={44}\r?\n', ''
        Set-Content -Path $PROFILE -Value $profileContent.TrimEnd()
        Add-Content -Path $PROFILE -Value $profileConfig
        Write-Status "Profile updated successfully!" -Type 'Success'
    } else {
        Write-Status "Skipping profile update" -Type 'Info'
    }
} else {
    # Add configuration to profile
    Add-Content -Path $PROFILE -Value $profileConfig
    Write-Status "Profile updated successfully!" -Type 'Success'
    Write-Host "  Profile path: $PROFILE"
}

# Display usage instructions
Write-Host ""
Write-Status "Autocomplete is now enabled! 🎉" -Type 'Success'
Write-Host ""
Write-Host "Usage:" -ForegroundColor Cyan
Write-Host "  • Start typing a command and see suggestions appear"
Write-Host "  • Press Tab to cycle through completions"
Write-Host "  • Press → (right arrow) to accept inline suggestions"
Write-Host "  • Press Ctrl+Spacebar (or Ctrl+@) for word completion"
Write-Host "  • Press Up/Down arrows to search command history"
Write-Host "  • Press F2 to switch between inline/list view"
Write-Host ""
Write-Host "Examples:" -ForegroundColor Cyan
Write-Host "  Type 'git st' and press Tab → completes to 'git status'"
Write-Host "  Type 'docker' and see previous docker commands"
Write-Host "  Type 'Get-' and press Tab → shows all Get-* cmdlets"
Write-Host ""
Write-Status "Note: Changes are active in current session and will persist in new sessions" -Type 'Info'
Write-Host ""
