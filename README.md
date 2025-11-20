# easm-rnd

A modern monorepo application for External Attack Surface Management (EASM) Research and Development, built with Django REST API backend and React TypeScript frontend.

## 📁 Project Structure

```
easm-rnd/
├── backend/             # EASM application leverage on Django
│   ├── apps/            # Django applications
│   ├── config/          # Project configuration
│   ├── pyproject.toml   # Poetry dependencies
│   └── manage.py        # Manage command inside app
├── frontend/            # React TypeScript application
│   ├── src/
│   ├── public/
│   ├── package.json
│   └── tsconfig.json
    - portal
    - dashboard
    - ui-core/share-or-common-component
├── infra/              # Kubernetes & deployment configs
│   ├── helm/           # Helm charts
│   ├── docker/         # Dockerfiles
│   └── k8s/            # Kubernetes manifests
├── .github/
│   └── workflows/      # GitHub Actions
├── skaffold.yaml       # Skaffold configuration
└── README.md
```

## 🚀 Tech Stack

### Backend

| Name                          | Version | Description                        |
|-------------------------------|---------|-----------------------------------|
| Python                        | 3.12+   | Python runtime                    |
| Django                        | 5.2+    | Web framework                     |
| Django REST Framework         | 3.15+   | RESTful API toolkit               |
| djangorestframework-simplejwt | 5.3+    | JWT authentication                |
| Poetry                        | 2.2+    | Dependency management             |
| PostgreSQL                    | 18+     | Primary database (Django ORM)     |
| MongoDB                       | 8+      | NoSQL database (Scanner app)      |
| PyMongo                       | 4.6+    | MongoDB driver for Python         |
| psycopg2-binary               | 2.9+    | PostgreSQL adapter for Python     |
| Redis                         | 7.4+    | Caching and session store         |
| redis (Python)                | 5.0+    | Redis Python client               |
| django-redis                  | 5.4+    | Redis cache backend for Django    |
| Gunicorn                      | 21.2+   | WSGI HTTP Server                  |
| drf-spectacular               | 0.27+   | OpenAPI schema generation         |
| django-cors-headers           | 4.3+    | CORS handling                     |
| django-filter                 | 23.5+   | Filtering support                 |

### Frontend

| Name           | Version      | Description               |
| -------------- | ------------ | ------------------------- |
| React          | 18.3+        | UI library                |
| TypeScript     | 5.6+         | Type-safe JavaScript      |
| Vite           | 5.4+         | Build tool and dev server |
| pnpm / Yarn    | 9.12+ / 4.5+ | Package manager           |
| React Router   | 6.26+        | Client-side routing       |
| TanStack Query | 5.56+        | Server state management   |
| Tailwind CSS   | 3.4+         | Utility-first CSS         |

### Infra

| Name       | Version | Description                |
| ---------- | ------- | -------------------------- |
| Docker     | 27.3+   | Containerization           |
| Minikube   | 1.34+   | Local Kubernetes cluster   |
| Skaffold   | 2.13+   | Local development workflow |
| Helm       | 3.16+   | Kubernetes package manager |
| Kubernetes | 1.31+   | Container orchestration    |

## 🛠️ Prerequisites

- Python 3.12+
- Node.js 20+ LTS
- Poetry 1.8+
- pnpm 9.12+ or Yarn 4.5+
- Docker 27.3+
- Minikube 1.34+
- kubectl 1.31+
- Skaffold 2.13+
- Helm 3.16+

## 🏃 Getting Started

### Quick Start with CLI (Recommended)

The easiest way to manage this project is using the unified CLI:

```bash
# 1. Clone and setup
git clone <repository-url>
cd easm-rnd
cp .env.example .env

# 2. Start development environment (auto-detects mode)
python cli/easm.py dev start

# 3. View logs
python cli/easm.py dev logs -f

# 4. Stop services
python cli/easm.py dev stop
```

**Install CLI globally:**

```bash
# Windows PowerShell
.\cli\install.ps1

# Linux/macOS
./cli/install.sh

# After installation, use:
easm dev start
easm --help
```

See [CLI Documentation](cli/README.md) for complete reference.

### Environment Configuration

This project uses a **single environment file** (`.env`) for all deployment modes.

```bash
# Copy the example environment file
cp .env.example .env

# Edit .env with your configuration
# Update SECRET_KEY, POSTGRES_PASSWORD, and other values as needed
```

### Local Development with Docker Compose

