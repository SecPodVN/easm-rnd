#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Build and push EASM Helm charts to GitHub Container Registry (GHCR)

.DESCRIPTION
    This script builds and publishes EASM Helm charts to GHCR.
    Auto-discovers charts from ./src/charts directory.

.PARAMETER Chart
    Which chart(s) to build: all, api, web-portal, frontend (default: all)

.PARAMETER Push
    Push the chart to GHCR after packaging

.PARAMETER Login
    Login to GHCR before pushing

.PARAMETER Token
    GitHub PAT for GHCR authentication (or set GITHUB_TOKEN in .env)

.PARAMETER Registry
    OCI Registry URL (default: ghcr.io, or GHCR_REGISTRY from .env)

.PARAMETER Owner
    GitHub repository owner (default: SecPod-Git, or GHCR_OWNER from .env)

.PARAMETER Token
    GitHub PAT for GHCR authentication (or GITHUB_TOKEN from .env)

.EXAMPLE
    .\build-chart.ps1 -Chart api -Push -Login
    .\build-chart.ps1 -Chart all -Push -Login -Owner "myorg" -Token "ghp_xxxxx"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string[]]$Chart = @("all"),
    [Parameter(Mandatory=$false)]
    [switch]$Push,
    [Parameter(Mandatory=$false)]
    [switch]$Login,
    [Parameter(Mandatory=$false)]
    [string]$Token,
    [Parameter(Mandatory=$false)]
    [string]$Registry,
    [Parameter(Mandatory=$false)]
    [string]$Owner,
    [Parameter(Mandatory=$false)]
    [switch]$Help
)

#region Configuration
$ErrorActionPreference = 'Stop'
$Script:Config = @{
    ChartsDir   = "./src/charts"
    PackageDir  = "./.build/chart"
    EnvFile     = "./.env"
    AliasPrefix = "easm-"
}
#endregion

#region Helper Functions
function Write-ColorMessage {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message,
        [Parameter(Mandatory=$false)]
        [ValidateSet('Success', 'Info', 'Warning', 'Error', 'Header')]
        [string]$Type = 'Info'
    )
    $config = @{
        Success = @{ Prefix = '✓'; Color = 'Green' }
        Info    = @{ Prefix = 'ℹ'; Color = 'Cyan' }
        Warning = @{ Prefix = '⚠'; Color = 'Yellow' }
        Error   = @{ Prefix = '✗'; Color = 'Red' }
        Header  = @{ Prefix = ''; Color = 'Yellow' }
    }
    $settings = $config[$Type]
    if ($Type -eq 'Header') {
        Write-Host "`n========================================" -ForegroundColor $settings.Color
        Write-Host " $Message" -ForegroundColor $settings.Color
        Write-Host "========================================`n" -ForegroundColor $settings.Color
    } else {
        Write-Host "$($settings.Prefix) $Message" -ForegroundColor $settings.Color
    }
}

function Get-EnvConfig {
    [CmdletBinding()]
    param([Parameter(Mandatory=$true)][string]$FilePath)
    $config = @{}
    if (-not (Test-Path $FilePath)) { return $config }
    try {
        Get-Content $FilePath -ErrorAction Stop | ForEach-Object {
            $line = $_.Trim()
            if ($line -match '^\s*#|^\s*$') { return }
            if ($line -match '^([^=]+)=(.*)$') {
                $key = $Matches[1].Trim()
                $value = $Matches[2].Trim() -replace '^["'']|["'']$', ''
                $config[$key] = $value
            }
        }
    } catch {
        Write-ColorMessage "Warning: Could not read .env file: $_" -Type Warning
    }
    return $config
}

function Get-ChartMapping {
    [CmdletBinding()]
    param([Parameter(Mandatory=$true)][string]$ChartsDirectory)
    if (-not (Test-Path $ChartsDirectory)) {
        Write-ColorMessage "Charts directory not found: $ChartsDirectory" -Type Warning
        return @{}
    }
    $mapping = @{}
    Get-ChildItem -Path $ChartsDirectory -Directory -ErrorAction SilentlyContinue |
        Where-Object { Test-Path (Join-Path $_.FullName "Chart.yaml") } |
        ForEach-Object {
            $alias = $_.Name -replace "^$($Script:Config.AliasPrefix)", ''
            $mapping[$alias] = @{
                Name = $_.Name
                Path = (Resolve-Path $_.FullName -Relative)
            }
        }
    return $mapping
}

