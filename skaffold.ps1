# Quick start script for deploying EASM with Skaffold (PowerShell)

# Cleanup function for temporary files
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

Write-Host "=== EASM Skaffold Deployment Script ===" -ForegroundColor Cyan
Write-Host ""

# Load environment variables from skaffold.env file (new) or .env (fallback)
$envFile = if (Test-Path "skaffold.env") { "skaffold.env" } elseif (Test-Path ".env") { ".env" } else { $null }

if ($envFile) {
    Write-Host "[*] Loading environment variables from $envFile..." -ForegroundColor Yellow
    Get-Content $envFile | Where-Object {
        $_ -notmatch '^\s*#' -and $_ -notmatch '^\s*$'
    } | ForEach-Object {
        if ($_ -match '^\s*([^=]+)=(.*)$') {
            $name = $matches[1].Trim()
            $value = $matches[2].Trim()
            [Environment]::SetEnvironmentVariable($name, $value, 'Process')
            Write-Host "  [+] Set $name" -ForegroundColor Gray
        }
    }
    Write-Host ""
} else {
    Write-Host "[!] Warning: skaffold.env or .env file not found!" -ForegroundColor Yellow
    Write-Host "    Copy skaffold.env.example to skaffold.env and configure your environment" -ForegroundColor Yellow
    Write-Host ""
}

# Check if Kubernetes is running
try {
    kubectl cluster-info 2>&1 | Out-Null
    Write-Host "[OK] Kubernetes cluster is running" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Kubernetes cluster is not running!" -ForegroundColor Red
    Write-Host "Please start your cluster first:"
    Write-Host "  - Minikube: minikube start"
    Write-Host "  - Docker Desktop: Enable Kubernetes in settings"
    Write-Host "  - Kind: kind create cluster"
    exit 1
}

Write-Host ""

# Add Bitnami repo if not already added
$helmRepos = helm repo list 2>&1 | Out-String
if (-not $helmRepos.Contains("bitnami")) {
    Write-Host "[*] Adding Bitnami Helm repository..." -ForegroundColor Yellow
    helm repo add bitnami https://charts.bitnami.com/bitnami
}

Write-Host "[*] Updating Helm repositories..." -ForegroundColor Yellow
helm repo update

Write-Host ""

# Get port configuration from environment or use defaults
$apiPort = if ($env:API_LOCAL_PORT) { $env:API_LOCAL_PORT } else { "8000" }
$postgresPort = if ($env:POSTGRES_LOCAL_PORT) { $env:POSTGRES_LOCAL_PORT } else { "5432" }
$redisPort = if ($env:REDIS_LOCAL_PORT) { $env:REDIS_LOCAL_PORT } else { "6379" }

# Show port configuration
Write-Host "Port Forwarding Configuration:" -ForegroundColor Cyan
Write-Host "   API:        localhost:$apiPort -> container:8000" -ForegroundColor White
Write-Host "   PostgreSQL: localhost:$postgresPort -> container:5432" -ForegroundColor White
Write-Host "   Redis:      localhost:$redisPort -> container:6379" -ForegroundColor White
Write-Host ""

# Generate temporary values file for ALLOWED_HOSTS (handles commas properly)
Write-Host "[*] Generating values file for comma-separated configs..." -ForegroundColor Yellow
$allowedHosts = if ($env:ALLOWED_HOSTS) { $env:ALLOWED_HOSTS } else { "localhost,127.0.0.1" }
$valuesContent = @"
# Auto-generated from skaffold.env
# This file handles values with commas that can't be passed via --set
django:
  allowedHosts: "$allowedHosts"
"@
$valuesContent | Set-Content "skaffold-values.yaml"

# Generate temporary skaffold.yaml with custom ports
# (Skaffold doesn't support CLI port override or template variables in localPort)
Write-Host "[*] Generating temporary skaffold config with custom ports..." -ForegroundColor Yellow
$tempSkaffoldFile = "skaffold.temp.yaml"
$originalContent = Get-Content "skaffold.yaml" -Raw
# Use multiline regex to match and replace only the port number, preserving comments
$modifiedContent = $originalContent -replace '(?m)(^\s+localPort:\s+)8000(\s+#.*)?$', "`${1}$apiPort`$2"
$modifiedContent = $modifiedContent -replace '(?m)(^\s+localPort:\s+)5432(\s+#.*)?$', "`${1}$postgresPort`$2"
$modifiedContent = $modifiedContent -replace '(?m)(^\s+localPort:\s+)6379(\s+#.*)?$', "`${1}$redisPort`$2"
$modifiedContent | Set-Content $tempSkaffoldFile
Write-Host ""

