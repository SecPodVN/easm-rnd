# Skaffold Quick Start Guide

## ⚠️ Important: Environment Variables Required

Skaffold requires environment variables from `.env` file to be loaded before running.

## 🚀 Quick Start Options

### Option 1: Use the Start Script (Recommended)

**Windows (PowerShell):**
```powershell
.\skaffold.ps1
```

**Linux/macOS (Bash):**
```bash
./skaffold.sh
```

### Option 2: Load .env and Run Manually

**Windows (PowerShell):**
```powershell
# Load environment variables from .env
Get-Content .env | ForEach-Object {
  if ($_ -match '^\s*([^#][^=]+)=(.*)$') {
    Set-Item -Path "env:$($matches[1].Trim())" -Value $matches[2].Trim()
  }
}

# Run skaffold
skaffold dev
```

**Linux/macOS (Bash):**
```bash
# Load environment variables from .env
set -a
source .env
set +a

# Run skaffold
skaffold dev
```

### Option 3: One-Line Command

**Windows (PowerShell):**
```powershell
Get-Content .env | ForEach-Object { if ($_ -match '^\s*([^#][^=]+)=(.*)$') { Set-Item -Path "env:$($matches[1].Trim())" -Value $matches[2].Trim() } }; skaffold dev
```

**Linux/macOS (Bash):**
```bash
(set -a; source .env; set +a; skaffold dev)
```

## 🔧 Common Commands

### Development Mode (Hot Reload)
```powershell
# Windows
.\skaffold.ps1
# Then select: 1) Development

# Or manually:
Get-Content .env | ForEach-Object { if ($_ -match '^\s*([^#][^=]+)=(.*)$') { Set-Item -Path "env:$($matches[1].Trim())" -Value $matches[2].Trim() } }; skaffold dev
```

### One-Time Deployment
```powershell
# Windows
.\skaffold.ps1
# Then select: 2) One-time deployment

# Or manually:
Get-Content .env | ForEach-Object { if ($_ -match '^\s*([^#][^=]+)=(.*)$') { Set-Item -Path "env:$($matches[1].Trim())" -Value $matches[2].Trim() } }; skaffold run
```

### Build Only
```powershell
skaffold build
```

### Delete Deployment
```powershell
Get-Content .env | ForEach-Object { if ($_ -match '^\s*([^#][^=]+)=(.*)$') { Set-Item -Path "env:$($matches[1].Trim())" -Value $matches[2].Trim() } }; skaffold delete
```

## ❌ Common Errors

### Error: "map has no entry for key K8S_NAMESPACE"

**Cause:** Environment variables from `.env` are not loaded.

**Solution:** Use one of the methods above to load `.env` before running skaffold.

### Error: "release not found"

**Cause:** Previous deployment wasn't cleaned up properly.

**Solution:**
```powershell
# Load env vars first
Get-Content .env | ForEach-Object { if ($_ -match '^\s*([^#][^=]+)=(.*)$') { Set-Item -Path "env:$($matches[1].Trim())" -Value $matches[2].Trim() } }

# Delete all releases
helm uninstall postgresql -n easm-rnd
helm uninstall redis -n easm-rnd
helm uninstall easm-api -n easm-rnd

# Or use skaffold
skaffold delete
```

### Error: "Kubernetes cluster not running"

**Solution:**
```powershell
# Start Minikube
minikube start

# Or check Docker Desktop Kubernetes is enabled
```

## 📝 Required Environment Variables

Ensure these are set in `.env`:

```bash
# Kubernetes Settings
K8S_NAMESPACE=easm-rnd
K8S_REPLICA_COUNT=1

# Docker Image
API_IMAGE=easm-api
API_IMAGE_TAG=latest
API_APP_VERSION=0.1.0

# Database
POSTGRES_HOST=postgresql
POSTGRES_PORT=5432
POSTGRES_DB=easm_db
POSTGRES_USER=easm_user
POSTGRES_PASSWORD=easm_password

# Redis
REDIS_HOST=redis-master
REDIS_PORT=6379
REDIS_DB=0

# Django
DEBUG=True
SECRET_KEY=django-insecure-development-key-change-in-production
ALLOWED_HOSTS=*

# JWT
JWT_ACCESS_TOKEN_LIFETIME=60
JWT_REFRESH_TOKEN_LIFETIME=1440
```

## 🔍 Verify Deployment

```powershell
# Check if env vars are loaded
Write-Host "K8S_NAMESPACE: $env:K8S_NAMESPACE"
Write-Host "API_IMAGE: $env:API_IMAGE"

# Check deployments
kubectl get all -n easm-rnd

# Check pods
kubectl get pods -n easm-rnd

# Check services
kubectl get svc -n easm-rnd

# View logs
kubectl logs -f deployment/easm-api -n easm-rnd
```

## 🌐 Access the Application

After successful deployment:

```powershell
# API is port-forwarded automatically by Skaffold
# Access at: http://localhost:8000

# Or manually:
kubectl port-forward svc/easm-api 8000:8000 -n easm-rnd
```

## 🛑 Stop Deployment

Press `Ctrl+C` in the terminal running `skaffold dev`

Skaffold will automatically clean up resources.

---

**Tip:** Create a PowerShell alias for convenience:

```powershell
# Add to your PowerShell profile
function Start-Skaffold {
    Get-Content .env | ForEach-Object {
        if ($_ -match '^\s*([^#][^=]+)=(.*)$') {
            Set-Item -Path "env:$($matches[1].Trim())" -Value $matches[2].Trim()
        }
    }
    skaffold dev
}

Set-Alias -Name skdev -Value Start-Skaffold
```

Then just run: `skdev`
