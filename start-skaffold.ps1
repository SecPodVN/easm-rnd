# Quick start script for deploying EASM with Skaffold (PowerShell)

Write-Host "=== EASM Skaffold Deployment Script ===" -ForegroundColor Cyan
Write-Host ""

# Load environment variables from .env file
if (Test-Path .env) {
    Write-Host "📋 Loading environment variables from .env file..." -ForegroundColor Yellow
    Get-Content .env | ForEach-Object {
        if ($_ -match '^\s*([^#][^=]+)=(.*)$') {
            $name = $matches[1].Trim()
            $value = $matches[2].Trim()
            Set-Item -Path "env:$name" -Value $value
            Write-Host "  Set $name" -ForegroundColor Gray
        }
    }
    Write-Host ""
} else {
    Write-Host "⚠️  Warning: .env file not found!" -ForegroundColor Yellow
    Write-Host "   Copy .env.example to .env and configure your environment" -ForegroundColor Yellow
    Write-Host ""
}

# Check if Kubernetes is running
try {
    kubectl cluster-info 2>&1 | Out-Null
    Write-Host "✅ Kubernetes cluster is running" -ForegroundColor Green
} catch {
    Write-Host "❌ Kubernetes cluster is not running!" -ForegroundColor Red
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
    Write-Host "📦 Adding Bitnami Helm repository..." -ForegroundColor Yellow
    helm repo add bitnami https://charts.bitnami.com/bitnami
}

Write-Host "🔄 Updating Helm repositories..." -ForegroundColor Yellow
helm repo update

Write-Host ""
Write-Host "Choose deployment mode:" -ForegroundColor Cyan
Write-Host "  1) Development (skaffold dev - with hot reload)"
Write-Host "  2) One-time deployment (skaffold run)"
Write-Host "  3) Development profile (no persistence)"
Write-Host "  4) Production profile (with persistence and scaling)"
Write-Host ""

$choice = Read-Host "Enter your choice (1-4)"

switch ($choice) {
    "1" {
        Write-Host ""
        Write-Host "🚀 Starting Skaffold in development mode..." -ForegroundColor Green
        Write-Host "Press Ctrl+C to stop" -ForegroundColor Yellow
        Write-Host ""
        skaffold dev
    }
    "2" {
        Write-Host ""
        Write-Host "🚀 Deploying with Skaffold..." -ForegroundColor Green
        skaffold run
        Write-Host ""
        Write-Host "✅ Deployment complete!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Access the application:" -ForegroundColor Cyan
        Write-Host "  API: http://localhost:8000"
        Write-Host ""
        Write-Host "To view logs: kubectl logs -f deployment/easm-api" -ForegroundColor Yellow
        Write-Host "To delete: skaffold delete" -ForegroundColor Yellow
    }
    "3" {
        Write-Host ""
        Write-Host "🚀 Starting Skaffold with dev profile..." -ForegroundColor Green
        Write-Host "Press Ctrl+C to stop" -ForegroundColor Yellow
        Write-Host ""
        skaffold dev --profile=dev
    }
    "4" {
        Write-Host ""
        Write-Host "🚀 Deploying with production profile..." -ForegroundColor Green
        skaffold run --profile=prod
        Write-Host ""
        Write-Host "✅ Deployment complete!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Access the application:" -ForegroundColor Cyan
        Write-Host "  kubectl port-forward service/easm-api 8000:8000"
        Write-Host ""
        Write-Host "To view logs: kubectl logs -f deployment/easm-api" -ForegroundColor Yellow
        Write-Host "To delete: skaffold delete" -ForegroundColor Yellow
    }
    default {
        Write-Host "❌ Invalid choice" -ForegroundColor Red
        exit 1
    }
}
