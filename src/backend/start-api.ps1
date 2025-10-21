# PowerShell script to start the Django API

Write-Host "Starting Django API..." -ForegroundColor Green

# Set default environment variables if not set
if (-not $env:POSTGRES_HOST) { $env:POSTGRES_HOST = "localhost" }
if (-not $env:POSTGRES_PORT) { $env:POSTGRES_PORT = "5432" }
if (-not $env:REDIS_HOST) { $env:REDIS_HOST = "localhost" }
if (-not $env:REDIS_PORT) { $env:REDIS_PORT = "6379" }
if (-not $env:GUNICORN_WORKERS) { $env:GUNICORN_WORKERS = "4" }

# Wait for PostgreSQL
Write-Host "Waiting for PostgreSQL..." -ForegroundColor Yellow
$maxAttempts = 30
$attempt = 0
while ($attempt -lt $maxAttempts) {
    try {
        $tcpClient = New-Object System.Net.Sockets.TcpClient
        $tcpClient.Connect($env:POSTGRES_HOST, $env:POSTGRES_PORT)
        $tcpClient.Close()
        Write-Host "PostgreSQL is ready!" -ForegroundColor Green
        break
    }
    catch {
        $attempt++
        Start-Sleep -Milliseconds 100
    }
}

# Wait for Redis
Write-Host "Waiting for Redis..." -ForegroundColor Yellow
$attempt = 0
while ($attempt -lt $maxAttempts) {
    try {
        $tcpClient = New-Object System.Net.Sockets.TcpClient
        $tcpClient.Connect($env:REDIS_HOST, $env:REDIS_PORT)
        $tcpClient.Close()
        Write-Host "Redis is ready!" -ForegroundColor Green
        break
    }
    catch {
        $attempt++
        Start-Sleep -Milliseconds 100
    }
}

# Run migrations
Write-Host "Running database migrations..." -ForegroundColor Yellow
python manage.py migrate --noinput

# Collect static files
Write-Host "Collecting static files..." -ForegroundColor Yellow
python manage.py collectstatic --noinput

# Create superuser if it doesn't exist
Write-Host "Creating superuser..." -ForegroundColor Yellow
python manage.py shell -c @"
from django.contrib.auth import get_user_model
User = get_user_model()
if not User.objects.filter(username='admin').exists():
    User.objects.create_superuser('admin', 'admin@example.com', 'admin123')
    print('Superuser created')
else:
    print('Superuser already exists')
"@

# Start Gunicorn
Write-Host "Starting Gunicorn on 0.0.0.0:8000 with $env:GUNICORN_WORKERS workers..." -ForegroundColor Green
gunicorn config.wsgi:application `
    --bind 0.0.0.0:8000 `
    --workers $env:GUNICORN_WORKERS `
    --reload `
    --access-logfile - `
    --error-logfile - `
    --log-level info
