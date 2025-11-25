<#
.SYNOPSIS
    Build and push Docker images to GitHub Container Registry (GHCR)

.DESCRIPTION
    This script builds Docker images for EASM API and Frontend.
    - Builds images locally and optionally saves them to .build/images
    - Can push to GHCR when -Push flag is used
    - Supports automatic login to GHCR with -Login flag

.PARAMETER Image
    Which image to build: api, frontend, or all (default: all)

.PARAMETER Push
    Push images to GHCR after building (default: false)

.PARAMETER Login
    Login to GHCR before pushing (default: false)

.PARAMETER Token
    GitHub PAT for GHCR authentication (or set GITHUB_TOKEN in .env)

.PARAMETER Version
    Version tag for the images (default: reads from Chart.yaml or uses 'latest')

.PARAMETER Platform
    Target platform for multi-arch builds (default: linux/amd64)

.PARAMETER Registry
    Container registry URL (default: ghcr.io from .env or ghcr.io)

.PARAMETER Owner
    Registry owner/organization (default: from .env or SecPodVN)

.PARAMETER SaveLocal
    Save image tar files to .build/images directory (default: true if not pushing)

.EXAMPLE
    .\build-image.ps1 -Image all
    Build all images locally

.EXAMPLE
    .\build-image.ps1 -Image api -Push -Login
    Build API image and push to GHCR with login

.EXAMPLE
    .\build-image.ps1 -Image all -Push -Login -Token "ghp_xxxxx"
    Build all images and push to GHCR with custom token
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [ValidateSet('api', 'frontend', 'all')]
    [string]$Image = 'all',

    [Parameter(Mandatory=$false)]
    [switch]$Push,

    [Parameter(Mandatory=$false)]
    [switch]$Login,

    [Parameter(Mandatory=$false)]
    [string]$Token,

    [Parameter(Mandatory=$false)]
    [string]$Version,

    [Parameter(Mandatory=$false)]
    [string]$Platform = 'linux/amd64',

    [Parameter(Mandatory=$false)]
    [string]$Registry,

    [Parameter(Mandatory=$false)]
    [string]$Owner,

    [Parameter(Mandatory=$false)]
    [switch]$SaveLocal
)

#region Configuration
$ErrorActionPreference = 'Stop'
$Script:Config = @{
    ImagesDir = "./.build/images"
    EnvFile   = "./.env"
}
#endregion

# Color output functions
function Write-ColorOutput {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message,
        [Parameter(Mandatory=$false)]
        [string]$Color = 'White',
        [Parameter(Mandatory=$false)]
        [switch]$NoNewline
    )

    $params = @{
        Object = $Message
        ForegroundColor = $Color
    }
    if ($NoNewline) {
        $params.Add('NoNewline', $true)
    }
    Write-Host @params
}

function Write-Header {
    param([string]$Message)
    Write-Host ""
    Write-ColorOutput "========================================" -Color Cyan
    Write-ColorOutput " $Message" -Color Cyan
    Write-ColorOutput "========================================" -Color Cyan
    Write-Host ""
}

function Write-Step {
    param([string]$Message)
    Write-ColorOutput "[*] $Message" -Color Yellow
}

function Write-Success {
    param([string]$Message)
    Write-ColorOutput "[✓] $Message" -Color Green
}

function Write-Error-Custom {
    param([string]$Message)
    Write-ColorOutput "[✗] $Message" -Color Red
}

function Write-Info {
    param([string]$Message)
    Write-ColorOutput "[ℹ] $Message" -Color Cyan
}

function Write-Warning {
    param([string]$Message)
    Write-ColorOutput "[⚠] $Message" -Color Yellow
}

