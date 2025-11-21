# Quick start script for deploying EASM with Skaffold (PowerShell)
# Supports auto-reload when .env file changes

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

# Function to load environment variables from .env file
function Load-EnvFile {
    $envVars = @{}
    if (Test-Path .env) {
        Get-Content .env | ForEach-Object {
            if ($_ -match '^\s*([^#][^=]+)=(.*)$') {
                $name = $matches[1].Trim()
                $value = $matches[2].Trim()
                $envVars[$name] = $value
                [Environment]::SetEnvironmentVariable($name, $value, 'Process')
                Write-Host "  [+] Set $name" -ForegroundColor Gray
            }
        }
    }
    return $envVars
}

$envFile = Load-EnvFile
if (-not $envFile) {
    Write-Host "[ERROR] Failed to load environment variables from .env file" -ForegroundColor Red
}

# Check if Kubernetes is running
$k8sRunning = $false
$null = kubectl cluster-info 2>&1
if ($LASTEXITCODE -eq 0) {
    $k8sRunning = $true
    Write-Host "[OK] Kubernetes cluster is running" -ForegroundColor Green
}

if (-not $k8sRunning) {
    Write-Host "[WARNING] Kubernetes cluster is not running!" -ForegroundColor Yellow
    Write-Host ""

    # Check if minikube is available
    $minikubeAvailable = Get-Command minikube -ErrorAction SilentlyContinue

    if ($minikubeAvailable) {
        Write-Host "[*] Attempting to start Minikube with Docker driver..." -ForegroundColor Cyan
        Write-Host "[*] This may take a few minutes..." -ForegroundColor Yellow

        # Start minikube and wait for it to be ready
        minikube start --driver=docker

        if ($LASTEXITCODE -ne 0) {
            Write-Host ""
            Write-Host "[ERROR] Failed to start Minikube" -ForegroundColor Red
            Write-Host ""
            Write-Host "Please start your cluster manually:"
            Write-Host "  - Minikube: minikube start --driver=docker"
            Write-Host "  - Docker Desktop: Enable Kubernetes in settings"
            Write-Host "  - Kind: kind create cluster"
            exit 1
        }

        # Wait for kubectl to be able to connect
        Write-Host "[*] Waiting for Kubernetes to be ready..." -ForegroundColor Yellow
        $maxRetries = 30
        $retryCount = 0
        $kubectlReady = $false

        while (-not $kubectlReady -and $retryCount -lt $maxRetries) {
            $null = kubectl cluster-info 2>&1
            if ($LASTEXITCODE -eq 0) {
                $kubectlReady = $true
                Write-Host ""
                Write-Host "[OK] Minikube started successfully" -ForegroundColor Green
            } else {
                $retryCount++
                Start-Sleep -Seconds 2
                Write-Host "." -NoNewline -ForegroundColor Gray
            }
        }

        if (-not $kubectlReady) {
            Write-Host ""
            Write-Host "[ERROR] Kubernetes cluster did not become ready in time" -ForegroundColor Red
            Write-Host ""
            Write-Host "Please check the status manually:"
            Write-Host "  - Check Minikube: minikube status"
            Write-Host "  - Check kubectl: kubectl cluster-info"
            exit 1
        }
    } else {
        Write-Host "[ERROR] Minikube not found!" -ForegroundColor Red
        Write-Host "Please install Minikube or start your cluster manually:"
        Write-Host "  - Install Minikube: https://minikube.sigs.k8s.io/docs/start/"
        Write-Host "  - Docker Desktop: Enable Kubernetes in settings"
        Write-Host "  - Kind: kind create cluster"
        exit 1
    }
}

Write-Host ""

# Add Bitnami repo if not already added
try {
    $helmReposList = helm repo list 2>&1
    $helmRepos = $helmReposList | Out-String
} catch {
    $helmRepos = ""
}

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
$mongodbPort = if ($env:MONGODB_LOCAL_PORT) { $env:MONGODB_LOCAL_PORT } else { "27017" }

