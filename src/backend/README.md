# EASM Backend

Django REST API backend for the EASM platform.

## 📁 Structure

```
backend/
├── easm/                      # Base Django application
│   ├── apps/                  # Django applications
│   │   ├── api/               # REST API endpoints
│   │   ├── scanner/           # Security scanner
│   │   └── todos/             # Todo management
│   ├── config/                # Django project configuration
│   │   ├── settings.py        # Django settings
│   │   ├── urls.py            # URL routing
│   │   └── wsgi.py            # WSGI config
│   ├── manage.py              # Django management script
│   ├── pyproject.toml         # Poetry dependencies
│   └── pytest.ini             # Pytest configuration
│
├── easm-core/                 # Shared core libraries and utilities
│   └── (future shared utilities)
│
├── Dockerfile                 # Docker build configuration
├── docker-compose.yml         # Local development setup
├── docker-entrypoint.sh       # Docker entrypoint script
├── start-api.sh               # API startup script (Linux/Mac)
├── start-api.ps1              # API startup script (Windows)
├── requirements.txt           # Python dependencies (fallback)
├── schema.yml                 # API schema definition
├── k8s/                       # Kubernetes manifests
└── README.md                  # This file
```

## 🚀 Quick Start

### Using Docker Compose

```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f api

# Run migrations
docker-compose exec api sh -c "cd easm && python manage.py migrate"

# Create superuser
docker-compose exec api sh -c "cd easm && python manage.py createsuperuser"

# Stop services
docker-compose down
```

### Local Development (without Docker)

```bash
# Navigate to the easm directory
cd easm

# Install dependencies using Poetry
poetry install

# Activate virtual environment
poetry shell

# Run migrations
python manage.py migrate

# Create superuser
python manage.py createsuperuser

# Run development server
python manage.py runserver
```

### Using PowerShell (Windows)

```powershell
# Start the API server
.\start-api.ps1
```

### Using Bash (Linux/Mac)

```bash
# Make the script executable
chmod +x start-api.sh

# Start the API server
./start-api.sh
```

## 📝 Environment Variables

Copy `.env.example` to `.env` and update the values:

```bash
cp .env.example .env
```

Key environment variables:
- `SECRET_KEY` - Django secret key
- `DEBUG` - Debug mode (True/False)
- `POSTGRES_*` - PostgreSQL connection settings
- `REDIS_*` - Redis connection settings
- `MONGODB_*` - MongoDB connection settings (optional)

## 🧪 Testing

```bash
# Navigate to easm directory
cd easm

# Run all tests
poetry run pytest

# Run with coverage
poetry run pytest --cov=apps

# Run specific app tests
poetry run pytest apps/api/tests.py
```

## 📚 API Documentation

Once the server is running, access the API documentation at:

- **Swagger UI**: http://localhost:8000/api/docs/
- **ReDoc**: http://localhost:8000/api/redoc/
- **OpenAPI Schema**: http://localhost:8000/api/schema/

## 🔧 Management Commands

### Database Commands

```bash
cd easm

# Run migrations
python manage.py migrate

# Create migrations
python manage.py makemigrations

# Create superuser
python manage.py createsuperuser

# Database shell
python manage.py dbshell
```

### Seeding Data

```bash
cd easm

# Seed sample data
python manage.py seed_data

# Seed with custom parameters
python manage.py seed_data --users 10 --todos-per-user 20

# Clear seeded data
python manage.py clear_seed_data
```

## 🏗️ Project Structure Details

### easm/

The main Django application containing all project-specific code:

- **apps/** - Django applications following the app pattern
  - Each app is self-contained with models, views, serializers, etc.
  - Apps communicate through well-defined interfaces

- **config/** - Django project configuration
  - Central settings, URL routing, and WSGI configuration
  - Database routers for multi-database support

### easm-core/

Shared libraries and utilities that can be reused across different Django applications or projects:

- Core functionality independent of specific apps
- Utilities, helpers, and shared components
- Can be extracted as a separate package in the future

## 🐳 Docker

### Building the Image

```bash
docker build -t easm-backend:latest .
```

### Running with Docker

```bash
docker run -p 8000:8000 \
  -e POSTGRES_HOST=postgres \
  -e REDIS_HOST=redis \
  easm-backend:latest
```

## 📦 Dependencies

This project uses Poetry for dependency management. Key dependencies:

- Django 5.2+
- Django REST Framework
- PostgreSQL (psycopg2)
- Redis (django-redis)
- MongoDB (pymongo)
- JWT Authentication (djangorestframework-simplejwt)

See `easm/pyproject.toml` for the complete list.

## 🔐 Security

- JWT-based authentication
- CORS configuration
- Password validation
- SQL injection protection (Django ORM)
- Environment-based secrets management

## 📄 License

MIT License