# Load environment variables from .env file
function Load-EnvFile {
    param([string]$FilePath = ".env")

    if (Test-Path $FilePath) {
        Write-Step "Loading environment variables from $FilePath"
        Get-Content $FilePath | ForEach-Object {
            if ($_ -match '^\s*([^#][^=]+)=(.*)$') {
                $name = $matches[1].Trim()
                $value = $matches[2].Trim()
                # Remove quotes if present
                $value = $value -replace '^["'']|["'']$', ''
                [Environment]::SetEnvironmentVariable($name, $value, 'Process')
            }
        }
        Write-Success "Environment variables loaded"
    } else {
        Write-Error-Custom ".env file not found at $FilePath"
    }
}

# Get version from Chart.yaml
function Get-ChartVersion {
    param([string]$ChartPath)

    $chartYaml = Join-Path $ChartPath "Chart.yaml"
    if (Test-Path $chartYaml) {
        $content = Get-Content $chartYaml -Raw
        if ($content -match '(?m)^version:\s*(.+)$') {
            return $matches[1].Trim()
        }
    }
    return $null
}

# Check if Docker is available
function Test-Docker {
    try {
        # Common Docker installation locations by priority
        $dockerLocations = @(
            '/usr/local/bin/docker'           # Homebrew / Docker Desktop (preferred)
            '/opt/homebrew/bin/docker'        # Homebrew (Apple Silicon)
            'docker'                          # In PATH
            '/usr/bin/docker'                 # System
            "$HOME/.docker/bin/docker"        # User local
            "$HOME/.rd/bin/docker"            # Rancher Desktop (last resort)
        )

        # Try each location
        foreach ($location in $dockerLocations) {
            $expandedPath = $ExecutionContext.InvokeCommand.ExpandString($location)

            # Try as file path first
            if ($location -ne 'docker' -and (Test-Path $expandedPath -ErrorAction SilentlyContinue)) {
                try {
                    $output = & $expandedPath --version 2>&1
                    if ($LASTEXITCODE -eq 0 -and $output -match "Docker version") {
                        # Set this as the docker command to use
                        Set-Alias -Name docker -Value $expandedPath -Scope Global -Force
                        return $true
                    }
                } catch {
                    continue
                }
            }

            # Try as command in PATH
            if ($location -eq 'docker') {
                try {
                    $output = & docker --version 2>&1
                    if ($LASTEXITCODE -eq 0 -and $output -match "Docker version") {
                        return $true
                    }
                } catch {
                    continue
                }
            }
        }

        return $false
    } catch {
        return $false
    }
}

# Check if Docker Buildx is available
function Test-DockerBuildx {
    try {
        $buildxOutput = & docker buildx version 2>&1

        if ($LASTEXITCODE -eq 0) {
            return $true
        }

        return $false
    } catch {
        return $false
    }
}

# Login to GitHub Container Registry
function Invoke-GHCRLogin {
    param(
        [string]$Registry,
        [string]$Token
    )

    Write-Step "Logging in to $Registry"

    if (-not $Token) {
        Write-Error-Custom "GITHUB_TOKEN is not set. Please set it in .env file or environment."
        Write-Host ""
        Write-Host "To create a GitHub Personal Access Token (Classic):" -ForegroundColor Yellow
        Write-Host "  1. Go to: https://github.com/settings/tokens" -ForegroundColor Gray
        Write-Host "  2. Click 'Generate new token' → 'Generate new token (classic)'" -ForegroundColor Gray
        Write-Host "  3. Add a note (e.g., 'GHCR Push Access')" -ForegroundColor Gray
        Write-Host "  4. Select scopes:" -ForegroundColor Gray
        Write-Host "     ✓ write:packages (Upload packages to GitHub Package Registry)" -ForegroundColor Green
        Write-Host "     ✓ read:packages (Download packages from GitHub Package Registry)" -ForegroundColor Green
        Write-Host "     ✓ delete:packages (Delete packages from GitHub Package Registry) - Optional" -ForegroundColor Gray
        Write-Host "  5. Click 'Generate token' and copy it" -ForegroundColor Gray
        Write-Host "  6. Add to .env file: GITHUB_TOKEN=ghp_xxxxxxxxxxxx" -ForegroundColor Gray
        Write-Host ""
        return $false
    }

    # Validate token format
    if (-not ($Token -match '^(ghp_|github_pat_)')) {
        Write-Warning "Token does not appear to be a valid GitHub token"
        Write-Info "GitHub tokens should start with 'ghp_' or 'github_pat_'"
    }

    # Use 'oauth2' as username for GHCR (not system username)
    $username = 'oauth2'

    $env:DOCKER_TOKEN = $Token
    $loginResult = echo $env:DOCKER_TOKEN | docker login $Registry -u $username --password-stdin 2>&1
    Remove-Item Env:DOCKER_TOKEN

    if ($LASTEXITCODE -eq 0) {
        Write-Success "Successfully logged in to $Registry"
        return $true
    } else {
        Write-Error-Custom "Failed to login to $Registry"
        Write-Host $loginResult
        return $false
    }
}