function Get-HelmExecutable {
    [CmdletBinding()]
    param()
    # Common Helm installation locations by OS
    $helmLocations = @(
        'helm'  # In PATH
    )
    # macOS specific locations
    if ($IsMacOS -or $PSVersionTable.Platform -eq 'Unix') {
        $helmLocations += @(
            "$HOME/.rd/bin/helm"           # Rancher Desktop (macOS)
            '/usr/local/bin/helm'          # Homebrew
            '/opt/homebrew/bin/helm'       # Homebrew (Apple Silicon)
            "$HOME/.local/bin/helm"        # User local
            '/usr/bin/helm'                # System
        )
    }
    # Windows specific locations
    if ($IsWindows -or $PSVersionTable.Platform -eq 'Win32NT' -or (-not $PSVersionTable.Platform)) {
        $helmLocations += @(
            "$env:LOCALAPPDATA\Programs\Rancher Desktop\resources\resources\win32\bin\helm.exe"
            "$env:ProgramFiles\Rancher Desktop\resources\resources\win32\bin\helm.exe"
            "$env:ChocolateyInstall\bin\helm.exe"
            "$env:ProgramFiles\helm\helm.exe"
        )
    }
    # Linux specific locations
    if ($IsLinux -or ($PSVersionTable.Platform -eq 'Unix' -and -not $IsMacOS)) {
        $helmLocations += @(
            "$HOME/.rd/bin/helm"           # Rancher Desktop (Linux)
            '/usr/local/bin/helm'          # Standard location
            '/usr/bin/helm'                # System package
            "$HOME/.local/bin/helm"        # User local
            '/snap/bin/helm'               # Snap package
        )
    }
    # Check each location
    foreach ($location in $helmLocations) {
        $expandedPath = $ExecutionContext.InvokeCommand.ExpandString($location)
        # Try as command first (for PATH)
        if ($location -eq 'helm') {
            try {
                $null = & $location version --short 2>&1
                if ($LASTEXITCODE -eq 0) {
                    return $location
                }
            } catch {
                continue
            }
        }
        # Try as file path (suppress all errors)
        try {
            if (Test-Path $expandedPath -ErrorAction SilentlyContinue) {
                $null = & $expandedPath version --short 2>&1
                if ($LASTEXITCODE -eq 0) {
                    return $expandedPath
                }
            }
        } catch {
            continue
        }
    }
    return $null
}

function Get-ChartVersion {
    [CmdletBinding()]
    param([Parameter(Mandatory=$true)][string]$ChartFile)
    $content = Get-Content $ChartFile -Raw -ErrorAction Stop
    if ($content -match '(?m)^version:\s*(.+)$') {
        return $Matches[1].Trim()
    }
    throw "Version not found in $ChartFile"
}

function Invoke-HelmLogin {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)][string]$Registry,
        [Parameter(Mandatory=$true)][string]$Token,
        [Parameter(Mandatory=$true)][string]$HelmPath
    )
    try {
        $Token | & $HelmPath registry login $Registry --username $env:USERNAME --password-stdin 2>&1 | Out-Null
        if ($LASTEXITCODE -ne 0) {
            throw "Helm login returned exit code $LASTEXITCODE"
        }
        Write-ColorMessage "Successfully logged in to $Registry" -Type Success
        return $true
    } catch {
        Write-ColorMessage "Failed to login to ${Registry}: $_" -Type Error
        Write-ColorMessage "Make sure your token has 'write:packages' scope" -Type Info
        return $false
    }
}

function Invoke-ChartPackage {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)][string]$ChartPath,
        [Parameter(Mandatory=$true)][string]$DestinationDir,
        [Parameter(Mandatory=$true)][string]$HelmPath
    )
    $output = & $HelmPath package $ChartPath --destination $DestinationDir 2>&1
    if ($LASTEXITCODE -eq 0) {
        return @{ Success = $true; Output = $output }
    }
    return @{ Success = $false; Error = $output }
}

function Invoke-ChartPush {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)][string]$Package,
        [Parameter(Mandatory=$true)][string]$Registry,
        [Parameter(Mandatory=$true)][string]$Owner,
        [Parameter(Mandatory=$true)][string]$HelmPath
    )
    $ociUrl = "oci://${Registry}/${Owner}"
    $output = & $HelmPath push $Package $ociUrl 2>&1
    if ($LASTEXITCODE -eq 0) {
        return @{ Success = $true; Output = $output }
    }
    return @{ Success = $false; Error = $output }
}

