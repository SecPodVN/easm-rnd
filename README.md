# easm-platform

A modern monorepo, modular, extensible, reusable application for External Attack Surface Management (EASM) Research and Development, built with Django REST API and GRAPHQL backend and React TypeScript frontend.

## 📁 Project Structure

This project follows a modular monorepo architecture inspired by and customized from the [Pitchfork Layout](https://joholl.github.io/pitchfork-website/) for our Python/Django backend and TypeScript/React frontend stack. The structure emphasizes separation of concerns, modularity, and scalability.

```
easm-platform/
├── backend/             # Contain all backend application/lib
│   ├── easm/            # Base Django application
│   │   ├── apps/        # Django applications
│   │   ├── config/      # Project configuration
│   │   ├── pyproject.toml   # Poetry dependencies
│   │   └── manage.py    # Manage command inside app
│   ├── easm-cli/        # CLI tools and commands
│   └── easm-core/       # Core, Shared libraries and utilities
├── frontend/            # Contain all frontend application/lib
│   ├── easm-portal-ui/  # Portal interface
│   │   ├── src/
│   │   ├── public/
│   │   ├── package.json
│   │   └── tsconfig.json
│   ├── easm-admin-ui/   # Admin dashboard
│   ├── easm-core/       # Shared core utilities
│   └── easm-react/      # React components library
├── infra/               # Kubernetes & deployment configs
│   ├── helm/            # Helm charts
│   ├── docker/          # Dockerfiles
│   └── k8s/             # Kubernetes manifests
├── .github/
│   └── workflows/       # GitHub Actions
├── skaffold.yaml        # Skaffold configuration
└── README.md
```

**Key Design Principles:**
- **Modularity**: Each component (backend/frontend modules) is independently maintainable
- **Separation**: Clear boundaries between core application, CLI tools, and shared libraries
- **Scalability**: Easy to add new modules or services without affecting existing ones
- **Reusability**: Shared libraries (`easm-lib`, `easm-core`, `easm-react`) promote code reuse


### Frontend App Structure

```
src/frontend/
├── EASM-portal/                 # Main EASM Portal (User-facing)
│   ├── src/
│   │   ├── features/            # Domain-specific modules
│   │   ├── shared/
│   │   ├── components/
│   ├── public/
│   ├── package.json
│   ├── .gitignore
│   └── README.md
│
├── EASM-admin/                  # Admin Portal (Administrative interface)
│   ├── src/
│   │   ├── features/            # Admin-specific features
│   │   └── shared/
│   │       └── components/      # Admin-specific shared components
│   ├── public/
│   ├── package.json
│   ├── .gitignore
│   └── README.md                # 🚧 Under development
│
└── EASM-ui-core/                # Shared UI Library
    ├── src/
    │   ├── components/          # Shared components across apps
    │   ├── utils/               # Utility functions
    │   ├── hooks/               # Custom React hooks
    │   ├── types/               # TypeScript type definitions
    │   └── index.ts
    ├── package.json
    ├── tsconfig.json
    ├── .gitignore
    └── README.md
```

**Note:** Each app (EASM-portal, EASM-admin) has its own `shared/` directory for app-specific shared components. The `EASM-ui-core` package contains components and utilities shared across all EASM applications.

## 🚀 Tech Stack

| Category        | Name       | Version | Environment | Description                                                    |
|-----------------|------------|---------|-------------|----------------------------------------------------------------|
| **Infra**       | Docker     | 28.5+   | All         | Platform for developing, shipping, and running containers      |
| **Infra**       | Kubernetes | 1.32+   | All         | Production-grade container orchestration platform              |
| **Infra**       | Minikube   | 1.35+   | Local       | Local Kubernetes cluster for development and testing           |
| **Infra**       | Skaffold   | 2.16+   | Local, Dev  | Command-line tool for continuous development on Kubernetes     |
| **Infra**       | Helm       | 3.19+   | All         | Package manager for Kubernetes applications                    |
| **Backend**     | Python     | 3.13+   | All         | Python runtime for backend services                            |
| **Backend**     | Django     | 5.2+    | All         | High-level Python web framework for rapid development          |
| **Backend**     | Poetry     | 2.2+    | All         | Python dependency management and packaging tool                |
| **Backend**     | PostgreSQL | 18+     | All         | Advanced open-source relational database                       |
| **Backend**     | MongoDB    | 8+      | All         | NoSQL document database for flexible data storage              |
| **Backend**     | Redis      | 7.4+    | All         | In-memory data structure store for caching and sessions        |
| **Frontend**    | Node.js    | 22+     | All         | JavaScript runtime environment                                 |
| **Frontend**    | React      | 19+     | All         | Component-based JavaScript library for building user interfaces|
| **Frontend**    | TypeScript | 5.7+    | All         | Typed superset of JavaScript for enhanced code quality         |
| **Frontend**    | Vite       | 6+      | All         | Next-generation frontend build tool with HMR                   |
| **Frontend**    | Turborepo  | 2+      | All         | High-performance build system for JavaScript/TypeScript monorepos|

## 🏃 Getting Started

### Quick Start with CLI (Recommended)

The easiest way to manage this project is using the unified CLI:

```bash
# 1. Clone and setup
git clone <repository-url> your-path-to/easm-platform
cd easm-platform
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
helm install easm-platform ./infra/helm/easm-platform \
  --namespace easm-platform \
  --create-namespace \
  --values ./infra/helm/easm-platform/values-dev.yaml
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

## 🌿 Git Workflow

We follow Git Flow branching strategy with Conventional Commits specification.

**📖 Complete Guide:** [Git Workflow & Commit Conventions](docs/GIT-WORKFLOW.md)

This guide includes:
- **Commit Message Convention** - Conventional Commits format, types, and examples
- **Branch Naming** - Branch types and naming conventions
- **Branch Workflow** - Creating and managing feature, bugfix, hotfix, and release branches
- **Pull Request Process** - PR creation with templates and checklists
- **Code Review Guidelines** - Best practices for reviewing and approving PRs
- **Branch Protection Rules** - Merge strategies and protection settings

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
# infra/helm/easm-platform/Chart.yaml

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
helm rollback easm-platform -n easm-platform

# Or rollback to specific revision
helm rollback easm-platform 3 -n easm-platform

# Check rollback status
helm history easm-platform -n easm-platform
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

| Security Feature              | Status      | Backend | Frontend | Description                                    |
|-------------------------------|-------------|---------|----------|------------------------------------------------|
| HTTPS/TLS Encryption          | ❌ Done     | ❌      | ❌       | Secure communication with SSL/TLS              |
| JWT Authentication            | ✅ Done     | ✅      | ✅       | Token-based authentication system              |
| CORS Configuration            | ✅ Done     | ✅      | ✅       | Cross-Origin Resource Sharing properly configured |
| Rate Limiting                 | ❌ Done     | ❌      | ❌       | API rate limiting to prevent abuse             |
| SQL Injection Prevention      | ❌ Done     | ❌      | ❌       | Django ORM protection against SQL injection    |
| XSS Protection                | ❌ Done     | ❌      | ❌       | Cross-Site Scripting prevention mechanisms     |
| CSRF Tokens                   | ❌ Done     | ❌      | ❌       | Cross-Site Request Forgery protection          |
| Security Headers              | ❌ Done     | ❌      | ❌       | HSTS, CSP, X-Frame-Options, etc.               |
| Input Validation              | ❌ Done     | ❌      | ❌       | Server and client-side input validation        |
| Password Hashing              | ✅ Done     | ✅      | ✅       | Bcrypt/PBKDF2 for secure password storage      |
| Environment Variables         | ❌ Done     | ❌      | ❌       | Sensitive data stored in environment variables |
| Dependency Scanning           | ❌ Progress | ❌      | ❌       | Automated vulnerability scanning for dependencies |
| API Key Management            | ❌ Planned  | ❌      | ❌       | Secure API key rotation and management         |
| Two-Factor Authentication     | ❌ Planned  | ❌      | ❌       | 2FA for enhanced user security                 |
| Security Audit Logging        | ❌ Planned  | ❌      | ❌       | Comprehensive security event logging           |

**Legend:**
- ✅ Done - Implemented and active
- 🔄 Progress - In development
- 📋 Planned - Scheduled for future implementation
- ❌ Not applicable or not implemented

## 📚 Documentation

- **API Documentation**: `/api/docs/` (Swagger/OpenAPI)
- **API Schema**: `/api/schema/`
- **Admin Panel**: `/admin/`

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes using conventional commits
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request to `develop` branch

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

##  Support

- **Issues**: [GitHub Issues](https://github.com/SecPod-Git/easm/issues)
- **Discussions**: [GitHub Discussions](https://github.com/SecPod-Git/easm/discussions)
- **Email**: support@your-domain.com

---

Built with ❤️ by the EASM R&D Team
