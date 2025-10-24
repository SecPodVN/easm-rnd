# EASM Django REST API - Quick Start Guide

## Prerequisites Check

Before starting, ensure you have:
- [ ] Python 3.13 installed
- [ ] Poetry installed
- [ ] Docker installed
- [ ] Docker Compose installed
- [ ] (Optional) Minikube installed
- [ ] (Optional) kubectl installed
- [ ] (Optional) Helm 3 installed
- [ ] (Optional) Skaffold installed

## Quick Setup (5 minutes)

### Option 1: Docker Compose (Recommended for Quick Start)

```powershell
# 1. Clone or navigate to the project
cd c:\Working\EASM\easm-rnd

# 2. Copy environment file
Copy-Item .env.example .env

# 3. Start all services
docker-compose up --build -d

# 4. Wait for services to start (30 seconds)
Start-Sleep -Seconds 30

# 5. Run migrations
docker-compose exec web python manage.py migrate

# 6. Create superuser (interactive)
docker-compose exec web python manage.py createsuperuser

# 7. Access the application
# API: http://localhost:8000
# Admin: http://localhost:8000/admin
# API Docs: http://localhost:8000/api/docs/
```

### Option 2: Local Development

```powershell
# 1. Install dependencies
poetry install

# 2. Start PostgreSQL and Redis (via Docker)
docker-compose up -d postgres redis

# 3. Copy and edit environment file
Copy-Item .env.example .env
# Edit .env and set:
# POSTGRES_HOST=localhost
# REDIS_HOST=localhost

# 4. Run migrations
poetry run python manage.py migrate

# 5. Create superuser
poetry run python manage.py createsuperuser

# 6. Run development server
poetry run python manage.py runserver
```

### Option 3: Kubernetes with Minikube

```powershell
# 1. Start Minikube
minikube start

# 2. Enable ingress
minikube addons enable ingress

# 3. Deploy infra
kubectl apply -f k8s/deployment.yaml

# 4. Build and deploy with Skaffold
skaffold dev

# 5. Access the application
minikube service easm-api
```

## First API Calls

### 1. Get JWT Token

```powershell
# Create token request
$body = @{
    username = "your_username"
    password = "your_password"
} | ConvertTo-Json

# Get token
$response = Invoke-RestMethod -Uri "http://localhost:8000/api/token/" -Method Post -Body $body -ContentType "application/json"
$token = $response.access

Write-Host "Token: $token"
```

### 2. Create a Todo

```powershell
# Create todo
$headers = @{
    Authorization = "Bearer $token"
}

$todoBody = @{
    title = "My First Todo"
    description = "This is a test todo"
    status = "pending"
    priority = "high"
} | ConvertTo-Json

$todo = Invoke-RestMethod -Uri "http://localhost:8000/api/todos/" -Method Post -Headers $headers -Body $todoBody -ContentType "application/json"

Write-Host "Created todo with ID: $($todo.id)"
```

### 3. List Todos

```powershell
# Get all todos
$todos = Invoke-RestMethod -Uri "http://localhost:8000/api/todos/" -Method Get -Headers $headers

Write-Host "Total todos: $($todos.count)"
$todos.results | Format-Table id, title, status, priority
```

## Verification Steps

### Check Services Status

```powershell
# Docker Compose
docker-compose ps

# Kubernetes
kubectl get pods -n easm
kubectl get services -n easm
```

### Check Logs

```powershell
# Docker Compose
docker-compose logs -f web

# Kubernetes
kubectl logs -f deployment/easm-api
```

### Test Endpoints

```powershell
# Health check (API docs)
Invoke-WebRequest -Uri "http://localhost:8000/api/docs/"

# Admin panel
Start-Process "http://localhost:8000/admin"

# API Documentation
Start-Process "http://localhost:8000/api/docs/"
```

## Common Issues and Solutions

### Issue: Port 8000 already in use
```powershell
# Find and kill process using port 8000
Get-Process -Id (Get-NetTCPConnection -LocalPort 8000).OwningProcess | Stop-Process

# Or change port in docker-compose.yml or manage.py
```

### Issue: Database connection error
```powershell
# Check if PostgreSQL is running
docker-compose ps postgres

# Restart PostgreSQL
docker-compose restart postgres

# Check logs
docker-compose logs postgres
```

### Issue: Redis connection error
```powershell
# Check if Redis is running
docker-compose ps redis

# Restart Redis
docker-compose restart redis
```

### Issue: Migration errors
```powershell
# Reset migrations
docker-compose exec web python manage.py migrate --fake todos zero
docker-compose exec web python manage.py migrate
```

### Issue: Permission denied on docker-entrypoint.sh
```powershell
# On Windows, ensure line endings are LF not CRLF
# In git bash:
dos2unix docker-entrypoint.sh

# Or rebuild image
docker-compose build --no-cache
```

## Next Steps

1. **Explore the API**
   - Open http://localhost:8000/api/docs/
   - Try the interactive Swagger UI

2. **Read Documentation**
   - API-DOCUMENTATION.md - Detailed API guide
   - DJANGO-API-README.md - Development guide

3. **Customize Settings**
   - Edit `.env` file for configuration
   - Modify `src/backend/easm/settings.py` for advanced settings

4. **Add Features**
   - Create new Django apps
   - Add custom endpoints
   - Implement additional models

5. **Deploy to Production**
   - Use Helm chart with custom values
   - Configure ingress and TLS
   - Set up monitoring and logging

## Useful Commands

```powershell
# Docker Compose
docker-compose up -d              # Start services
docker-compose down               # Stop services
docker-compose logs -f web        # View logs
docker-compose exec web bash      # Enter container
docker-compose restart web        # Restart service

# Poetry
poetry install                    # Install dependencies
poetry add package-name           # Add dependency
poetry update                     # Update dependencies
poetry run python manage.py shell # Django shell

# Django
poetry run python manage.py makemigrations
poetry run python manage.py migrate
poetry run python manage.py createsuperuser
poetry run python manage.py collectstatic
poetry run python manage.py runserver

# Kubernetes
kubectl get pods
kubectl get services
kubectl logs -f pod-name
kubectl describe pod pod-name
kubectl port-forward svc/easm-api 8000:8000

# Helm
helm install easm-api ./charts/easm-api
helm upgrade easm-api ./charts/easm-api
helm uninstall easm-api
helm list

# Skaffold
skaffold dev       # Development mode
skaffold run       # Build and deploy
skaffold delete    # Delete deployment
```

## Support Resources

- **Main README**: Project overview and features
- **API Documentation**: Complete API reference
- **Django Docs**: https://docs.djangoproject.com/
- **DRF Docs**: https://www.django-rest-framework.org/
- **Docker Docs**: https://docs.docker.com/
- **Kubernetes Docs**: https://kubernetes.io/docs/

## Getting Help

If you encounter issues:

1. Check the logs
2. Review the documentation
3. Verify prerequisites are installed
4. Check environment variables
5. Try rebuilding containers

Happy coding! 🚀