function Show-Summary {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)][array]$Results,
        [Parameter(Mandatory=$true)][string]$Registry,
        [Parameter(Mandatory=$true)][string]$Owner,
        [Parameter(Mandatory=$false)][bool]$PushEnabled = $false
    )
    Write-ColorMessage "Build Summary" -Type Header
    Write-Host "Total charts processed: $($Results.Count)" -ForegroundColor Cyan
    Write-Host ""
    foreach ($result in $Results) {
        Write-Host "Chart: $($result.Chart)" -ForegroundColor White
        Write-Host "  Version: $(if ($result.Version) { $result.Version } else { 'N/A' })" -ForegroundColor Cyan
        Write-Host "  Package: $(if ($result.Package) { $result.Package } else { 'N/A' })" -ForegroundColor Cyan
        Write-Host "  Status:  " -NoNewline
        switch ($result.Status) {
            'Pushed' {
                Write-Host "$_ ✓" -ForegroundColor Green
                Write-Host "  Registry: $($result.Registry)" -ForegroundColor Cyan
            }
            'Packaged' { Write-Host "$_" -ForegroundColor Yellow }
            'Failed' {
                Write-Host "$_ ✗" -ForegroundColor Red
                if ($result.Error) { Write-Host "  Error: $($result.Error)" -ForegroundColor Red }
            }
            default {
                Write-Host "$_" -ForegroundColor Yellow
                if ($result.Error) { Write-Host "  Error: $($result.Error)" -ForegroundColor Red }
            }
        }
        Write-Host ""
    }
    $pushedCharts = $Results | Where-Object { $_.Status -eq 'Pushed' }
    if ($pushedCharts.Count -gt 0) {
        Write-ColorMessage "Installation Instructions" -Type Header
        foreach ($result in $pushedCharts) {
            $chartName = $result.Chart
            $chartVersion = $result.Version
            Write-Host "[$chartName]" -ForegroundColor Yellow
            Write-Host "  helm pull oci://${Registry}/${Owner}/${chartName} --version ${chartVersion}" -ForegroundColor Gray
            Write-Host "  helm install ${chartName} oci://${Registry}/${Owner}/${chartName} --version ${chartVersion}" -ForegroundColor Gray
            Write-Host ""
        }
    }
    if (-not $PushEnabled) {
        Write-ColorMessage "To push charts to GHCR, run with -Push -Login flags" -Type Info
        Write-Host "  .\build-chart.ps1 -Chart all -Push -Login`n" -ForegroundColor Gray
    }
    $successCount = ($Results | Where-Object { $_.Status -in @('Pushed', 'Packaged') }).Count
    $failCount = ($Results | Where-Object { $_.Status -eq 'Failed' }).Count
    if ($failCount -eq 0) {
        Write-ColorMessage "All charts processed successfully! ($successCount/$($Results.Count))" -Type Success
    } else {
        Write-ColorMessage "Completed with errors: $successCount succeeded, $failCount failed" -Type Warning
    }
    Write-Host ""
}

function Show-Help {
    $helpFile = Join-Path $PSScriptRoot "build-chart-help.md"
    if (Test-Path $helpFile) {
        Get-Content $helpFile
    } else {
        Write-Host "See: tools/build-chart-help.md for detailed help" -ForegroundColor Cyan
    }
}
#endregion

