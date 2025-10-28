# EASM Django REST API - Documentation Index

Welcome to the EASM Django REST API documentation! This index will help you navigate all available documentation.

## 📚 Documentation Overview

This project includes comprehensive documentation covering setup, development, deployment, and API usage.

## 🗂️ Documentation Structure

### 1. Getting Started

#### 📖 [PROJECT-SUMMARY.md](PROJECT-SUMMARY.md)
**Start here!** Complete project overview with all features, structure, and quick commands.
- ✅ What's included
- ✅ Project structure
- ✅ Quick start options
- ✅ Key features
- ✅ Dependencies

#### 🚀 [QUICKSTART.md](QUICKSTART.md)
**Get running in 5 minutes!** Step-by-step guide to get the API running locally.
- Prerequisites checklist
- Three setup options (Docker, Local, Kubernetes)
- First API calls
- Troubleshooting common issues
- Useful commands

### 2. Development

#### 🔧 [DJANGO-API-README.md](DJANGO-API-README.md)
**Complete development guide** for working with the Django REST API.
- Installation steps
- Running the application
- Docker commands
- Kubernetes/Minikube commands
- Django management
- Testing
- Code quality tools

### 3. API Reference

#### 📡 [API-DOCUMENTATION.md](API-DOCUMENTATION.md)
**Complete API reference** with all endpoints, examples, and usage patterns.
- Authentication (JWT)
- All endpoints detailed
- Request/response examples
- Filtering, searching, sorting
- Pagination
- Error responses

#### 🔍 [SCANNER-API-DOCUMENTATION.md](SCANNER-API-DOCUMENTATION.md)
**Scanner app API reference** with MongoDB-based resource scanning endpoints.
- 11 REST endpoints for EASM scanning
- Resource, Rule, and Finding models
- Scanning engine capabilities
- Analytics and reporting
- Bulk operations

#### ⚡ [SCANNER-QUICKSTART.md](SCANNER-QUICKSTART.md)
**Quick start guide for Scanner API** with practical examples.
- Service health check
- Upload resources and rules
- Execute scans
- Query findings
- Real-world examples
- Python examples

### 4. Production

#### 🚢 [DEPLOYMENT.md](DEPLOYMENT.md)
**Production deployment guide** for deploying to various environments.
- Pre-deployment checklist
- Environment configuration
- Database setup (AWS RDS, GCP SQL, Azure)
- Docker deployment
- Kubernetes deployment
- Monitoring and logging
- Security hardening
- Backup and recovery

### 5. Interactive Documentation

#### 🌐 Swagger UI
Once running, visit: **http://localhost:8000/api/docs/**
- Interactive API testing
- Try endpoints directly
- See request/response formats
- Auto-generated from code

#### 📚 ReDoc
Once running, visit: **http://localhost:8000/api/redoc/**
- Beautiful API documentation
- Easy to navigate
- Alternative to Swagger UI

## 🎯 Quick Navigation by Task

### I want to...

#### ...get the API running quickly
→ Go to [QUICKSTART.md](QUICKSTART.md) → "Option 1: Docker Compose"

#### ...understand what's included
→ Go to [PROJECT-SUMMARY.md](PROJECT-SUMMARY.md) → "What's Included"

#### ...learn about the API endpoints
→ Go to [API-DOCUMENTATION.md](API-DOCUMENTATION.md) or http://localhost:8000/api/docs/

#### ...develop locally
→ Go to [DJANGO-API-README.md](DJANGO-API-README.md) → "Running the Application"

#### ...deploy to production
→ Go to [DEPLOYMENT.md](DEPLOYMENT.md) → Choose your platform

#### ...run tests
→ Go to [DJANGO-API-README.md](DJANGO-API-README.md) → "Testing"

#### ...troubleshoot issues
→ Go to [QUICKSTART.md](QUICKSTART.md) → "Common Issues and Solutions"

#### ...understand the project structure
→ Go to [PROJECT-SUMMARY.md](PROJECT-SUMMARY.md) → "Project Structure"

#### ...use Docker Compose
→ Go to [DJANGO-API-README.md](DJANGO-API-README.md) → "Docker Commands"

#### ...deploy with Kubernetes
→ Go to [DEPLOYMENT.md](DEPLOYMENT.md) → "Kubernetes Deployment"

#### ...work with the database
→ Go to [DJANGO-API-README.md](DJANGO-API-README.md) → "Database Setup"

#### ...configure environment variables
→ Go to [DEPLOYMENT.md](DEPLOYMENT.md) → "Environment Configuration"

## 📋 Technology-Specific Documentation

### Python/Django
- Django settings: `src/backend/easm/settings.py`
- Models: `todos/models.py`
- Views: `todos/views.py`
- Serializers: `todos/serializers.py`
- URL routing: `src/backend/easm/urls.py`

### Docker
- Dockerfile: `Dockerfile`
- Docker Compose: `docker-compose.yml`
- Entrypoint: `docker-entrypoint.sh`
- Ignore file: `.dockerignore`

### Kubernetes
- Manifests: `k8s/deployment.yaml`
- Helm Chart: `charts/easm-api/`
- Skaffold: `skaffold.yaml`

### Dependencies
- Poetry: `pyproject.toml`
- Requirements: `requirements.txt`
- Lock file: `poetry.lock`

### Configuration
- Environment: `.env.example`
- Pytest: `pytest.ini`
- Flake8: `.flake8`
- VS Code: `.vscode/settings.json`

## 🔍 Finding Specific Information

