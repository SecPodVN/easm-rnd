# Quick start script for deploying EASM with Skaffold (PowerShell)
# Supports auto-reload when .env file changes

Write-Host "=== EASM Skaffold Deployment Script ===" -ForegroundColor Cyan
Write-Host ""

# Function to load environment variables from .env file
function Load-EnvFile {
    $envVars = @{}
    if (Test-Path .env) {
        Get-Content .env | ForEach-Object {
            if ($_ -match '^\s*([^#][^=]+)=(.*)$') {
                $name = $matches[1].Trim()
                $value = $matches[2].Trim()
                $envVars[$name] = $value
                Set-Item -Path "env:$name" -Value $value
            }
        }
    }
    return $envVars
}

# Load environment variables
$envLoaded = Load-EnvFile
if (-not $envLoaded) {
    Write-Host "[ERROR] Failed to load environment variables from .env file" -ForegroundColor Red
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
Write-Host "Choose deployment mode:" -ForegroundColor Cyan
Write-Host "  1) Development (skaffold dev - with hot reload)"
Write-Host "  2) One-time deployment (skaffold run)"
Write-Host "  3) Development profile (no persistence)"
Write-Host "  4) Production profile (with persistence and scaling)"
Write-Host "  5) Debug mode (skip cleanup on failure)" -ForegroundColor Magenta
Write-Host "  6) Auto-watch mode (.env changes trigger redeploy)" -ForegroundColor Green
Write-Host ""

$choice = Read-Host "Enter your choice (1-6)"

switch ($choice) {
    "1" {
        Write-Host ""
        Write-Host "[>>] Starting Skaffold in development mode..." -ForegroundColor Green
        Write-Host "[*] Press Ctrl+C to stop" -ForegroundColor Yellow
        Write-Host ""
        skaffold dev
    }
    "2" {
        Write-Host ""
        Write-Host "[>>] Deploying with Skaffold..." -ForegroundColor Green
        skaffold run
        Write-Host ""
        Write-Host "[OK] Deployment complete!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Access the application:" -ForegroundColor Cyan
        Write-Host "  API: http://localhost:8000"
        Write-Host ""
        Write-Host "To view logs: kubectl logs -f deployment/easm-api" -ForegroundColor Yellow
        Write-Host "To delete: skaffold delete" -ForegroundColor Yellow
    }
    "3" {
        Write-Host ""
        Write-Host "[>>] Starting Skaffold with dev profile..." -ForegroundColor Green
        Write-Host "[*] Press Ctrl+C to stop" -ForegroundColor Yellow
        Write-Host ""
        skaffold dev --profile=dev
    }
    "4" {
        Write-Host ""
        Write-Host "[>>] Deploying with production profile..." -ForegroundColor Green
        skaffold run --profile=prod
        Write-Host ""
        Write-Host "[OK] Deployment complete!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Access the application:" -ForegroundColor Cyan
        Write-Host "  kubectl port-forward service/easm-api 8000:8000"
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
    "6" {
        Write-Host ""
        Write-Host "[>>] Starting Auto-Watch Mode..." -ForegroundColor Green
        Write-Host "[*] Watching .env file for changes..." -ForegroundColor Cyan
        Write-Host "[*] Services will start/stop based on .env flags" -ForegroundColor Cyan
        Write-Host "[*] Then Skaffold dev will manage the deployment" -ForegroundColor Cyan
        Write-Host "[*] Press Ctrl+C to stop" -ForegroundColor Yellow
        Write-Host ""

        # Helper functions for service management
        function Test-HelmRelease {
            param([string]$ReleaseName, [string]$Namespace)
            $result = helm list -n $Namespace -o json 2>&1 | ConvertFrom-Json
            return $result | Where-Object { $_.name -eq $ReleaseName }
        }

        function Deploy-PostgreSQL {
            param([string]$Namespace)
            Write-Host "[+] Starting PostgreSQL..." -ForegroundColor Green
            helm upgrade --install postgresql bitnami/postgresql --version 18.1.1 --namespace $Namespace --create-namespace --set auth.database=easm_db --set auth.username=easm_user --set auth.password=easm_password --set primary.persistence.enabled=false --set image.pullPolicy=IfNotPresent --wait=false 2>&1 | Out-Null
        }

        function Deploy-Redis {
            param([string]$Namespace)
            Write-Host "[+] Starting Redis..." -ForegroundColor Green
            helm upgrade --install redis bitnami/redis --version 23.2.1 --namespace $Namespace --create-namespace --set auth.enabled=false --set architecture=standalone --set master.persistence.enabled=false --set image.pullPolicy=IfNotPresent --wait=false 2>&1 | Out-Null
        }

        function Remove-Service {
            param([string]$ServiceName, [string]$Namespace)
            Write-Host "[-] Stopping $ServiceName..." -ForegroundColor Red
            helm uninstall $ServiceName -n $Namespace 2>&1 | Out-Null
        }

        function Reconcile-Services {
            param([hashtable]$EnvVars)
            $namespace = $EnvVars['K8S_NAMESPACE']
            $changes = @()

            # PostgreSQL
            $postgresEnabled = $EnvVars['POSTGRESQL_ENABLED'] -ne 'False'
            $postgresRunning = $null -ne (Test-HelmRelease -ReleaseName "postgresql" -Namespace $namespace)
            if ($postgresEnabled -and -not $postgresRunning) {
                Deploy-PostgreSQL -Namespace $namespace
                $changes += "PostgreSQL STARTED"
            } elseif (-not $postgresEnabled -and $postgresRunning) {
                Remove-Service -ServiceName "postgresql" -Namespace $namespace
                $changes += "PostgreSQL STOPPED"
            }

            # Redis
            $redisEnabled = $EnvVars['REDIS_ENABLED'] -ne 'False'
            $redisRunning = $null -ne (Test-HelmRelease -ReleaseName "redis" -Namespace $namespace)
            if ($redisEnabled -and -not $redisRunning) {
                Deploy-Redis -Namespace $namespace
                $changes += "Redis STARTED"
            } elseif (-not $redisEnabled -and $redisRunning) {
                Remove-Service -ServiceName "redis" -Namespace $namespace
                $changes += "Redis STOPPED"
            }

            return $changes
        }

        # Initial reconciliation
        Write-Host "[*] Initial service reconciliation..." -ForegroundColor Yellow
        $envVars = Load-EnvFile
        $changes = Reconcile-Services -EnvVars $envVars
        if ($changes.Count -gt 0) {
            $changes | ForEach-Object { Write-Host "  $_" -ForegroundColor Cyan }
        }
        Write-Host ""

        # Store the initial hash of .env file
        $script:envHash = (Get-FileHash .env -Algorithm MD5).Hash
        $script:skaffoldJob = $null

        try {
            while ($true) {
                # Start skaffold if not running
                if ($null -eq $script:skaffoldJob -or $script:skaffoldJob.State -ne 'Running') {
                    Get-Job | Where-Object { $_.State -ne 'Running' } | Remove-Job -Force -ErrorAction SilentlyContinue

                    Write-Host "[>>] Starting Skaffold dev..." -ForegroundColor Green
                    $script:skaffoldJob = Start-Job -ScriptBlock {
                        Set-Location $using:PWD
                        Get-Content .env | ForEach-Object {
                            if ($_ -match '^\s*([^#][^=]+)=(.*)$') {
                                $name = $matches[1].Trim()
                                $value = $matches[2].Trim()
                                Set-Item -Path "env:$name" -Value $value
                            }
                        }
                        # Use API-only config since PostgreSQL/Redis are managed separately
                        skaffold dev -f skaffold-api-only.yaml 2>&1
                    }
                    Write-Host "[*] Skaffold started" -ForegroundColor Gray
                    Start-Sleep -Seconds 3
                }

                # Check for .env file changes every 2 seconds
                Start-Sleep -Seconds 2

                if (Test-Path .env) {
                    $currentHash = (Get-FileHash .env -Algorithm MD5).Hash

                    if ($currentHash -ne $script:envHash) {
                        Write-Host ""
                        Write-Host "[!] .env file changed!" -ForegroundColor Yellow

                        # Stop skaffold
                        if ($script:skaffoldJob) {
                            Stop-Job -Job $script:skaffoldJob -ErrorAction SilentlyContinue
                            Remove-Job -Job $script:skaffoldJob -Force -ErrorAction SilentlyContinue
                        }
                        Get-Process skaffold -ErrorAction SilentlyContinue | Stop-Process -Force

                        # Update hash and reload env
                        $script:envHash = $currentHash
                        $envVars = Load-EnvFile

                        # Reconcile services based on new flags
                        Write-Host "[*] Reconciling services..." -ForegroundColor Yellow
                        $changes = Reconcile-Services -EnvVars $envVars

                        if ($changes.Count -gt 0) {
                            Write-Host "[OK] Changes:" -ForegroundColor Green
                            $changes | ForEach-Object { Write-Host "  $_" -ForegroundColor Cyan }
                        }

                        Write-Host "[*] Restarting Skaffold dev..." -ForegroundColor Green
                        Write-Host ""
                        Start-Sleep -Seconds 2
                        $script:skaffoldJob = $null
                    }
                }

                # Show job output
                if ($script:skaffoldJob) {
                    $output = Receive-Job -Job $script:skaffoldJob
                    if ($output) {
                        $output | ForEach-Object { Write-Host $_ }
                    }
                }
            }
        }
        finally {
            Write-Host ""
            Write-Host "[*] Cleaning up..." -ForegroundColor Yellow

            # Stop Skaffold job
            if ($script:skaffoldJob) {
                Stop-Job -Job $script:skaffoldJob -ErrorAction SilentlyContinue
                Remove-Job -Job $script:skaffoldJob -Force -ErrorAction SilentlyContinue
            }
            Get-Process skaffold -ErrorAction SilentlyContinue | Stop-Process -Force

            # Delete all running Kubernetes resources (pods, services, deployments, etc.)
            Write-Host "[*] Removing all running services..." -ForegroundColor Yellow
            kubectl delete all --all -n $env:K8S_NAMESPACE 2>&1 | Out-Null

            Write-Host "[OK] Cleanup complete!" -ForegroundColor Green
        }
    }
    default {
        Write-Host "[ERROR] Invalid choice" -ForegroundColor Red
        exit 1
    }
}