# Show port configuration
Write-Host "Port Forwarding Configuration:" -ForegroundColor Cyan
Write-Host "   API:        localhost:$apiPort -> container:8000" -ForegroundColor White
Write-Host "   PostgreSQL: localhost:$postgresPort -> container:5432" -ForegroundColor White
Write-Host "   Redis:      localhost:$redisPort -> container:6379" -ForegroundColor White
Write-Host "   MongoDB:    localhost:$mongodbPort -> container:27017" -ForegroundColor White
Write-Host ""

# Generate temporary values file for ALLOWED_HOSTS (handles commas properly)
Write-Host "[*] Generating values file for comma-separated configs..." -ForegroundColor Yellow
$allowedHosts = if ($env:ALLOWED_HOSTS) { $env:ALLOWED_HOSTS } else { "localhost,127.0.0.1" }
$valuesContent = @"
# Auto-generated from .env
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
Write-Host "  5) DEBUG mode (skaffold dev --cleanup=false --status-check=false)"
Write-Host "  6) Auto-watch mode (.env changes trigger redeploy)"
Write-Host ""

$choice = Read-Host "Enter your choice (1-6)"

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

        function Deploy-MongoDB {
            param([string]$Namespace)
            Write-Host "[+] Starting MongoDB..." -ForegroundColor Green
            helm upgrade --install mongodb bitnami/mongodb --version 16.3.1 --namespace $Namespace --create-namespace --set auth.rootPassword=easm_password --set auth.username=easm_user --set auth.password=easm_password --set auth.database=easm_db --set persistence.enabled=false --set image.tag=latest --set image.pullPolicy=IfNotPresent --wait=false 2>&1 | Out-Null
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
            $postgresRelease = Test-HelmRelease -ReleaseName "postgresql" -Namespace $namespace
            $postgresPods = kubectl get pods -n $namespace -l app.kubernetes.io/name=postgresql -o json 2>&1 | ConvertFrom-Json
            $postgresRunning = ($null -ne $postgresRelease) -and ($postgresPods.items.Count -gt 0)

            if ($postgresEnabled -and -not $postgresRunning) {
                Deploy-PostgreSQL -Namespace $namespace
                $changes += "PostgreSQL STARTED"
            } elseif (-not $postgresEnabled -and $postgresRunning) {
                Remove-Service -ServiceName "postgresql" -Namespace $namespace
                $changes += "PostgreSQL STOPPED"
            }

            # Redis
            $redisEnabled = $EnvVars['REDIS_ENABLED'] -ne 'False'
            $redisRelease = Test-HelmRelease -ReleaseName "redis" -Namespace $namespace
            $redisPods = kubectl get pods -n $namespace -l app.kubernetes.io/name=redis -o json 2>&1 | ConvertFrom-Json
            $redisRunning = ($null -ne $redisRelease) -and ($redisPods.items.Count -gt 0)

            if ($redisEnabled -and -not $redisRunning) {
                Deploy-Redis -Namespace $namespace
                $changes += "Redis STARTED"
            } elseif (-not $redisEnabled -and $redisRunning) {
                Remove-Service -ServiceName "redis" -Namespace $namespace
                $changes += "Redis STOPPED"
            }

            # MongoDB
            $mongoEnabled = $EnvVars['MONGODB_ENABLED'] -ne 'False'
            $mongoRelease = Test-HelmRelease -ReleaseName "mongodb" -Namespace $namespace
            $mongoPods = kubectl get pods -n $namespace -l app.kubernetes.io/name=mongodb -o json 2>&1 | ConvertFrom-Json
            $mongoRunning = ($null -ne $mongoRelease) -and ($mongoPods.items.Count -gt 0)

            if ($mongoEnabled -and -not $mongoRunning) {
                Deploy-MongoDB -Namespace $namespace
                $changes += "MongoDB STARTED"
            } elseif (-not $mongoEnabled -and $mongoRunning) {
                Remove-Service -ServiceName "mongodb" -Namespace $namespace
                $changes += "MongoDB STOPPED"
            }

            return $changes
        }

        function Wait-ForInfrastructure {
            param([hashtable]$EnvVars)

            $namespace = $EnvVars['K8S_NAMESPACE']

            # Only wait if API is enabled
            if ($EnvVars['EASM_API_ENABLED'] -eq 'False') {
                return $true
            }

            Write-Host "[*] Waiting for infrastructure services..." -ForegroundColor Yellow
            Start-Sleep -Seconds 10
            Write-Host "[OK] Ready" -ForegroundColor Green
            return $true
        }

        # Initial reconciliation
        Write-Host "[*] Initial service reconciliation..." -ForegroundColor Yellow
        $envVars = Load-EnvFile
        Write-Host "[DEBUG] POSTGRESQL_ENABLED=$($envVars['POSTGRESQL_ENABLED']), REDIS_ENABLED=$($envVars['REDIS_ENABLED']), MONGODB_ENABLED=$($envVars['MONGODB_ENABLED']), EASM_API_ENABLED=$($envVars['EASM_API_ENABLED'])" -ForegroundColor DarkGray

        $changes = Reconcile-Services -EnvVars $envVars
        if ($changes.Count -gt 0) {
            Write-Host "[OK] Changes applied:" -ForegroundColor Green
            $changes | ForEach-Object { Write-Host "  $_" -ForegroundColor Cyan }
        } else {
            Write-Host "[OK] All services already in desired state" -ForegroundColor Gray
        }
        Write-Host ""

        # Wait for enabled infrastructure services to be ready before starting API
        Wait-ForInfrastructure -EnvVars $envVars | Out-Null        # Store the initial hash of .env file
        $script:envHash = (Get-FileHash .env -Algorithm MD5).Hash
        $script:skaffoldJob = $null

        try {
            while ($true) {
                # Check if API should be running
                $apiEnabled = $envVars['EASM_API_ENABLED'] -ne 'False'

                # Start skaffold if not running AND API is enabled
                if ($apiEnabled -and ($null -eq $script:skaffoldJob -or $script:skaffoldJob.State -ne 'Running')) {
                    Get-Job | Where-Object { $_.State -ne 'Running' } | Remove-Job -Force -ErrorAction SilentlyContinue

                    Write-Host "[>>] Starting Skaffold dev (EASM API)..." -ForegroundColor Green
                    $script:skaffoldJob = Start-Job -ScriptBlock {
                        Set-Location $using:PWD
                        Get-Content .env | ForEach-Object {
                            if ($_ -match '^\s*([^#][^=]+)=(.*)$') {
                                $name = $matches[1].Trim()
                                $value = $matches[2].Trim()
                                Set-Item -Path "env:$name" -Value $value
                            }
                        }
                        # Use API-only config since PostgreSQL/Redis/MongoDB are managed separately
                        skaffold dev -f skaffold-api-only.yaml 2>&1
                    }
                    Write-Host "[*] Skaffold started" -ForegroundColor Gray
                    Start-Sleep -Seconds 3
                } elseif (-not $apiEnabled -and $script:skaffoldJob -and $script:skaffoldJob.State -eq 'Running') {
                    # Stop Skaffold if API is disabled
                    Write-Host "[*] API disabled, stopping Skaffold..." -ForegroundColor Yellow
                    Stop-Job -Job $script:skaffoldJob -ErrorAction SilentlyContinue
                    Remove-Job -Job $script:skaffoldJob -Force -ErrorAction SilentlyContinue
                    Get-Process skaffold -ErrorAction SilentlyContinue | Stop-Process -Force
                    $script:skaffoldJob = $null
                }

                # Show status if API is disabled
                if (-not $apiEnabled) {
                    Write-Host "`r[*] API disabled - watching for .env changes..." -NoNewline -ForegroundColor DarkGray
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
                            Write-Host ""

                            # Wait for infrastructure to be ready before restarting API
                            Wait-ForInfrastructure -EnvVars $envVars | Out-Null
                        }                        Write-Host "[*] Restarting Skaffold dev..." -ForegroundColor Green
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
        Cleanup-TempFiles
        exit 1
    }
}