```bash
# Manual method
docker-compose up -d

# Or use CLI
python cli/easm.py dev start --mode compose

# Backend setup
cd backend
poetry install
poetry run python manage.py migrate
poetry run python manage.py createsuperuser

# Frontend setup (new terminal)
cd frontend
pnpm install  # or yarn install
pnpm dev      # or yarn dev
```

### Local Development with Minikube & Skaffold

```bash
# Using CLI (automatically starts Minikube if needed)
python cli/easm.py dev start --mode k8s

# Or use the interactive deployment script
# PowerShell:
.\skaffold.ps1

# Bash/Linux/macOS:
./skaffold.sh

# Manual method
minikube start --cpus=4 --memory=8192 --driver=docker
minikube addons enable ingress
skaffold dev

# Access services
minikube service list
```

**Note:** The CLI and deployment scripts automatically:
- Load environment variables from `.env`
- Start Minikube if Kubernetes is not running
- Generate temporary Skaffold config with your custom ports
- Clean up temporary files after deployment

### Manual Kubernetes Deployment

```bash
# Build and push images
docker build -t easm-backend:latest ./backend
docker build -t easm-frontend:latest ./frontend

# Deploy with Helm
helm install easm-rnd ./infra/helm/easm-rnd \
  --namespace easm-rnd \
  --create-namespace \
  --values ./infra/helm/easm-rnd/values-dev.yaml
```

## 🎯 CLI Commands Reference

### Development
```bash
easm dev start              # Start development environment
easm dev start --watch      # Start with auto-watch mode
easm dev stop               # Stop all services
easm dev logs               # View logs
easm dev logs -f            # Follow logs
easm dev shell api          # Shell into API container
easm dev clean              # Clean temp files
easm dev reset --confirm    # Reset everything
```

### Database
```bash
easm db migrate             # Run migrations
easm db seed                # Seed database
easm db shell               # Database shell
```

### Configuration
```bash
easm config init            # Initialize .env
easm config validate        # Validate configuration
easm config show            # Show current config
easm config set DEBUG=True  # Set value
```

### Kubernetes
```bash
easm k8s start              # Start Minikube
easm k8s status             # Check status
easm k8s pods               # List pods
easm k8s services           # List services
```

See `easm --help` or [CLI Documentation](cli/README.md) for all commands.

## 🌿 Git Branching Convention

We follow a structured branching strategy based on Git Flow:

### Branch Types

- **`main`** - Production-ready code
- **`develop`** - Integration branch for features
- **`feature/*`** - New features (`feature/user-authentication`)
- **`bugfix/*`** - Bug fixes for develop (`bugfix/login-validation`)
- **`hotfix/*`** - Critical fixes for production (`hotfix/security-patch`)
- **`release/*`** - Release preparation (`release/v1.2.0`)
- **`chore/*`** - Maintenance tasks (`chore/update-dependencies`)

### Branch Workflow

```bash
# Create feature branch
git checkout develop
git checkout -b feature/add-user-dashboard

# Work on feature
git add .
git commit -m "feat(dashboard): add user analytics widget"

# Keep updated with develop
git fetch origin
git rebase origin/develop

# Push and create PR
git push origin feature/add-user-dashboard
```

## 📝 Commit Message Convention

