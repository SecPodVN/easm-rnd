#!/usr/bin/env pwsh
# Skaffold Dev Helper - Loads ports from skaffold.env
# Usage: .\skdev.ps1 [additional skaffold arguments]

param(
    [Parameter(ValueFromRemainingArguments=$true)]
    $SkaffoldArgs
)

Write-Host "🚀 Starting Skaffold with environment-based port forwarding..." -ForegroundColor Cyan
Write-Host ""

# Load environment variables from skaffold.env
if (Test-Path "skaffold.env") {
    Write-Host "📝 Loading environment from skaffold.env..." -ForegroundColor Green
    Get-Content "skaffold.env" | Where-Object {
        $_ -notmatch '^\s*#' -and $_ -notmatch '^\s*$'
    } | ForEach-Object {
        $key, $value = $_ -split '=', 2
        [Environment]::SetEnvironmentVariable($key.Trim(), $value.Trim(), 'Process')
    }
} else {
    Write-Host "⚠️  Warning: skaffold.env not found, using default ports" -ForegroundColor Yellow
}

# Get port values from environment or use defaults
$apiPort = if ($env:API_LOCAL_PORT) { $env:API_LOCAL_PORT } else { "8000" }
$postgresPort = if ($env:POSTGRES_LOCAL_PORT) { $env:POSTGRES_LOCAL_PORT } else { "5432" }
$redisPort = if ($env:REDIS_LOCAL_PORT) { $env:REDIS_LOCAL_PORT } else { "6379" }

Write-Host "🔌 Port Forwarding Configuration:" -ForegroundColor Cyan
Write-Host "   API:        localhost:$apiPort → container:8000" -ForegroundColor White
Write-Host "   PostgreSQL: localhost:$postgresPort → container:5432" -ForegroundColor White
Write-Host "   Redis:      localhost:$redisPort → container:6379" -ForegroundColor White
Write-Host ""

# Build port forwarding argument
$portForwardArg = "${apiPort}:8000,${postgresPort}:5432,${redisPort}:6379"

Write-Host "▶️  Running: skaffold dev --port-forward-ports=$portForwardArg $SkaffoldArgs" -ForegroundColor Green
Write-Host ""

# Execute Skaffold
& skaffold dev --port-forward-ports=$portForwardArg @SkaffoldArgs
