# Auto-Watch Mode for EASM Services
# Monitors .env file and starts/stops services based on _ENABLED flags

Write-Host "=== EASM Auto-Watch Mode ===" -ForegroundColor Cyan
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

# Function to check if a Helm release is installed
function Test-HelmRelease {
    param([string]$ReleaseName, [string]$Namespace)
    $result = helm list -n $Namespace -o json 2>&1 | ConvertFrom-Json
    return $result | Where-Object { $_.name -eq $ReleaseName }
}

# Function to deploy PostgreSQL
function Deploy-PostgreSQL {
    param([string]$Namespace)
    Write-Host "[+] Deploying PostgreSQL..." -ForegroundColor Green
    helm upgrade --install postgresql `
        bitnami/postgresql `
        --version 18.1.1 `
        --namespace $Namespace `
        --create-namespace `
        --set auth.database=easm_db `
        --set auth.username=easm_user `
        --set auth.password=easm_password `
        --set primary.persistence.enabled=false `
        --set image.pullPolicy=IfNotPresent `
        --wait=false
}

# Function to deploy Redis
function Deploy-Redis {
    param([string]$Namespace)
    Write-Host "[+] Deploying Redis..." -ForegroundColor Green
    helm upgrade --install redis `
        bitnami/redis `
        --version 23.2.1 `
        --namespace $Namespace `
        --create-namespace `
        --set auth.enabled=false `
        --set architecture=standalone `
        --set master.persistence.enabled=false `
        --set image.pullPolicy=IfNotPresent `
        --wait=false
}

# Function to deploy EASM API
function Deploy-EasmApi {
    param([string]$Namespace, [hashtable]$EnvVars)
    Write-Host "[+] Deploying EASM API..." -ForegroundColor Green

    # Build the image first
    Write-Host "  [*] Building image..." -ForegroundColor Gray
    docker build -t easm-api:latest src/backend -q

    helm upgrade --install easm-api `
        src/charts/easm-api `
        --namespace $Namespace `
        --create-namespace `
        --set image.repository=easm-api `
        --set image.tag=latest `
        --set image.pullPolicy=Never `
        --set appVersion=$($EnvVars['API_APP_VERSION']) `
        --set postgresql.host=$($EnvVars['POSTGRES_HOST']) `
        --set postgresql.port=$($EnvVars['POSTGRES_PORT']) `
        --set postgresql.database=$($EnvVars['POSTGRES_DB']) `
        --set postgresql.username=$($EnvVars['POSTGRES_USER']) `
        --set postgresql.password=$($EnvVars['POSTGRES_PASSWORD']) `
        --set postgresql.enabled=$($EnvVars['POSTGRESQL_ENABLED']) `
        --set redis.host=$($EnvVars['REDIS_HOST']) `
        --set redis.port=$($EnvVars['REDIS_PORT']) `
        --set redis.db=$($EnvVars['REDIS_DB']) `
        --set redis.enabled=$($EnvVars['REDIS_ENABLED']) `
        --set easmApi.enabled=$($EnvVars['EASM_API_ENABLED']) `
        --set django.debug=$($EnvVars['DEBUG']) `
        --set django.secretKey=$($EnvVars['SECRET_KEY']) `
        --set jwt.accessTokenLifetime=$($EnvVars['JWT_ACCESS_TOKEN_LIFETIME']) `
        --set jwt.refreshTokenLifetime=$($EnvVars['JWT_REFRESH_TOKEN_LIFETIME']) `
        --set replicaCount=$($EnvVars['K8S_REPLICA_COUNT']) `
        --set postgresql.deploy=false `
        --set redis.deploy=false `
        --wait=false
}

# Function to remove a service
function Remove-Service {
    param([string]$ServiceName, [string]$Namespace)
    Write-Host "[-] Removing $ServiceName..." -ForegroundColor Red
    helm uninstall $ServiceName -n $Namespace 2>&1 | Out-Null
}

# Function to reconcile services based on flags
function Reconcile-Services {
    param([hashtable]$EnvVars, [hashtable]$CurrentState)

    $namespace = $EnvVars['K8S_NAMESPACE']
    $changes = @()

    # Check PostgreSQL
    $postgresEnabled = $EnvVars['POSTGRESQL_ENABLED'] -ne 'False'
    $postgresRunning = $null -ne (Test-HelmRelease -ReleaseName "postgresql" -Namespace $namespace)

    if ($postgresEnabled -and -not $postgresRunning) {
        Deploy-PostgreSQL -Namespace $namespace
        $changes += "PostgreSQL STARTED"
    } elseif (-not $postgresEnabled -and $postgresRunning) {
        Remove-Service -ServiceName "postgresql" -Namespace $namespace
        $changes += "PostgreSQL STOPPED"
    }

    # Check Redis
    $redisEnabled = $EnvVars['REDIS_ENABLED'] -ne 'False'
    $redisRunning = $null -ne (Test-HelmRelease -ReleaseName "redis" -Namespace $namespace)

    if ($redisEnabled -and -not $redisRunning) {
        Deploy-Redis -Namespace $namespace
        $changes += "Redis STARTED"
    } elseif (-not $redisEnabled -and $redisRunning) {
        Remove-Service -ServiceName "redis" -Namespace $namespace
        $changes += "Redis STOPPED"
    }

    # Check EASM API
    $apiEnabled = $EnvVars['EASM_API_ENABLED'] -ne 'False'
    $apiRunning = $null -ne (Test-HelmRelease -ReleaseName "easm-api" -Namespace $namespace)

    if ($apiEnabled -and -not $apiRunning) {
        Deploy-EasmApi -Namespace $namespace -EnvVars $EnvVars
        $changes += "EASM-API STARTED"
    } elseif ($apiEnabled -and $apiRunning) {
        # Always update if enabled (in case configs changed)
        Deploy-EasmApi -Namespace $namespace -EnvVars $EnvVars
        $changes += "EASM-API UPDATED"
    } elseif (-not $apiEnabled -and $apiRunning) {
        Remove-Service -ServiceName "easm-api" -Namespace $namespace
        $changes += "EASM-API STOPPED"
    }

    return $changes
}

# Main watch loop
Write-Host "[*] Loading initial configuration..." -ForegroundColor Yellow
$envVars = Load-EnvFile
$namespace = $envVars['K8S_NAMESPACE']

Write-Host "[*] Checking Kubernetes cluster..." -ForegroundColor Yellow
try {
    kubectl cluster-info 2>&1 | Out-Null
    Write-Host "[OK] Kubernetes cluster is running" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Kubernetes cluster is not running!" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "[*] Initial service reconciliation..." -ForegroundColor Yellow
$changes = Reconcile-Services -EnvVars $envVars -CurrentState @{}
if ($changes.Count -gt 0) {
    $changes | ForEach-Object { Write-Host "  $_" -ForegroundColor Cyan }
}

Write-Host ""
Write-Host "[>>] Watching .env for changes..." -ForegroundColor Green
Write-Host "[*] Current service status:" -ForegroundColor Cyan
Write-Host "    PostgreSQL: $(if ($envVars['POSTGRESQL_ENABLED'] -ne 'False') { 'ENABLED' } else { 'DISABLED' })" -ForegroundColor $(if ($envVars['POSTGRESQL_ENABLED'] -ne 'False') { 'Green' } else { 'Red' })
Write-Host "    Redis: $(if ($envVars['REDIS_ENABLED'] -ne 'False') { 'ENABLED' } else { 'DISABLED' })" -ForegroundColor $(if ($envVars['REDIS_ENABLED'] -ne 'False') { 'Green' } else { 'Red' })
Write-Host "    EASM-API: $(if ($envVars['EASM_API_ENABLED'] -ne 'False') { 'ENABLED' } else { 'DISABLED' })" -ForegroundColor $(if ($envVars['EASM_API_ENABLED'] -ne 'False') { 'Green' } else { 'Red' })
Write-Host ""
Write-Host "[*] Edit .env and save to trigger changes" -ForegroundColor Yellow
Write-Host "[*] Press Ctrl+C to stop" -ForegroundColor Yellow
Write-Host ""

$lastHash = (Get-FileHash .env -Algorithm MD5).Hash

try {
    while ($true) {
        Start-Sleep -Seconds 2

        if (Test-Path .env) {
            $currentHash = (Get-FileHash .env -Algorithm MD5).Hash

            if ($currentHash -ne $lastHash) {
                Write-Host ""
                Write-Host "[!] .env file changed detected!" -ForegroundColor Yellow
                $lastHash = $currentHash

                # Reload environment variables
                $envVars = Load-EnvFile

                Write-Host "[*] New service status:" -ForegroundColor Cyan
                Write-Host "    PostgreSQL: $(if ($envVars['POSTGRESQL_ENABLED'] -ne 'False') { 'ENABLED' } else { 'DISABLED' })" -ForegroundColor $(if ($envVars['POSTGRESQL_ENABLED'] -ne 'False') { 'Green' } else { 'Red' })
                Write-Host "    Redis: $(if ($envVars['REDIS_ENABLED'] -ne 'False') { 'ENABLED' } else { 'DISABLED' })" -ForegroundColor $(if ($envVars['REDIS_ENABLED'] -ne 'False') { 'Green' } else { 'Red' })
                Write-Host "    EASM-API: $(if ($envVars['EASM_API_ENABLED'] -ne 'False') { 'ENABLED' } else { 'DISABLED' })" -ForegroundColor $(if ($envVars['EASM_API_ENABLED'] -ne 'False') { 'Green' } else { 'Red' })

                # Reconcile services
                Write-Host "[*] Reconciling services..." -ForegroundColor Yellow
                $changes = Reconcile-Services -EnvVars $envVars -CurrentState @{}

                if ($changes.Count -gt 0) {
                    Write-Host ""
                    Write-Host "[OK] Changes applied:" -ForegroundColor Green
                    $changes | ForEach-Object { Write-Host "  $_" -ForegroundColor Cyan }
                } else {
                    Write-Host "[OK] No changes needed" -ForegroundColor Green
                }
                Write-Host ""
            }
        }
    }
} finally {
    Write-Host ""
    Write-Host "[*] Watch mode stopped" -ForegroundColor Yellow
}