Write-Host "Choose deployment mode:" -ForegroundColor Cyan
Write-Host "  1) Development (skaffold dev - with hot reload)"
Write-Host "  2) One-time deployment (skaffold run)"
Write-Host "  3) Development profile (no persistence)"
Write-Host "  4) Production profile (with persistence and scaling)"
Write-Host "  5) Debug mode (skip cleanup on failure)"
Write-Host ""

$choice = Read-Host "Enter your choice (1-5)"

switch ($choice) {
    "1" {
        Write-Host ""
        Write-Host "[>>] Starting Skaffold in development mode..." -ForegroundColor Green
        Write-Host "[*] Press Ctrl+C to stop" -ForegroundColor Yellow
        Write-Host ""
        try {
            skaffold dev -f $tempSkaffoldFile
        }
        finally {
            Cleanup-TempFiles
        }
    }
    "2" {
        Write-Host ""
        Write-Host "[>>] Deploying with Skaffold..." -ForegroundColor Green
        try {
            skaffold run -f $tempSkaffoldFile
        }
        finally {
            Cleanup-TempFiles
        }
        Write-Host ""
        Write-Host "[OK] Deployment complete!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Access the application:" -ForegroundColor Cyan
        Write-Host "  API: http://localhost:$apiPort"
        Write-Host ""
        Write-Host "To view logs: kubectl logs -f deployment/easm-api" -ForegroundColor Yellow
        Write-Host "To delete: skaffold delete" -ForegroundColor Yellow
    }
    "3" {
        Write-Host ""
        Write-Host "[>>] Starting Skaffold with dev profile..." -ForegroundColor Green
        Write-Host "[*] Press Ctrl+C to stop" -ForegroundColor Yellow
        Write-Host ""
        try {
            skaffold dev --profile=dev -f $tempSkaffoldFile
        }
        finally {
            Cleanup-TempFiles
        }
    }
    "4" {
        Write-Host ""
        Write-Host "[>>] Deploying with production profile..." -ForegroundColor Green
        try {
            skaffold run --profile=prod -f $tempSkaffoldFile
        }
        finally {
            Cleanup-TempFiles
        }
        Write-Host ""
        Write-Host "[OK] Deployment complete!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Access the application:" -ForegroundColor Cyan
        Write-Host "  kubectl port-forward service/easm-api $apiPort:8000"
        Write-Host ""
        Write-Host "To view logs: kubectl logs -f deployment/easm-api" -ForegroundColor Yellow
        Write-Host "To delete: skaffold delete" -ForegroundColor Yellow
    }
    "5" {
        Write-Host ""
        Write-Host "[>>] Starting Skaffold in DEBUG mode..." -ForegroundColor Magenta
        Write-Host "[*] Cleanup on exit will be DISABLED" -ForegroundColor Yellow
        Write-Host "[*] Press Ctrl+C to stop (resources will remain)" -ForegroundColor Yellow
        Write-Host ""
        skaffold dev --cleanup=false --status-check=false
        Write-Host ""
        Write-Host "[DEBUG] Resources are still running. To debug:" -ForegroundColor Cyan
        Write-Host "  View logs: kubectl logs -f deployment/easm-api" -ForegroundColor Yellow
        Write-Host "  Shell into pod: kubectl exec -it deployment/easm-api -- /bin/bash" -ForegroundColor Yellow
        Write-Host "  Check packages: kubectl exec -it deployment/easm-api -- pip list" -ForegroundColor Yellow
        Write-Host "  Delete when done: skaffold delete" -ForegroundColor Yellow
    }
    default {
        Write-Host "[ERROR] Invalid choice" -ForegroundColor Red
        Cleanup-TempFiles
        exit 1
    }
}