# Build Docker image
function Build-DockerImage {
    param(
        [string]$ImageName,
        [string]$Context,
        [string]$Dockerfile,
        [string]$FullImageName,
        [string]$RegistryFullName,
        [string]$Platform,
        [bool]$Push,
        [bool]$SaveLocal,
        [string]$OutputDir
    )

    Write-Header "Building Docker Image: $ImageName"

    Write-Info "Image: $FullImageName"
    Write-Info "Context: $Context"
    Write-Info "Dockerfile: $Dockerfile"
    Write-Info "Platform: $Platform"
    Write-Info "Push: $Push"
    if ($SaveLocal) {
        Write-Info "Save to: $OutputDir"
    }
    if ($Push -and $RegistryFullName) {
        Write-Info "Registry: $RegistryFullName"
    }

    # Check if image already exists locally when pushing
    $skipBuild = $false
    if ($Push) {
        $imageTag = ($FullImageName -split ':')[-1]
        $tarFileName = "${ImageName}-${imageTag}.tar"
        $tarFilePath = Join-Path $OutputDir $tarFileName

        if (Test-Path $tarFilePath) {
            Write-Info "Found existing image: $tarFilePath"
            $fileSize = [math]::Round((Get-Item $tarFilePath).Length / 1MB, 2)
            Write-Info "Size: $fileSize MB"

            Write-Step "Loading existing image..."
            $loadResult = docker load -i $tarFilePath 2>&1

            if ($LASTEXITCODE -eq 0) {
                Write-Success "Image loaded from local file"

                # Verify the image exists with the expected name
                $imageCheck = docker images --format "{{.Repository}}:{{.Tag}}" | Where-Object { $_ -eq $FullImageName }
                if (-not $imageCheck) {
                    Write-Warning "Loaded image not found with expected name: $FullImageName"
                    Write-Info "Available images:"
                    docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" | Select-Object -First 10 | ForEach-Object {
                        Write-ColorOutput "  $_" -Color Gray
                    }
                    Write-Warning "Will rebuild image instead"
                } else {
                    Write-Info "Verified image exists: $FullImageName"
                    $skipBuild = $true
                }
            } else {
                Write-Warning "Failed to load existing image, will rebuild"
                Write-ColorOutput "  $loadResult" -Color Gray
            }
        } else {
            Write-Info "No existing image found at: $tarFilePath"
            Write-Info "Will build new image"
        }
    }

    # Check if context exists (skip if using existing image)
    if (-not $skipBuild) {
        if (-not (Test-Path $Context)) {
            Write-Error-Custom "Context directory not found: $Context"
            return @{ Success = $false; Error = "Context not found" }
        }

        # Check if Dockerfile exists
        $dockerfilePath = Join-Path $Context $Dockerfile
        if (-not (Test-Path $dockerfilePath)) {
            Write-Error-Custom "Dockerfile not found: $dockerfilePath"
            return @{ Success = $false; Error = "Dockerfile not found" }
        }
    }

    # Build or push existing image
    if ($skipBuild) {
        # Tag the loaded image with registry name and push
        if ($Push -and $RegistryFullName) {
            Write-Step "Tagging image for registry..."
            $tagResult = docker tag $FullImageName $RegistryFullName 2>&1

            if ($LASTEXITCODE -ne 0) {
                Write-Error-Custom "Failed to tag image"
                Write-ColorOutput "  Error: $tagResult" -Color Red
                return @{ Success = $false; Error = "Tag failed: $tagResult" }
            }

            Write-Success "Image tagged: $RegistryFullName"

            Write-Step "Pushing image to registry..."
            Write-ColorOutput "  Command: docker push $RegistryFullName" -Color Gray

            $pushResult = docker push $RegistryFullName 2>&1

            if ($LASTEXITCODE -ne 0) {
                Write-Error-Custom "Failed to push image to registry"
                Write-Host ""

                # Check if it's a permission error
                $errorText = $pushResult -join ' '
                if ($errorText -match 'permission_denied|does not match expected scopes') {
                    Write-ColorOutput "ERROR: Token does not have sufficient permissions!" -Color Red
                    Write-Host ""
                    Write-Host "Your GitHub token is missing required scopes." -ForegroundColor Yellow
                    Write-Host ""
                    Write-Host "To fix this:" -ForegroundColor Yellow
                    Write-Host "  1. Go to: https://github.com/settings/tokens" -ForegroundColor Gray
                    Write-Host "  2. Find your current token or create a new one (classic)" -ForegroundColor Gray
                    Write-Host "  3. Ensure these scopes are checked:" -ForegroundColor Gray
                    Write-Host "     ✓ write:packages" -ForegroundColor Green
                    Write-Host "     ✓ read:packages" -ForegroundColor Green
                    Write-Host "  4. Save the token and update your .env file" -ForegroundColor Gray
                    Write-Host "  5. Run: pwsh ./tools/build-image.ps1 -Login -Push" -ForegroundColor Gray
                    Write-Host ""
                } else {
                    Write-ColorOutput "Error output:" -Color Red
                    $pushResult | ForEach-Object { Write-ColorOutput "  $_" -Color Red }
                }
                Write-Host ""
                return @{ Success = $false; Error = "Push failed: $errorText" }
            }

            Write-Success "Image pushed successfully: $RegistryFullName"
        }
    } else {
        # Build new image
        # Build command - use full path for Dockerfile
        $buildArgs = @(
            'buildx', 'build',
            '--platform', $Platform,
            '-t', $FullImageName
        )

        # Add registry tag if pushing
        if ($Push -and $RegistryFullName) {
            $buildArgs += @('-t', $RegistryFullName)
        }

        $buildArgs += @(
            '-f', $dockerfilePath,
            $Context
        )

        if ($Push) {
            $buildArgs += '--push'
        } else {
            $buildArgs += '--load'
        }

        Write-Step "Building image..."
        Write-ColorOutput "  Command: docker $($buildArgs -join ' ')" -Color Gray
        Write-Host ""

        $buildResult = & docker @buildArgs

        if ($LASTEXITCODE -ne 0) {
            Write-Error-Custom "Failed to build image: $ImageName"
            return @{ Success = $false; Error = "Build failed" }
        }

        Write-Success "Image built successfully: $FullImageName"
    }

    # Save image to local tar file if requested
    if ($SaveLocal -and -not $Push) {
        Write-Step "Saving image to local file..."

        # Create output directory if it doesn't exist
        if (-not (Test-Path $OutputDir)) {
            New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
            Write-Info "Created directory: $OutputDir"
        }

        # Extract version from full image name
        $imageTag = ($FullImageName -split ':')[-1]
        $tarFileName = "${ImageName}-${imageTag}.tar"
        $tarFilePath = Join-Path $OutputDir $tarFileName

        Write-Info "Saving to: $tarFilePath"
        $saveResult = docker save -o $tarFilePath $FullImageName 2>&1

        if ($LASTEXITCODE -eq 0) {
            $fileSize = [math]::Round((Get-Item $tarFilePath).Length / 1MB, 2)
            Write-Success "Image saved successfully: $tarFilePath ($fileSize MB)"
            return @{
                Success = $true
                Package = $tarFilePath
                Size = $fileSize
            }
        } else {
            Write-Error-Custom "Failed to save image to file"
            return @{ Success = $false; Error = "Save failed" }
        }
    }

    return @{ Success = $true }
}