We follow [Conventional Commits](https://www.conventionalcommits.org/) specification:

### Format

```
<type>(<scope>): <subject>

[optional body]

[optional footer]
```

### Types

- **feat** - New feature
- **fix** - Bug fix
- **docs** - Documentation changes
- **style** - Code style changes (formatting, semicolons, etc.)
- **refactor** - Code refactoring
- **perf** - Performance improvements
- **test** - Adding or updating tests
- **build** - Build system or dependencies
- **ci** - CI/CD changes
- **chore** - Other changes that don't modify src or test files
- **revert** - Revert previous commit

### Examples

```bash
# Feature
git commit -m "feat(auth): implement JWT authentication"

# Bug fix
git commit -m "fix(api): resolve CORS issue on user endpoint"

# Documentation
git commit -m "docs(readme): update installation instructions"

# Breaking change
git commit -m "feat(api)!: migrate to GraphQL API

BREAKING CHANGE: REST API endpoints are deprecated"

# Multiple scopes
git commit -m "fix(frontend,backend): resolve timezone inconsistency"

# With body and footer
git commit -m "feat(dashboard): add real-time metrics

- Add WebSocket connection
- Implement metric cards
- Add auto-refresh functionality

Closes #123"
```

### Scope Examples

- **auth** - Authentication/Authorization
- **api** - API changes
- **ui** - UI components
- **db** - Database
- **docker** - Docker configuration
- **k8s** - Kubernetes configuration
- **ci** - CI/CD pipeline

## 🚢 Release Process

### Automated Release with GitHub Actions

Our CI/CD pipeline automatically deploys to Proxmox Kubernetes cluster:

#### Workflow Triggers

- **Push to `main`** - Deploy to production
- **Push to `develop`** - Deploy to staging
- **Pull Request** - Run tests and build checks
- **Tag `v*`** - Create GitHub release and deploy

#### Environment Variables Required

Set these in GitHub Repository Settings → Secrets:

```yaml
PROXMOX_K8S_CLUSTER    # Kubernetes cluster URL
PROXMOX_K8S_TOKEN      # Service account token
PROXMOX_K8S_CA_CERT    # Cluster CA certificate
DOCKER_REGISTRY        # Docker registry URL
DOCKER_USERNAME        # Registry username
DOCKER_PASSWORD        # Registry password
HELM_REPO_URL          # Helm chart repository
DATABASE_URL           # PostgreSQL connection string
REDIS_URL              # Redis connection string
RABBITMQ_URL           # RabbitMQ connection string
SECRET_KEY             # Django secret key
```

### Manual Release Steps

```bash
# 1. Create release branch
git checkout develop
git checkout -b release/v1.2.0

# 2. Update version numbers
# backend/pyproject.toml
# frontend/package.json
# infra/helm/easm-rnd/Chart.yaml

# 3. Update CHANGELOG.md
# Document all changes since last release

# 4. Commit version bump
git commit -am "chore(release): bump version to 1.2.0"

# 5. Merge to main
git checkout main
git merge release/v1.2.0

# 6. Create and push tag
git tag -a v1.2.0 -m "Release version 1.2.0"
git push origin main --tags

# 7. Merge back to develop
git checkout develop
git merge release/v1.2.0
git push origin develop

# 8. Delete release branch
git branch -d release/v1.2.0
git push origin --delete release/v1.2.0
```

### Rollback Procedure

```bash
# Rollback to previous Helm release
helm rollback easm-rnd -n easm-rnd

# Or rollback to specific revision
helm rollback easm-rnd 3 -n easm-rnd

# Check rollback status
helm history easm-rnd -n easm-rnd
```

## 🧪 Testing

```bash
# Backend tests
cd backend
poetry run pytest
poetry run pytest --cov=apps

# Frontend tests
cd frontend
pnpm test              # or yarn test
pnpm test:coverage     # or yarn test:coverage

# E2E tests
pnpm test:e2e         # or yarn test:e2e
```

## 📊 Monitoring

- **Application**: Django Debug Toolbar (dev), Sentry (prod)
- **Infra**: Prometheus + Grafana
- **Logs**: ELK Stack (Elasticsearch, Logstash, Kibana)
- **Tracing**: Jaeger

## 🔒 Security

- HTTPS/TLS encryption
- JWT authentication
- CORS configuration
- Rate limiting
- SQL injection prevention
- XSS protection
- CSRF tokens
- Security headers (HSTS, CSP, etc.)

## 📚 Documentation

- **API Documentation**: `/api/docs/` (Swagger/OpenAPI)
- **API Schema**: `/api/schema/`
- **Admin Panel**: `/admin/`
- **Scanner API Guide**: [SCANNER-QUICKSTART.md](docs/SCANNER-QUICKSTART.md)
- **Scanner API Reference**: [SCANNER-API-DOCUMENTATION.md](docs/SCANNER-API-DOCUMENTATION.md)
- **Scanner Implementation**: [SCANNER_IMPLEMENTATION.md](SCANNER_IMPLEMENTATION.md)

### Django Apps

- **todos**: Task management API
- **scanner**: MongoDB-based EASM resource scanning with 11 REST endpoints

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes using conventional commits
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request to `develop` branch

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👥 Team

- **Project Lead**: [Name]
- **Backend Team**: [Names]
- **Frontend Team**: [Names]
- **DevOps Team**: [Names]

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/your-org/easm-rnd/issues)
- **Discussions**: [GitHub Discussions](https://github.com/your-org/easm-rnd/discussions)
- **Email**: support@your-domain.com

---

Built with ❤️ by the EASM R&D Team