### Authentication
- Setup: [API-DOCUMENTATION.md](API-DOCUMENTATION.md) → "Authentication"
- JWT Config: `src/backend/easm/settings.py` → `SIMPLE_JWT`
- Token endpoints: `/api/token/` and `/api/token/refresh/`

### Database
- Configuration: [DEPLOYMENT.md](DEPLOYMENT.md) → "Database Setup"
- Models: `todos/models.py`
- Migrations: `python manage.py migrate`

### API Endpoints
- Full Reference: [API-DOCUMENTATION.md](API-DOCUMENTATION.md)
- Interactive Docs: http://localhost:8000/api/docs/
- URL Configuration: `src/backend/easm/urls.py`, `todos/urls.py`

### Docker
- Build: [DJANGO-API-README.md](DJANGO-API-README.md) → "Docker Commands"
- Compose: `docker-compose.yml`
- Production: [DEPLOYMENT.md](DEPLOYMENT.md) → "Docker Deployment"

### Kubernetes
- Local (Minikube): [QUICKSTART.md](QUICKSTART.md) → "Option 3"
- Production: [DEPLOYMENT.md](DEPLOYMENT.md) → "Kubernetes Deployment"
- Helm: `charts/easm-api/`

### Testing
- Run tests: [DJANGO-API-README.md](DJANGO-API-README.md) → "Testing"
- Test files: `tests/test_todos.py`
- Configuration: `pytest.ini`

### Configuration
- Environment: `.env.example`
- Django: `src/backend/easm/settings.py`
- Production: [DEPLOYMENT.md](DEPLOYMENT.md) → "Environment Configuration"

## 🛠️ Development Workflow

### Day-to-day Development
1. Start: `docker-compose up -d` or `poetry run python manage.py runserver`
2. Make changes to code
3. Test: `poetry run pytest`
4. Format: `poetry run black .`
5. Lint: `poetry run flake8`
6. Commit changes

### Adding Features
1. Read: [DJANGO-API-README.md](DJANGO-API-README.md)
2. Create Django app or modify existing
3. Add models, views, serializers
4. Write tests
5. Update documentation

### Deploying
1. Read: [DEPLOYMENT.md](DEPLOYMENT.md)
2. Configure environment
3. Build Docker image
4. Deploy with Helm or Docker Compose
5. Run migrations
6. Monitor logs

## 🎓 Learning Resources

### External Documentation
- [Django Documentation](https://docs.djangoproject.com/)
- [Django REST Framework](https://www.django-rest-framework.org/)
- [Poetry Documentation](https://python-poetry.org/docs/)
- [Docker Documentation](https://docs.docker.com/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Helm Documentation](https://helm.sh/docs/)

### Internal Documentation
- Code comments in Python files
- Docstrings in functions and classes
- README files in subdirectories
- Configuration files with comments

## 🆘 Getting Help

### Order of Operations
1. Check this index for relevant documentation
2. Read the specific documentation file
3. Check the interactive API docs
4. Review code comments and docstrings
5. Check logs: `docker-compose logs -f web`
6. Run verification: `.\verify-setup.ps1`

### Troubleshooting Resources
- [QUICKSTART.md](QUICKSTART.md) → "Common Issues and Solutions"
- [DJANGO-API-README.md](DJANGO-API-README.md) → "Troubleshooting"
- Logs: `docker-compose logs`, `kubectl logs`
- Health check: http://localhost:8000/health/

## 📝 Documentation Standards

All documentation follows these standards:
- Markdown format
- Clear headings and structure
- Code examples with syntax highlighting
- Step-by-step instructions
- Platform-specific commands (PowerShell for Windows)
- Links to related documentation

## 🔄 Keeping Documentation Updated

When making changes to the project:
1. Update relevant documentation files
2. Update code comments and docstrings
3. Update API documentation (Swagger annotations)
4. Update version numbers
5. Update CHANGELOG if applicable

## 📊 Documentation Metrics

- **Total Documentation Files**: 7
- **Total Pages**: ~150+ pages
- **Code Examples**: 100+
- **Commands Documented**: 200+
- **API Endpoints**: 11+

## ✨ Quick Reference Card

```
Essential URLs:
- API Docs:     http://localhost:8000/api/docs/
- Admin Panel:  http://localhost:8000/admin/
- Health Check: http://localhost:8000/health/
- ReDoc:        http://localhost:8000/api/redoc/

Essential Commands:
- Start:        docker-compose up -d
- Stop:         docker-compose down
- Logs:         docker-compose logs -f web
- Shell:        docker-compose exec web bash
- Migrations:   docker-compose exec web python manage.py migrate
- Tests:        poetry run pytest

Essential Files:
- Settings:     src/backend/easm/settings.py
- Models:       todos/models.py
- Views:        todos/views.py
- Environment:  .env (copy from .env.example)
```

## 🎉 Start Here

New to the project? Follow this path:

1. **Read**: [PROJECT-SUMMARY.md](PROJECT-SUMMARY.md) (5 min)
2. **Run**: `.\verify-setup.ps1` to check prerequisites
3. **Setup**: Follow [QUICKSTART.md](QUICKSTART.md) (10 min)
4. **Explore**: Open http://localhost:8000/api/docs/
5. **Learn**: Read [API-DOCUMENTATION.md](API-DOCUMENTATION.md)
6. **Develop**: Check [DJANGO-API-README.md](DJANGO-API-README.md)
7. **Deploy**: When ready, see [DEPLOYMENT.md](DEPLOYMENT.md)

---

**Happy coding!** 🚀

For questions or issues, refer to the specific documentation files listed above.