# Main script
Write-Header "EASM Docker Image Builder"

# Load .env file
Load-EnvFile

# Check Docker
if (-not (Test-Docker)) {
    Write-Error-Custom "Docker is not installed or not in PATH"
    Write-Host ""
    Write-Host "Please ensure Docker is installed and running:" -ForegroundColor Yellow
    Write-Host "  - Docker Desktop: Check if it's running" -ForegroundColor Gray
    Write-Host "  - Rancher Desktop: Check Settings > Container Engine" -ForegroundColor Gray
    Write-Host "  - CLI: Verify with 'docker --version'" -ForegroundColor Gray
    Write-Host ""
    Write-Host "If using Rancher Desktop with broken symlinks:" -ForegroundColor Yellow
    Write-Host "  1. Open Rancher Desktop Settings" -ForegroundColor Gray
    Write-Host "  2. Go to Container Engine > General" -ForegroundColor Gray
    Write-Host "  3. Ensure 'dockerd (moby)' is selected" -ForegroundColor Gray
    Write-Host "  4. Or use: ln -sf ~/.rd/bin/docker /usr/local/bin/docker" -ForegroundColor Gray
    Write-Host ""
    exit 1
}

# Check Docker Buildx
if (-not (Test-DockerBuildx)) {
    Write-Error-Custom "Docker Buildx is not available"
    Write-Info "Install: docker buildx create --use"
    exit 1
}