#region Main Script
try {
    if ($Help) {
        Show-Help
        exit 0
    }

    # Set default values if not provided
    if ([string]::IsNullOrEmpty($Registry)) {
        $Registry = "ghcr.io"
    }
    if ([string]::IsNullOrEmpty($Owner)) {
        $Owner = "SecPod-Git"
    }

    # Load configuration from .env file
    $envConfig = Get-EnvConfig -FilePath $Script:Config.EnvFile
    if ($envConfig.Count -gt 0) {
        Write-ColorMessage "Loading configuration from .env file..." -Type Info

        # Load Token from .env if not provided via parameter
        if ([string]::IsNullOrEmpty($Token) -and $envConfig.ContainsKey('GITHUB_TOKEN') -and -not [string]::IsNullOrEmpty($envConfig.GITHUB_TOKEN)) {
            $Token = $envConfig.GITHUB_TOKEN
            Write-ColorMessage "GitHub token loaded from .env" -Type Success
        }

        # Load Registry from .env if not provided via parameter
        if ($PSBoundParameters.ContainsKey('Registry')) {
            Write-ColorMessage "Registry: $Registry (from parameter)" -Type Info
        } elseif ($envConfig.ContainsKey('GHCR_REGISTRY') -and -not [string]::IsNullOrEmpty($envConfig.GHCR_REGISTRY)) {
            $Registry = $envConfig.GHCR_REGISTRY
            Write-ColorMessage "Registry: $Registry (from .env)" -Type Info
        } else {
            Write-ColorMessage "Registry: $Registry (default)" -Type Info
        }

        # Load Owner from .env if not provided via parameter
        if ($PSBoundParameters.ContainsKey('Owner')) {
            Write-ColorMessage "Owner: $Owner (from parameter)" -Type Info
        } elseif ($envConfig.ContainsKey('GHCR_OWNER') -and -not [string]::IsNullOrEmpty($envConfig.GHCR_OWNER)) {
            $Owner = $envConfig.GHCR_OWNER
            Write-ColorMessage "Owner: $Owner (from .env)" -Type Info
        } else {
            Write-ColorMessage "Owner: $Owner (default)" -Type Info
        }
    } else {
        Write-ColorMessage "Registry: $Registry (default)" -Type Info
        Write-ColorMessage "Owner: $Owner (default)" -Type Info
    }
    $chartMapping = Get-ChartMapping -ChartsDirectory $Script:Config.ChartsDir
    if ($chartMapping.Count -eq 0) {
        Write-ColorMessage "No Helm charts found in $($Script:Config.ChartsDir)" -Type Error
        Write-ColorMessage "Make sure Chart.yaml exists in chart directories" -Type Info
        exit 1
    }
    Write-ColorMessage "Found $($chartMapping.Count) chart(s): $($chartMapping.Keys -join ', ')" -Type Success
    $chartsToProcess = if ($Chart -contains "all") {
        Write-ColorMessage "Building all charts..." -Type Info
        @($chartMapping.Keys)
    } else {
        $invalid = $Chart | Where-Object { $_ -ne "all" -and -not $chartMapping.ContainsKey($_) }
        if ($invalid) {
            Write-ColorMessage "Unknown chart(s): $($invalid -join ', ')" -Type Error
            Write-ColorMessage "Available charts: $($chartMapping.Keys -join ', '), all" -Type Info
            exit 1
        }
        $Chart
    }
    Write-ColorMessage "Charts to process: $($chartsToProcess -join ', ')" -Type Info
    Write-ColorMessage "Checking Prerequisites" -Type Header
    $helmPath = Get-HelmExecutable
    if (-not $helmPath) {
        Write-ColorMessage "Helm is not installed or not found" -Type Error
        Write-ColorMessage "Please install Helm from: https://helm.sh/docs/intro/install/" -Type Info
        Write-ColorMessage "Checked locations:" -Type Info
        Write-Host "  - System PATH" -ForegroundColor Gray
        if ($IsMacOS) {
            Write-Host "  - ~/.rd/bin/helm (Rancher Desktop)" -ForegroundColor Gray
            Write-Host "  - /usr/local/bin/helm (Homebrew)" -ForegroundColor Gray
            Write-Host "  - /opt/homebrew/bin/helm (Homebrew Apple Silicon)" -ForegroundColor Gray
        } elseif ($IsWindows) {
            Write-Host "  - Rancher Desktop installation" -ForegroundColor Gray
            Write-Host "  - Chocolatey installation" -ForegroundColor Gray
            Write-Host "  - Program Files" -ForegroundColor Gray
        } elseif ($IsLinux) {
            Write-Host "  - /usr/local/bin/helm" -ForegroundColor Gray
            Write-Host "  - /usr/bin/helm" -ForegroundColor Gray
            Write-Host "  - ~/.rd/bin/helm (Rancher Desktop)" -ForegroundColor Gray
            Write-Host "  - /snap/bin/helm (Snap)" -ForegroundColor Gray
        }
        exit 1
    }
    $helmVersion = & $helmPath version --short 2>&1
    Write-ColorMessage "Helm is installed: $helmVersion" -Type Success
    Write-ColorMessage "Helm location: $helmPath" -Type Info
    foreach ($chartKey in $chartsToProcess) {
        $chartPath = $chartMapping[$chartKey].Path
        $chartFile = Join-Path $chartPath "Chart.yaml"
        if (-not (Test-Path $chartFile)) {
            Write-ColorMessage "Chart.yaml not found at: $chartFile" -Type Error
            exit 1
        }
        Write-ColorMessage "Chart found: $chartKey at $chartPath" -Type Success
    }
    if ($Login) {
        Write-ColorMessage "Logging in to GHCR" -Type Header
        if ([string]::IsNullOrEmpty($Token)) {
            Write-ColorMessage "No token provided via -Token parameter or .env file" -Type Info
            Write-ColorMessage "Please enter your GitHub Personal Access Token:" -Type Info
            $secureToken = Read-Host -AsSecureString
            $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureToken)
            $Token = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
        }
        if (-not (Invoke-HelmLogin -Registry $Registry -Token $Token -HelmPath $helmPath)) {
            exit 1
        }
    }
    if (-not (Test-Path $Script:Config.PackageDir)) {
        New-Item -ItemType Directory -Path $Script:Config.PackageDir -Force | Out-Null
        Write-ColorMessage "Created package directory: $($Script:Config.PackageDir)" -Type Info
    }
    $results = [System.Collections.Generic.List[hashtable]]::new()
    foreach ($chartKey in $chartsToProcess) {
        $chartName = $chartMapping[$chartKey].Name
        $chartPath = $chartMapping[$chartKey].Path
        $chartFile = Join-Path $chartPath "Chart.yaml"
        Write-ColorMessage "Processing Chart: $chartName" -Type Header
        try {
            $chartVersion = Get-ChartVersion -ChartFile $chartFile
            Write-ColorMessage "Chart version: $chartVersion" -Type Success
            Write-ColorMessage "Packaging $chartName..." -Type Info
            $packageResult = Invoke-ChartPackage -ChartPath $chartPath -DestinationDir $Script:Config.PackageDir -HelmPath $helmPath
            if (-not $packageResult.Success) {
                throw "Packaging failed: $($packageResult.Error)"
            }
            $chartPackage = Join-Path $Script:Config.PackageDir "${chartName}-${chartVersion}.tgz"
            Write-ColorMessage "Chart packaged successfully: $chartPackage" -Type Success
            $packageSize = [math]::Round((Get-Item $chartPackage).Length / 1KB, 2)
            Write-ColorMessage "Package size: $packageSize KB" -Type Info
            if ($Push) {
                Write-ColorMessage "Pushing $chartName to GHCR..." -Type Info
                $pushResult = Invoke-ChartPush -Package $chartPackage -Registry $Registry -Owner $Owner -HelmPath $helmPath
                if ($pushResult.Success) {
                    Write-ColorMessage "Chart pushed successfully to GHCR!" -Type Success
                    $results.Add(@{
                        Chart    = $chartName
                        Version  = $chartVersion
                        Package  = $chartPackage
                        Status   = "Pushed"
                        Registry = "${Registry}/${Owner}/${chartName}:${chartVersion}"
                    })
                } else {
                    Write-ColorMessage "Failed to push chart: $($pushResult.Error)" -Type Error
                    $results.Add(@{
                        Chart   = $chartName
                        Version = $chartVersion
                        Package = $chartPackage
                        Status  = "Packaged (push failed)"
                        Error   = $pushResult.Error
                    })
                }
            } else {
                $results.Add(@{
                    Chart   = $chartName
                    Version = $chartVersion
                    Package = $chartPackage
                    Status  = "Packaged"
                })
            }
        } catch {
            Write-ColorMessage "Failed to process chart: $_" -Type Error
            $results.Add(@{
                Chart  = $chartName
                Status = "Failed"
                Error  = $_.Exception.Message
            })
        }
    }
    Show-Summary -Results $results -Registry $Registry -Owner $Owner -PushEnabled $Push
    $failCount = ($results | Where-Object { $_.Status -eq 'Failed' }).Count
    exit $(if ($failCount -eq 0) { 0 } else { 1 })
} catch {
    Write-ColorMessage "Fatal error: $_" -Type Error
    Write-ColorMessage "Stack trace: $($_.ScriptStackTrace)" -Type Error
    exit 1
}
#endregion
