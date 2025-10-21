# EASM Django REST API

> 🚀 A production-ready Django REST API with JWT authentication, PostgreSQL, Redis, and Kubernetes deployment

[![Python](https://img.shields.io/badge/python-3.13-blue.svg)](https://www.python.org/)
[![Django](https://img.shields.io/badge/django-5.1-green.svg)](https://www.djangoproject.com/)
[![DRF](https://img.shields.io/badge/DRF-3.15-orange.svg)](https://www.django-rest-framework.org/)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

## 📖 Overview

This is a fully-featured Django REST API built with modern technologies and best practices. It includes a complete Todo management system with authentication, filtering, search, pagination, and comprehensive API documentation.

## ✨ Features

- 🔐 **JWT Authentication** - Secure token-based authentication
- 📝 **Todo Management** - Complete CRUD operations
- 🔍 **Advanced Filtering** - Filter by status, priority, search
- 📄 **Pagination** - Built-in pagination support
- 📚 **API Documentation** - Auto-generated Swagger UI & ReDoc
- 🐳 **Docker Ready** - Complete Docker & Docker Compose setup
- ☸️ **Kubernetes Ready** - Helm charts and Skaffold configuration
- ✅ **Testing** - Pytest with fixtures and coverage
- 🎨 **Code Quality** - Black formatting, Flake8 linting
- 📦 **Poetry** - Modern Python dependency management

## 🚀 Quick Start

### Prerequisites

- Python 3.13+
- Docker & Docker Compose
- Poetry (optional, for local development)

### 1. Verify Setup

```powershell
.\verify-setup.ps1
```

### 2. Start with Docker Compose

```powershell
# Copy environment file
Copy-Item .env.example .env

# Start all services
docker-compose up --build -d

# Run migrations
docker-compose exec web python manage.py migrate

# Create superuser
docker-compose exec web python manage.py createsuperuser
```

### 3. Access the API

- **API Documentation**: http://localhost:8000/api/docs/
- **Admin Panel**: http://localhost:8000/admin/
- **Health Check**: http://localhost:8000/health/

## 📁 Project Structure

```
easm-rnd/
├── src/backend/easm/      # Django project settings (NEW LOCATION)
├── todos/                 # Todo application
├── charts/easm-api/       # Helm chart (NEW LOCATION)
├── k8s/                   # Kubernetes manifests
├── tests/                 # Test suite
├── docker-compose.yml     # Docker Compose configuration
├── Dockerfile             # Production Docker image
├── skaffold.yaml          # Skaffold configuration
├── pyproject.toml         # Poetry dependencies
└── manage.py              # Django management script
```

## 🔑 API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/token/` | Obtain JWT token |
| POST | `/api/token/refresh/` | Refresh JWT token |
| GET | `/api/todos/` | List todos (paginated) |
| POST | `/api/todos/` | Create todo |
| GET | `/api/todos/{id}/` | Get todo detail |
| PUT | `/api/todos/{id}/` | Update todo |
| PATCH | `/api/todos/{id}/` | Partial update |
| DELETE | `/api/todos/{id}/` | Delete todo |
| POST | `/api/todos/{id}/complete/` | Mark as completed |
| GET | `/api/todos/statistics/` | Get statistics |

## 📚 Documentation

Comprehensive documentation is available:

- **[DOCUMENTATION-INDEX.md](DOCUMENTATION-INDEX.md)** - Complete documentation index
- **[PROJECT-SUMMARY.md](PROJECT-SUMMARY.md)** - Project overview and summary
- **[QUICKSTART.md](QUICKSTART.md)** - Get started in 5 minutes
- **[DJANGO-API-README.md](DJANGO-API-README.md)** - Development guide
- **[API-DOCUMENTATION.md](API-DOCUMENTATION.md)** - Complete API reference
- **[DEPLOYMENT.md](DEPLOYMENT.md)** - Production deployment guide

## 🛠️ Development

### Local Development

```powershell
# Install dependencies
poetry install

# Start services
docker-compose up -d postgres redis

# Run migrations
poetry run python manage.py migrate

# Run development server
poetry run python manage.py runserver
```

### Running Tests

```powershell
# Run all tests
poetry run pytest

# Run with coverage
poetry run pytest --cov=.

# Run specific test
poetry run pytest tests/test_todos.py
```

### Code Quality

```powershell
# Format code
poetry run black .

# Lint code
poetry run flake8
```

## 🐳 Docker Commands

```powershell
# Build and start
docker-compose up --build -d

# View logs
docker-compose logs -f web

# Stop services
docker-compose down

# Enter container
docker-compose exec web bash
```

## ☸️ Kubernetes Deployment

### Using Minikube

```powershell
# Start Minikube
minikube start

# Deploy infrastructure
kubectl apply -f k8s/deployment.yaml

# Deploy with Skaffold
skaffold dev
```

### Using Helm

```powershell
# Install chart
helm install easm-api ./charts/easm-api

# Upgrade chart
helm upgrade easm-api ./charts/easm-api

# Uninstall
helm uninstall easm-api
```

## 🔧 Configuration

### Environment Variables

Copy `.env.example` to `.env` and configure:

```env
DEBUG=True
SECRET_KEY=your-secret-key
ALLOWED_HOSTS=localhost,127.0.0.1

POSTGRES_DB=easm_db
POSTGRES_USER=easm_user
POSTGRES_PASSWORD=easm_password
POSTGRES_HOST=postgres
POSTGRES_PORT=5432

REDIS_HOST=redis
REDIS_PORT=6379
REDIS_DB=0

JWT_ACCESS_TOKEN_LIFETIME=60
JWT_REFRESH_TOKEN_LIFETIME=1440
```

## 📊 Example Usage

### Get JWT Token

```bash
curl -X POST http://localhost:8000/api/token/ \
  -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "password"}'
```

### Create Todo

```bash
curl -X POST http://localhost:8000/api/todos/ \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "My Todo",
    "description": "Description",
    "status": "pending",
    "priority": "high"
  }'
```

### List Todos

```bash
curl -X GET "http://localhost:8000/api/todos/?page=1" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

## 🧪 Testing

The project includes comprehensive tests:

- Unit tests for models
- API endpoint tests
- Authentication tests
- Filtering and search tests
- Pagination tests

Run tests with: `poetry run pytest`

## 🔒 Security

- JWT token authentication
- Password hashing
- CORS configuration
- Security middleware
- Environment-based configuration
- SQL injection prevention

## 📈 Performance

- Redis caching
- Database query optimization
- Connection pooling ready
- Gunicorn WSGI server
- Horizontal pod autoscaling (HPA)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Write/update tests
5. Ensure tests pass
6. Submit a pull request

## 📝 License

This project is licensed under the MIT License.

## 🆘 Support

- Check [DOCUMENTATION-INDEX.md](DOCUMENTATION-INDEX.md) for all documentation
- Read [QUICKSTART.md](QUICKSTART.md) for getting started
- See [API-DOCUMENTATION.md](API-DOCUMENTATION.md) for API reference
- Review [DEPLOYMENT.md](DEPLOYMENT.md) for production deployment

## 🙏 Acknowledgments

Built with:
- [Django](https://www.djangoproject.com/)
- [Django REST Framework](https://www.django-rest-framework.org/)
- [PostgreSQL](https://www.postgresql.org/)
- [Redis](https://redis.io/)
- [Docker](https://www.docker.com/)
- [Kubernetes](https://kubernetes.io/)
- [Helm](https://helm.sh/)
- [Poetry](https://python-poetry.org/)

---

**Made with ❤️ for EASM**

For detailed documentation, see [DOCUMENTATION-INDEX.md](DOCUMENTATION-INDEX.md)