# Set defaults from environment or parameters
$Registry = if ($Registry) { $Registry } elseif ($env:GHCR_REGISTRY) { $env:GHCR_REGISTRY } else { 'ghcr.io' }
$Owner = if ($Owner) { $Owner } elseif ($env:GHCR_OWNER) { $env:GHCR_OWNER } else { 'secpodvn' }
$Owner = $Owner.ToLower() # GHCR requires lowercase

# Load Token from .env if not provided via parameter
if ([string]::IsNullOrEmpty($Token) -and $env:GITHUB_TOKEN) {
    $Token = $env:GITHUB_TOKEN
}

# Determine if we should save locally (default: true if not pushing)
$shouldSaveLocal = if ($PSBoundParameters.ContainsKey('SaveLocal')) {
    $SaveLocal.IsPresent
} else {
    -not $Push
}

Write-Info "Registry: $Registry"
Write-Info "Owner: $Owner"
Write-Info "Platform: $Platform"
Write-Info "Push to GHCR: $Push"
Write-Info "Save locally: $shouldSaveLocal"

# Login to GHCR if requested
if ($Login) {
    if ([string]::IsNullOrEmpty($Token)) {
        Write-Error-Custom "No token provided via -Token parameter or .env file (GITHUB_TOKEN)"
        Write-Info "Please set GITHUB_TOKEN in .env or provide via -Token parameter"
        Write-Info "Get token from: https://github.com/settings/tokens"
        Write-Info "Required scopes: write:packages, read:packages"
        exit 1
    }

    $loginSuccess = Invoke-GHCRLogin -Registry $Registry -Token $Token
    if (-not $loginSuccess) {
        exit 1
    }
}

# Define images to build
$imagesToBuild = @()

if ($Image -eq 'all' -or $Image -eq 'api') {
    $apiVersion = if ($Version) { $Version } else {
        $version = Get-ChartVersion "src/charts/easm-api"
        if ($version) { $version } else { 'latest' }
    }

    $imagesToBuild += @{
        Name = 'easm-api'
        Context = 'src/backend'
        Dockerfile = 'Dockerfile'
        FullName = "easm-api:${apiVersion}"
        RegistryFullName = "${Registry}/${Owner}/images/easm-api:${apiVersion}"
        Version = $apiVersion
    }
}

