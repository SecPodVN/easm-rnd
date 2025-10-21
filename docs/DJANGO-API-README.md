# Django REST API Setup

This document provides detailed instructions for setting up and running the EASM Django REST API.

## Installation Steps

### 1. Install Poetry

```bash
# Windows (PowerShell)
(Invoke-WebRequest -Uri https://install.python-poetry.org -UseBasicParsing).Content | python -

# Linux/macOS
curl -sSL https://install.python-poetry.org | python3 -

# Verify installation
poetry --version
```

### 2. Install Dependencies

```bash
# Install all dependencies
poetry install

# Install only production dependencies
poetry install --only main

# Add new dependency
poetry add package-name

# Add dev dependency
poetry add --group dev package-name
```

### 3. Database Setup

```bash
# Create migrations
poetry run python manage.py makemigrations

# Apply migrations
poetry run python manage.py migrate

# Create superuser
poetry run python manage.py createsuperuser
```

### 4. Collect Static Files

```bash
poetry run python manage.py collectstatic --noinput
```

## Running the Application

### Development Server

```bash
# Using Poetry
poetry run python manage.py runserver

# Using manage.py directly (if venv is activated)
python manage.py runserver 0.0.0.0:8000
```

### Production Server

```bash
# Using Gunicorn
poetry run gunicorn src.backend.easm.wsgi:application --bind 0.0.0.0:8000 --workers 4
```

## Docker Commands

### Build Image

```bash
docker build -t easm-api:latest .
```

### Run Container

```bash
docker run -p 8000:8000 --env-file .env easm-api:latest
```

### Docker Compose

```bash
# Start all services
docker-compose up -d

# Start and rebuild
docker-compose up --build

# Stop services
docker-compose down

# View logs
docker-compose logs -f

# Execute commands in container
docker-compose exec web python manage.py migrate
docker-compose exec web python manage.py createsuperuser
```

## Kubernetes/Minikube Commands

### Minikube Setup

```bash
# Start Minikube
minikube start --driver=docker

# Enable addons
minikube addons enable ingress
minikube addons enable metrics-server

# Check status
minikube status
```

### Deploy Infrastructure

```bash
# Deploy PostgreSQL and Redis
kubectl apply -f k8s/deployment.yaml

# Check deployments
kubectl get deployments -n easm
kubectl get pods -n easm
kubectl get services -n easm
```

### Helm Deployment

```bash
# Install chart
helm install easm-api ./charts/easm-api

# Upgrade chart
helm upgrade easm-api ./charts/easm-api

# Uninstall chart
helm uninstall easm-api

# Check release
helm list
helm status easm-api
```

### Skaffold Development

```bash
# Development mode (live reload)
skaffold dev

# Build and deploy
skaffold run

# Delete deployment
skaffold delete

# Debug
skaffold debug
```

## Useful Commands

### Django Management

```bash
# Create new app
poetry run python manage.py startapp app_name

# Shell
poetry run python manage.py shell

# Database shell
poetry run python manage.py dbshell

# Check for issues
poetry run python manage.py check

# Show migrations
poetry run python manage.py showmigrations

# SQL for migration
poetry run python manage.py sqlmigrate app_name migration_number
```

### Testing

```bash
# Run all tests
poetry run pytest

# Run specific test file
poetry run pytest tests/test_todos.py

# Run with coverage
poetry run pytest --cov=.

# Generate coverage report
poetry run pytest --cov=. --cov-report=html
```

### Code Quality

```bash
# Format code with Black
poetry run black .

# Check formatting
poetry run black --check .

# Lint with Flake8
poetry run flake8

# Type checking (if using mypy)
poetry run mypy .
```

## Environment Configuration

### Required Environment Variables

```bash
# Django
DEBUG=True
SECRET_KEY=your-secret-key
ALLOWED_HOSTS=localhost,127.0.0.1

# Database
POSTGRES_DB=easm_db
POSTGRES_USER=easm_user
POSTGRES_PASSWORD=easm_password
POSTGRES_HOST=localhost
POSTGRES_PORT=5432

# Redis
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_DB=0

# JWT
JWT_ACCESS_TOKEN_LIFETIME=60
JWT_REFRESH_TOKEN_LIFETIME=1440
```

## API Testing with curl

### Get Token

```bash
curl -X POST http://localhost:8000/api/token/ \
  -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "admin123"}'
```

### Create Todo

```bash
curl -X POST http://localhost:8000/api/todos/ \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Test Todo",
    "description": "This is a test",
    "status": "pending",
    "priority": "medium"
  }'
```

### Get Todos

```bash
curl -X GET http://localhost:8000/api/todos/ \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

### Update Todo

```bash
curl -X PATCH http://localhost:8000/api/todos/1/ \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"status": "completed"}'
```

### Delete Todo

```bash
curl -X DELETE http://localhost:8000/api/todos/1/ \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

## Troubleshooting

### Common Issues

1. **Module not found error**
   ```bash
   poetry install
   ```

2. **Database connection error**
   ```bash
   # Check if PostgreSQL is running
   docker-compose ps postgres
   
   # Check database settings in .env
   ```

3. **Redis connection error**
   ```bash
   # Check if Redis is running
   docker-compose ps redis
   ```

4. **Migration conflicts**
   ```bash
   # Reset migrations
   python manage.py migrate --fake app_name zero
   python manage.py migrate app_name
   ```

### Debug Mode

```bash
# Run with debug output
poetry run python manage.py runserver --verbosity 3

# Check Django settings
poetry run python manage.py diffsettings
```

## Additional Resources

- Django Documentation: https://docs.djangoproject.com/
- DRF Documentation: https://www.django-rest-framework.org/
- Poetry Documentation: https://python-poetry.org/docs/
- Kubernetes Documentation: https://kubernetes.io/docs/
- Helm Documentation: https://helm.sh/docs/
