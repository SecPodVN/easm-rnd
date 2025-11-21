# When to Create a New Project or App in EASM Platform

**Decision guide for organizing code in the EASM monorepo architecture**

---

## 📚 Table of Contents

1. [Understanding the Current Structure](#-understanding-the-current-structure)
2. [Quick Decision Tree](#-quick-decision-tree)
3. [When to Create a New Django App](#-when-to-create-a-new-django-app)
4. [When to Create a New Django Project](#-when-to-create-a-new-django-project)
5. [When to Create a New Backend Library](#-when-to-create-a-new-backend-library)
6. [When to Create a New Frontend App](#-when-to-create-a-new-frontend-app)
7. [Real-World Examples](#-real-world-examples)
8. [Step-by-Step Creation Guides](#-step-by-step-creation-guides)
9. [Best Practices](#-best-practices)

---

## 🏗️ Understanding the Current Structure

### Current EASM Platform Organization

```
easm-platform/
├── src/
│   ├── backend/                        # Backend Monorepo
│   │   ├── easm/                       # 🎯 Main Django Project (CORE)
│   │   │   ├── apps/                   # Django Applications
│   │   │   │   ├── api/                # API endpoints & routing
│   │   │   │   ├── todos/              # Todo domain
│   │   │   │   └── scanner/            # Scanner domain
│   │   │   ├── config/                 # Django settings
│   │   │   └── manage.py
│   │   │
│   │   └── easm-core/                  # 📚 Shared Backend Library
│   │       └── (utilities, helpers, common code)
│   │
│   ├── frontend/                       # Frontend Monorepo
│   │   ├── EASM-portal/                # 🌐 User Portal App
│   │   ├── EASM-admin/                 # 👨‍💼 Admin Dashboard App
│   │   └── EASM-ui-core/               # 🎨 Shared UI Library
│   │
│   └── cli/                            # CLI Tools
│       └── easm-cli/                   # Unified CLI
│
└── (other monorepo contents)
```

### Key Concepts

| Term                 | Definition                           | Example                        |
| -------------------- | ------------------------------------ | ------------------------------ |
| **Django Project**   | A collection of settings and apps    | `src/backend/easm/`            |
| **Django App**       | A module with specific functionality | `src/backend/easm/apps/todos/` |
| **Backend Library**  | Reusable Python code across projects | `src/backend/easm-core/`       |
| **Frontend App**     | Independent React application        | `src/frontend/EASM-portal/`    |
| **Frontend Library** | Shared React components              | `src/frontend/EASM-ui-core/`   |

---

## 🌳 Quick Decision Tree

```
┌─────────────────────────────────────────────────────────────┐
│  I need to add new functionality to EASM Platform...        │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
                    Is it Backend?
                           │
          ┌────────────────┴────────────────┐
          │ YES                              │ NO (Frontend)
          ▼                                  ▼
    Does it share data/models         Is it a new user interface
    with existing apps?               or major feature set?
          │                                  │
    ┌─────┴─────┐                      ┌────┴────┐
    │YES        │NO                     │YES      │NO
    ▼           ▼                       ▼         ▼
┌─────────┐ ┌──────────────┐    ┌──────────┐ ┌──────────┐
│ADD TO   │ │CREATE NEW    │    │CREATE    │ │ADD TO    │
│EXISTING │ │DJANGO APP    │    │NEW REACT │ │EXISTING  │
│APP      │ │IN easm/apps/ │    │APP IN    │ │APP OR    │
│         │ │              │    │frontend/ │ │LIBRARY   │
└─────────┘ └──────────────┘    └──────────┘ └──────────┘

Special Cases:
├─ Completely independent service? → CREATE NEW DJANGO PROJECT
├─ Reusable across projects? → ADD TO easm-core/ OR EASM-ui-core/
└─ Needs different tech stack? → CREATE MICROSERVICE
```

---

## 🔷 When to Create a New Django App

### ✅ Create a New Django App When:

1. **New Domain/Feature with Its Own Data Model**

   - Example: Adding a "Vulnerability Management" feature
   - Has its own models (Vulnerability, Scan, Report)
   - Distinct business logic separate from existing apps

2. **Self-Contained Functionality**

   - Can be enabled/disabled independently
   - Has minimal dependencies on other apps
   - Example: "Notifications System", "Report Generator"

3. **Clear Separation of Concerns**

   - Different team ownership
   - Different deployment schedule
   - Example: "Billing Module", "Analytics Engine"

4. **Reusable Across Projects (in the future)**
   - Could be extracted as a package later
   - Example: "Authentication System", "File Storage"

### ❌ DON'T Create a New Django App When:

1. **Extending Existing Domain**

   - Adding new fields to existing models → Modify existing app
   - Adding new views to existing resources → Add to `apps/api/[domain]/`

2. **Simple Utility Functions**

   - Helper functions → Add to `easm-core/`
   - Middleware → Add to existing app or `easm-core/`

3. **Just Adding API Endpoints**
   - New REST endpoints for existing models → Add to `apps/api/[domain]/`

### 📏 Size Guidelines

| App Size   | Files | Models | When to Split                           |
| ---------- | ----- | ------ | --------------------------------------- |
| **Small**  | 3-5   | 1-2    | Keep as single app                      |
| **Medium** | 6-15  | 3-7    | Consider splitting if domains are clear |
| **Large**  | 16+   | 8+     | Split into multiple apps by subdomain   |

---

## 🏢 When to Create a New Django Project

### ✅ Create a New Django Project When:

1. **Completely Independent Service (Microservice)**

   ```
   Example: Separate "Reporting Service"
   - Different database
   - Different scaling requirements
   - Different deployment cycle
   - Minimal shared code with main app
   ```

2. **Different Technology Requirements**

   ```
   Example: "Real-time Event Processor"
   - Needs async/await (FastAPI instead of Django)
   - Different Python version
   - Different dependency set
   ```

3. **Separate Deployment & Scaling Needs**

   ```
   Example: "Public API Gateway"
   - Public-facing vs internal
   - Different security requirements
   - Different rate limiting
   - Needs to scale independently
   ```

4. **Completely Different User Base**
   ```
   Example: "Third-Party Integration API"
   - External partners vs internal users
   - Different authentication
   - Different SLA requirements
   ```

### ❌ DON'T Create a New Django Project When:

1. **Can be a Django App** - If it shares the database and core functionality
2. **Just for Organization** - Use apps instead
3. **Performance Concerns** - Optimize first, split later
4. **Team Boundaries** - Use apps with clear ownership

### 📊 Monolith vs Microservice Decision Matrix

| Factor                   | Stay in `easm/` Project | Create New Project   |
| ------------------------ | ----------------------- | -------------------- |
| **Shares Database**      | ✅ Yes                  | ❌ No                |
| **Deployment Frequency** | Same                    | Different            |
| **Scaling Needs**        | Same                    | Independent          |
| **Team Ownership**       | Single/Shared           | Separate             |
| **Technology Stack**     | Same (Django)           | Different            |
| **Security Boundary**    | Internal                | Different            |
| **Development Speed**    | Faster (shared code)    | Slower (duplication) |

---

## 📚 When to Create a New Backend Library

### Create `easm-core/` or New Library When:

1. **Shared Utilities Across Multiple Apps**

   ```python
   # easm-core/utils/validators.py
   def validate_ip_address(ip: str) -> bool:
       # Used by scanner, network, security apps
       pass
   ```

2. **Common Business Logic**

   ```python
   # easm-core/security/scanner.py
   class BaseScanner:
       # Base class for all scanner types
       pass
   ```

3. **Reusable Across Projects**

   ```python
   # easm-core/integrations/slack.py
   class SlackNotifier:
       # Could be used in multiple EASM services
       pass
   ```

4. **Third-Party Integrations**
   ```python
   # easm-core/integrations/
   ├── aws.py           # AWS SDK wrapper
   ├── github.py        # GitHub API client
   └── virustotal.py    # VirusTotal integration
   ```

### Structure for `easm-core/`

```
easm-core/
├── __init__.py
├── README.md
├── setup.py or pyproject.toml
├── utils/
│   ├── validators.py    # Validation functions
│   ├── parsers.py       # Data parsers
│   └── formatters.py    # Output formatters
├── security/
│   ├── scanner.py       # Base scanner classes
│   └── encryption.py    # Encryption utilities
├── integrations/
│   ├── aws.py
│   └── github.py
└── models/              # Shared model mixins
    └── mixins.py
```

---

## 🎨 When to Create a New Frontend App

### ✅ Create a New Frontend App When:

1. **Distinct User Interface & Experience**

   ```
   EASM-portal/    → End users (security teams)
   EASM-admin/     → System administrators
   EASM-public/    → Public-facing marketing site
   ```

2. **Different Authentication/Authorization**

   ```
   EASM-portal/    → JWT authenticated users
   EASM-public/    → No authentication
   EASM-partner/   → OAuth for partners
   ```

3. **Independent Deployment**

   ```
   Portal updates daily
   Admin updates weekly
   Public site updates monthly
   ```

4. **Different Tech Stack Requirements**
   ```
   EASM-portal/    → React 19 + TypeScript
   EASM-mobile/    → React Native
   EASM-embed/     → Vanilla JS widget
   ```

### ❌ DON'T Create a New Frontend App When:

1. **Just a New Page/Feature** → Add to existing app
2. **Shared Components** → Add to `EASM-ui-core/`
3. **Different Styling** → Use theme configuration
4. **Route-based Sections** → Use React Router

### Frontend App Structure Guidelines

```
EASM-[name]/
├── src/
│   ├── features/          # Feature-based modules
│   │   ├── dashboard/
│   │   ├── scanning/
│   │   └── reports/
│   ├── shared/            # App-specific shared code
│   │   ├── components/
│   │   └── hooks/
│   ├── layouts/           # Page layouts
│   ├── routes/            # Route configuration
│   └── App.tsx
├── public/
├── package.json
└── vite.config.ts
```

---

## 💡 Real-World Examples

### Example 1: Adding Vulnerability Scanning

**Requirement:** Add vulnerability scanning feature to EASM platform

**Decision:** Create new Django app `apps/vulnerabilities/`

**Why?**

- ✅ New domain with its own models (Vulnerability, CVE, Patch)
- ✅ Self-contained functionality
- ✅ Could be reused in future projects
- ✅ Clear separation from scanner and todos

**Structure:**

```
src/backend/easm/apps/
├── vulnerabilities/              # NEW APP
│   ├── models.py                 # Vulnerability, CVE models
│   ├── managers.py               # Custom querysets
│   └── services.py               # Business logic
│
└── api/
    └── vulnerabilities/          # API endpoints
        ├── views.py
        ├── serializers.py
        └── filters.py
```

### Example 2: Adding User Preferences

**Requirement:** Add user preference management (theme, notifications, etc.)

**Decision:** Add to existing `apps/api/` or create `apps/accounts/`

**Why?**

- ✅ Extends existing user functionality
- ✅ Small feature set (a few fields)
- ❌ Doesn't warrant separate app initially

**Structure:**

```
src/backend/easm/apps/api/
└── users/
    ├── views.py                  # Add UserPreferenceViewSet
    ├── serializers.py            # Add PreferenceSerializer
    └── models.py                 # Add UserPreference model
```

### Example 3: Creating Reporting Microservice

**Requirement:** Heavy PDF/Excel report generation consuming lots of resources

**Decision:** Create new Django project `src/backend/easm-reporting/`

**Why?**

- ✅ Resource-intensive, needs independent scaling
- ✅ Different deployment schedule
- ✅ Can fail without affecting main app
- ✅ Potentially different tech stack (WeasyPrint, Celery)

**Structure:**

```
src/backend/
├── easm/                         # Main app
│   └── (existing structure)
│
└── easm-reporting/               # NEW PROJECT
    ├── config/
    ├── apps/
    │   ├── pdf_generator/
    │   └── excel_exporter/
    ├── manage.py
    └── pyproject.toml
```

### Example 4: Adding Real-Time Dashboard

**Requirement:** Real-time monitoring dashboard with WebSockets

**Decision:** Add to existing `EASM-portal/` as new feature

**Why?**

- ✅ Same user base (security teams)
- ✅ Same authentication
- ✅ Can share existing components
- ❌ Not complex enough for separate app

**Structure:**

```
src/frontend/EASM-portal/src/
└── features/
    └── monitoring/               # NEW FEATURE
        ├── MonitoringDashboard.tsx
        ├── RealtimeChart.tsx
        └── useWebSocket.ts
```

### Example 5: Partner API Portal

**Requirement:** Separate portal for third-party API partners

**Decision:** Create new frontend app `EASM-partner/`

**Why?**

- ✅ Different user base (external partners)
- ✅ Different authentication (OAuth)
- ✅ Different branding requirements
- ✅ Independent deployment schedule

**Structure:**

```
src/frontend/
├── EASM-portal/                  # Internal users
├── EASM-admin/                   # Administrators
└── EASM-partner/                 # NEW APP - External partners
    ├── src/
    │   ├── features/
    │   │   ├── api-keys/
    │   │   ├── documentation/
    │   │   └── usage-stats/
    │   └── App.tsx
    └── package.json
```

---

## 🛠️ Step-by-Step Creation Guides

### Creating a New Django App in `easm/`

```bash
# 1. Navigate to the easm project
cd src/backend/easm

# 2. Create new app
poetry run python manage.py startapp <app_name> apps/<app_name>

# Example: Create 'vulnerabilities' app
poetry run python manage.py startapp vulnerabilities apps/vulnerabilities

# 3. Add to INSTALLED_APPS in config/settings.py
INSTALLED_APPS = [
    # ...
    'apps.vulnerabilities',  # Add this line
]

# 4. Create models
# Edit apps/vulnerabilities/models.py

# 5. Create API endpoints
mkdir apps/api/vulnerabilities
touch apps/api/vulnerabilities/__init__.py
touch apps/api/vulnerabilities/views.py
touch apps/api/vulnerabilities/serializers.py

# 6. Register routes in apps/api/urls.py
from apps.api.vulnerabilities.views import VulnerabilityViewSet
router.register('vulnerabilities', VulnerabilityViewSet)

# 7. Make migrations
poetry run python manage.py makemigrations
poetry run python manage.py migrate

# 8. Test
poetry run python manage.py runserver
# Visit http://localhost:8000/api/vulnerabilities/
```

### Creating a New Django Project in Backend Monorepo

```bash
# 1. Navigate to backend monorepo root
cd src/backend

# 2. Create new project directory
mkdir easm-<service-name>
cd easm-<service-name>

# Example: Create 'easm-reporting' project
mkdir easm-reporting
cd easm-reporting

# 3. Initialize Poetry
poetry init --no-interaction
poetry add django djangorestframework gunicorn

# 4. Create Django project
poetry run django-admin startproject config .

# 5. Create project structure
mkdir apps
touch apps/__init__.py

# 6. Configure settings
# Edit config/settings.py to match EASM standards

# 7. Create Dockerfile
cat > Dockerfile << 'EOF'
FROM python:3.13-slim
WORKDIR /app
COPY pyproject.toml poetry.lock ./
RUN pip install poetry && poetry install --no-root
COPY . .
CMD ["poetry", "run", "gunicorn", "config.wsgi:application"]
EOF

# 8. Add to docker-compose.yml
# (See example below)

# 9. Add to skaffold.yaml for Kubernetes
# (See example below)
```

### Creating a New Frontend App

```bash
# 1. Navigate to frontend monorepo
cd src/frontend

# 2. Create new React app with Vite
npm create vite@latest EASM-<app-name> -- --template react-ts

# Example: Create 'EASM-partner' app
npm create vite@latest EASM-partner -- --template react-ts

# 3. Install dependencies
cd EASM-partner
npm install

# 4. Install shared UI library
npm install ../EASM-ui-core

# 5. Install common dependencies
npm install @mui/material @emotion/react @emotion/styled
npm install react-router-dom axios

# 6. Create feature-based structure
mkdir -p src/features
mkdir -p src/shared/components
mkdir -p src/shared/hooks
mkdir -p src/layouts

# 7. Configure vite.config.ts
# (Add proxy for API, etc.)

# 8. Update package.json scripts
{
  "scripts": {
    "dev": "vite --port 3001",  # Different port
    "build": "tsc && vite build",
    "preview": "vite preview"
  }
}

# 9. Add to root docker-compose.yml
# (See example below)

# 10. Test
npm run dev
# Visit http://localhost:3001
```

### Creating a Shared Backend Library

```bash
# 1. Navigate to backend monorepo
cd src/backend

# 2. Create library directory
mkdir easm-<library-name>
cd easm-<library-name>

# Example: Create 'easm-integrations' library
mkdir easm-integrations
cd easm-integrations

# 3. Initialize as Python package
touch __init__.py
touch README.md

# 4. Create pyproject.toml
cat > pyproject.toml << 'EOF'
[tool.poetry]
name = "easm-integrations"
version = "0.1.0"
description = "Shared integration libraries for EASM platform"

[tool.poetry.dependencies]
python = "^3.13"
requests = "^2.31.0"

[build-system]
requires = ["poetry-core"]
build-backend = "poetry.core.masonry.api"
EOF

# 5. Create module structure
mkdir -p easm_integrations/aws
mkdir -p easm_integrations/github
touch easm_integrations/__init__.py
touch easm_integrations/aws/__init__.py
touch easm_integrations/github/__init__.py

# 6. Install in main project
cd ../easm
poetry add ../easm-integrations

# 7. Use in main project
# from easm_integrations.aws import AWSClient
```

---

## ✅ Best Practices

### Naming Conventions

| Type                 | Convention         | Examples                              |
| -------------------- | ------------------ | ------------------------------------- |
| **Django App**       | Lowercase, plural  | `todos`, `vulnerabilities`, `reports` |
| **Django Project**   | `easm-<purpose>`   | `easm-reporting`, `easm-gateway`      |
| **Backend Library**  | `easm-<name>`      | `easm-core`, `easm-integrations`      |
| **Frontend App**     | `EASM-<purpose>`   | `EASM-portal`, `EASM-admin`           |
| **Frontend Library** | `EASM-<name>-core` | `EASM-ui-core`, `EASM-charts-core`    |

### Organization Principles

1. **Start Small, Refactor Later**

   - Begin with a single app
   - Split when it becomes unwieldy (>1000 lines)
   - Don't over-engineer upfront

2. **Clear Boundaries**

   - Each app should have a clear purpose
   - Minimal coupling between apps
   - Shared code goes in libraries

3. **Consistent Structure**

   - Follow the same pattern for all apps
   - Use the same folder structure
   - Maintain coding standards

4. **Documentation**
   - README.md in each app/project
   - Document dependencies
   - Explain when to use vs not use

### File Organization Within Apps

```python
# Good: Clear separation
apps/vulnerabilities/
├── __init__.py
├── models.py           # Data models
├── managers.py         # Custom managers
├── services.py         # Business logic
├── exceptions.py       # Custom exceptions
└── tests.py           # Unit tests

apps/api/vulnerabilities/
├── __init__.py
├── views.py           # API endpoints
├── serializers.py     # Data serialization
├── filters.py         # Query filtering
├── permissions.py     # Access control
└── tests.py          # API tests

# Bad: Everything in one file
apps/vulnerabilities/
└── models.py          # 2000+ lines of everything
```

### Dependency Management

```python
# Good: Clear dependencies
# apps/vulnerabilities/models.py
from django.db import models
from apps.scanner.models import ScanResult  # Clear dependency

# Bad: Circular dependencies
# apps/vulnerabilities/models.py imports from apps/scanner
# apps/scanner/models.py imports from apps/vulnerabilities
# → This creates circular import issues!
```

### API Organization

```python
# Good: Centralized routing
# apps/api/urls.py
from apps.api.todos.views import TodoViewSet
from apps.api.vulnerabilities.views import VulnerabilityViewSet

router.register('todos', TodoViewSet)
router.register('vulnerabilities', VulnerabilityViewSet)

# Bad: Scattered routing
# Each app registers its own URLs → Hard to maintain
```

---

## 🎯 Decision Checklist

Before creating a new project, app, or library, ask yourself:

### For Django Apps

- [ ] Does this feature have its own data models?
- [ ] Is it self-contained with minimal dependencies?
- [ ] Could it be enabled/disabled independently?
- [ ] Will it have more than 500 lines of code?
- [ ] Does it represent a distinct business domain?

**If 3+ Yes → Create new Django app**

### For Django Projects

- [ ] Does it need a separate database?
- [ ] Will it scale independently from the main app?
- [ ] Does it have different deployment requirements?
- [ ] Will it use different technology stack?
- [ ] Is it for a completely different user base?
- [ ] Will failures affect the main application?

**If 3+ Yes → Create new Django project (microservice)**

### For Backend Libraries

- [ ] Will this code be used in 2+ Django apps?
- [ ] Could it be extracted as an open-source package?
- [ ] Is it purely utility functions with no app-specific logic?
- [ ] Does it have no Django model dependencies?

**If 2+ Yes → Add to `easm-core/` or create new library**

### For Frontend Apps

- [ ] Is this for a different user base?
- [ ] Does it need different authentication?
- [ ] Will it deploy independently?
- [ ] Does it have a distinct visual identity?
- [ ] Is it more than 5-10 pages/components?

**If 3+ Yes → Create new frontend app**

---

## 📚 Further Reading

- [Django Apps Documentation](https://docs.djangoproject.com/en/5.2/ref/applications/)
- [Monorepo Best Practices](https://monorepo.tools/)
- [Microservices Pattern](https://microservices.io/)
- [Backend API Development Guide](BACKEND-API-DEVELOPMENT-GUIDE.md)
- [EASM Architecture Overview](PROJECT-SUMMARY.md)

---

## 🤝 Need Help?

**Still not sure?** Ask yourself:

1. **Can I add it to an existing app?** → Try that first
2. **Is it <500 lines of code?** → Probably doesn't need its own app
3. **Does it share the database?** → Keep it in the main project
4. **Will it run on the same server?** → Keep it in the main project

**When in doubt, start small and refactor later!**

---

**Last Updated**: November 2025
**Version**: 1.0.0
**Maintained By**: EASM Platform Development Team