if ($Image -eq 'all' -or $Image -eq 'frontend') {
    $frontendVersion = if ($Version) { $Version } else {
        $v = Get-ChartVersion "src/charts/easm-frontend"
        if ($v) { $v } else { 'latest' }
    }

    $imagesToBuild += @{
        Name = 'easm-frontend'
        Context = 'src/frontend/easm-user-portal'
        Dockerfile = 'Dockerfile'
        FullName = "easm-frontend:${frontendVersion}"
        RegistryFullName = "${Registry}/${Owner}/images/easm-frontend:${frontendVersion}"
        Version = $frontendVersion
    }
}

# Build images
$results = @()
foreach ($img in $imagesToBuild) {
    $buildResult = Build-DockerImage `
        -ImageName $img.Name `
        -Context $img.Context `
        -Dockerfile $img.Dockerfile `
        -FullImageName $img.FullName `
        -RegistryFullName $img.RegistryFullName `
        -Platform $Platform `
        -Push $Push `
        -SaveLocal $shouldSaveLocal `
        -OutputDir $Script:Config.ImagesDir

    $result = @{
        Name    = $img.Name
        FullName = $img.FullName
        Version = $img.Version
        Success = $buildResult.Success
    }

    if ($buildResult.Package) {
        $result.Package = $buildResult.Package
        $result.Size = $buildResult.Size
    }

    if ($buildResult.Error) {
        $result.Error = $buildResult.Error
    }

    if ($Push -and $buildResult.Success) {
        $result.Status = 'Pushed'
        $result.Registry = $img.RegistryFullName
    } elseif ($buildResult.Success -and $buildResult.Package) {
        $result.Status = 'Built & Saved'
    } elseif ($buildResult.Success) {
        $result.Status = 'Built'
    } else {
        $result.Status = 'Failed'
    }

    $results += $result
}

# Summary
Write-Header "Build Summary"

Write-Host "Total images processed: $($results.Count)" -ForegroundColor Cyan
Write-Host ""

foreach ($result in $results) {
    $statusSymbol = if ($result.Success) { "✓" } else { "✗" }
    $statusColor = if ($result.Success) { "Green" } else { "Red" }

    Write-Host "Image: $($result.Name)" -ForegroundColor White
    Write-Host "  Version: $($result.Version)" -ForegroundColor Cyan
    Write-Host "  Full Name: $($result.FullName)" -ForegroundColor Cyan
    Write-Host "  Status: " -NoNewline

    Write-Host "$($result.Status) $statusSymbol" -ForegroundColor $statusColor

    if ($result.Package) {
        Write-Host "  Package: $($result.Package)" -ForegroundColor Cyan
        Write-Host "  Size: $($result.Size) MB" -ForegroundColor Cyan
    }

    if ($result.Registry -and $Push) {
        Write-Host "  Registry: $($result.Registry)" -ForegroundColor Cyan
    }

    if ($result.Error) {
        Write-Host "  Error: $($result.Error)" -ForegroundColor Red
    }

    Write-Host ""
}

# Show usage instructions
if (-not $Push) {
    Write-Host "Local Images Built:" -ForegroundColor Yellow
    Write-Host "  To load: docker load -i .build/images/<image-name>.tar" -ForegroundColor Gray
    Write-Host "  To push to GHCR, run with -Push -Login flags" -ForegroundColor Gray
    Write-Host ""
}

if ($Push) {
    Write-Host "Images pushed to GHCR:" -ForegroundColor Yellow
    foreach ($result in $results | Where-Object { $_.Status -eq 'Pushed' }) {
        Write-Host "  docker pull $($result.Registry)" -ForegroundColor Gray
    }
    Write-Host ""
}

# Final status
$successCount = ($results | Where-Object { $_.Success }).Count
$totalCount = $results.Count

Write-Host ""
if ($successCount -eq $totalCount) {
    Write-Success "All images processed successfully! ($successCount/$totalCount)"
    exit 0
} else {
    Write-Error-Custom "Some images failed ($successCount/$totalCount succeeded)"
    exit 1
}
