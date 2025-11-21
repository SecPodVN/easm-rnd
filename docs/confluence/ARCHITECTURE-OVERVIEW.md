# EASM-RND Architecture Overview

## 🏗️ High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         CLIENT LAYER                             │
├─────────────────────────────────────────────────────────────────┤
│  • React Frontend (Port 3000)                                    │
│  • API Documentation (Swagger UI / ReDoc)                        │
│  • Admin Panel (Django Admin)                                    │
└────────────────────┬────────────────────────────────────────────┘
                     │ HTTP/HTTPS
                     ▼
┌─────────────────────────────────────────────────────────────────┐
│                    API GATEWAY LAYER                             │
├─────────────────────────────────────────────────────────────────┤
│  Django REST Framework (Port 8000)                               │
│  • JWT Authentication                                            │
│  • CORS Middleware                                               │
│  • Request/Response Processing                                   │
│  • Rate Limiting & Throttling                                    │
└────────────────────┬────────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────────┐
│                   APPLICATION LAYER                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │
│  │   apps.api   │  │  apps.todos  │  │ apps.scanner │         │
│  │              │  │              │  │              │         │
│  │ • ViewSets   │  │ • Models     │  │ • Models     │         │
│  │ • Routing    │  │ • Signals    │  │ • Engine     │         │
│  │ • Auth       │  │ • Commands   │  │ • DB Logic   │         │
│  └──────────────┘  └──────────────┘  └──────────────┘         │
│                                                                  │
└─────┬──────────────────────────────────────────┬────────────────┘
      │                                          │
      ▼                                          ▼
┌──────────────────────┐              ┌──────────────────────┐
│   DATA LAYER (SQL)   │              │ DATA LAYER (NoSQL)   │
├──────────────────────┤              ├──────────────────────┤
│  PostgreSQL          │              │  MongoDB             │
│  (Port 5432)         │              │  (Port 27017)        │
│                      │              │                      │
│  • Users             │              │  • Resources         │
│  • Todos             │              │  • Rules             │
│  • Sessions          │              │  • Findings          │
└──────────────────────┘              └──────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                      CACHE LAYER                                 │
├─────────────────────────────────────────────────────────────────┤
│  Redis (Port 6379)                                               │
│  • Session Cache                                                 │
│  • Query Cache                                                   │
│  • Rate Limiting                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📁 Directory Structure Explained

### **Project Root**

```
easm-rnd/
├── .env                           # ⚙️ Environment configuration (gitignored)
├── .env.example                   # 📄 Environment template
├── docker-compose.yml             # 🐳 Local development orchestration
├── skaffold.yaml                  # ☸️ Kubernetes deployment config
├── skaffold.ps1 / skaffold.sh    # 🚀 Deployment scripts
├── Dockerfile                     # 🐳 Container image definition
├── README.md                      # 📖 Project documentation
│
├── docs/                          # 📚 Documentation
│   ├── ADDING-NEW-DJANGO-APPS.md # 👈 YOU ARE HERE
│   ├── ARCHITECTURE-OVERVIEW.md   # 🏗️ This file
│   └── ... (other docs)
│
├── src/                           # 💻 Source code
│   └── backend/                   # 🐍 Django backend
│       ├── config/                # ⚙️ Project configuration
│       ├── apps/                  # 📦 Django applications
│       ├── manage.py              # 🛠️ Django management
│       └── requirements.txt       # 📋 Python dependencies
│
├── charts/                        # ⎈ Helm charts
│   └── easm-api/                  # Kubernetes deployment charts
│
└── tests/                         # 🧪 Integration tests
```

### **Backend Structure (Detailed)**

```
src/backend/
│
├── config/                              # Django Project Configuration
│   ├── __init__.py
│   ├── settings.py                      # ⚙️ All Django settings
│   ├── urls.py                          # 🔗 Root URL routing
│   ├── wsgi.py                          # 🌐 WSGI server config
│   ├── asgi.py                          # ⚡ ASGI server config (async)
│   └── health.py                        # ❤️ Health check endpoints
│
├── apps/                                # Django Applications
│   │
│   ├── api/                             # 🎯 CENTRAL API APP
│   │   ├── __init__.py
│   │   ├── apps.py                      # App: ApiConfig
│   │   ├── views.py                     # Auth & API root views
│   │   ├── serializers.py               # Auth serializers
│   │   ├── urls.py                      # ⭐ CENTRAL ROUTING
│   │   ├── permissions.py               # Custom permissions
│   │   ├── pagination.py                # Custom pagination
│   │   ├── filters.py                   # Custom filters
│   │   │
│   │   ├── todos/                       # Todo API endpoints
│   │   │   ├── __init__.py
│   │   │   ├── views.py                 # TodoViewSet
│   │   │   └── serializers.py           # TodoSerializer
│   │   │
│   │   └── scanner/                     # Scanner API endpoints
│   │       ├── __init__.py
│   │       ├── views.py                 # Scanner ViewSets
│   │       └── serializers.py           # Scanner Serializers
│   │
│   ├── todos/                           # 📝 TODO APP (Models)
│   │   ├── __init__.py
│   │   ├── apps.py                      # App: TodosConfig
│   │   ├── models.py                    # ⭐ Todo model (PostgreSQL)
│   │   ├── admin.py                     # Django admin config
│   │   ├── management/                  # Django commands
│   │   │   └── commands/
│   │   │       ├── seed_data.py         # Seed database
│   │   │       ├── quick_seed.py        # Quick seed
│   │   │       └── clear_seed_data.py   # Clear data
│   │   └── migrations/                  # Database migrations
│   │       └── 0001_initial.py
│   │
│   └── scanner/                         # 🔍 SCANNER APP (MongoDB)
│       ├── __init__.py
│       ├── apps.py                      # App: ScannerConfig
│       ├── models.py                    # ⭐ MongoDB models (pymongo)
│       ├── db.py                        # MongoDB connection
│       ├── engine.py                    # Scanner engine logic
│       ├── admin.py                     # Admin interface
│       ├── tests.py                     # Unit tests
│       └── migrations/                  # (empty - NoSQL)
│
├── manage.py                            # 🛠️ Django CLI
├── requirements.txt                     # 📋 Python dependencies
├── pyproject.toml                       # 📦 Poetry config (optional)
└── pytest.ini                           # 🧪 Test configuration
```

---

## 🔄 Request Flow

### Example: GET /api/todos/ (List Todos)

```
1. CLIENT REQUEST
   └─> HTTP GET http://localhost:8000/api/todos/
       Headers: Authorization: Bearer <JWT_TOKEN>

2. DJANGO MIDDLEWARE STACK
   ├─> Security Middleware (HTTPS, security headers)
   ├─> CORS Middleware (handle cross-origin requests)
   ├─> Session Middleware
   ├─> CSRF Middleware
   └─> Authentication Middleware
       └─> JWT Authentication (verify token)
           └─> Request.user = User object

3. URL ROUTING (config/urls.py)
   └─> path('api/', include('apps.api.urls'))
       └─> apps/api/urls.py
           └─> router.urls (DRF Router)
               └─> Match: 'todos/' → TodoViewSet

4. VIEW PROCESSING (apps/api/todos/views.py)
   ├─> TodoViewSet.list() called
   ├─> Permission Check: IsAuthenticated ✓
   ├─> get_queryset() → Filter by request.user
   ├─> Apply filters (status, priority)
   ├─> Apply search (title, description)
   ├─> Apply ordering (-created_at)
   └─> Apply pagination (page_size=10)

5. DATABASE QUERY (PostgreSQL)
   └─> SELECT * FROM todos_todo
       WHERE user_id = <user_id>
       ORDER BY created_at DESC
       LIMIT 10 OFFSET 0;

6. SERIALIZATION (apps/api/todos/serializers.py)
   └─> TodoSerializer.to_representation()
       └─> Convert QuerySet → Python dict → JSON

7. RESPONSE
   └─> HTTP 200 OK
       Content-Type: application/json
       {
         "count": 25,
         "next": "http://localhost:8000/api/todos/?page=2",
         "previous": null,
         "results": [
           { "id": 1, "title": "...", ... },
           ...
         ]
       }
```

---

## 🗄️ Database Architecture

### PostgreSQL Schema (Django ORM)

```sql
-- Users (Django built-in)
auth_user
├── id (PK)
├── username
├── password
├── email
├── first_name
├── last_name
└── date_joined

-- Todos
todos_todo
├── id (PK)
├── title
├── description
├── status (pending/in_progress/completed)
├── priority (low/medium/high)
├── user_id (FK → auth_user)
├── created_at
├── updated_at
├── due_date
└── completed_at

-- (Future: Add more tables as needed)
```

### MongoDB Schema (pymongo)

```javascript
// Resources Collection
{
  _id: ObjectId("..."),
  name: "example.com",
  type: "domain",
  status: "active",
  metadata: {
    ip_addresses: ["1.2.3.4"],
    technologies: ["nginx", "python"]
  },
  created_at: ISODate("..."),
  updated_at: ISODate("...")
}

// Rules Collection
{
  _id: ObjectId("..."),
  name: "SQL Injection Check",
  category: "injection",
  severity: "high",
  enabled: true,
  pattern: "...",
  created_at: ISODate("...")
}

// Findings Collection
{
  _id: ObjectId("..."),
  resource_id: ObjectId("..."),
  rule_id: ObjectId("..."),
  severity: "high",
  status: "open",
  details: { ... },
  created_at: ISODate("...")
}
```

---

## 🔐 Authentication Flow

### JWT Token-Based Authentication

```
1. USER REGISTRATION
   POST /api/token/register/
   Body: { username, password, email }
   Response: { message, user: {...} }

2. USER LOGIN
   POST /api/token/
   Body: { username, password }
   Response: {
     access: "eyJ0eXAiOiJKV1QiLCJhbGc...",  # Valid for 60 min
     refresh: "eyJ0eXAiOiJKV1QiLCJhbGc..."  # Valid for 24 hours
   }

3. AUTHENTICATED REQUESTS
   GET /api/todos/
   Headers: Authorization: Bearer <access_token>

   → Django validates JWT
   → Extracts user_id from token
   → Sets request.user
   → View processes request

4. TOKEN REFRESH (when access token expires)
   POST /api/token/refresh/
   Body: { refresh: "..." }
   Response: { access: "new_access_token" }

5. TOKEN EXPIRY
   Access Token: 60 minutes (configurable via JWT_ACCESS_TOKEN_LIFETIME)
   Refresh Token: 24 hours (configurable via JWT_REFRESH_TOKEN_LIFETIME)
```

---

## 🎯 API Endpoint Structure

### Current API Endpoints

```
BASE_URL: http://localhost:8000

┌─────────────────────────────────────────────────────────────┐
│ AUTHENTICATION ENDPOINTS                                     │
├─────────────────────────────────────────────────────────────┤
│ POST   /api/token/                  # Login (get tokens)    │
│ POST   /api/token/refresh/          # Refresh access token  │
│ POST   /api/token/register/         # Register new user     │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ TODO ENDPOINTS                                               │
├─────────────────────────────────────────────────────────────┤
│ GET    /api/todos/                  # List todos            │
│ POST   /api/todos/                  # Create todo           │
│ GET    /api/todos/{id}/             # Get todo detail       │
│ PUT    /api/todos/{id}/             # Update todo (full)    │
│ PATCH  /api/todos/{id}/             # Update todo (partial) │
│ DELETE /api/todos/{id}/             # Delete todo           │
│ POST   /api/todos/{id}/complete/    # Mark as complete      │
│ GET    /api/todos/my_todos/         # Get user's todos      │
│ GET    /api/todos/statistics/       # Get statistics        │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ SCANNER ENDPOINTS                                            │
├─────────────────────────────────────────────────────────────┤
│ GET    /api/scanner/healthStatus     # Scanner health       │
│ GET    /api/scanner/resources/       # List resources       │
│ POST   /api/scanner/resources/       # Create resource      │
│ GET    /api/scanner/rules/           # List rules           │
│ POST   /api/scanner/rules/           # Create rule          │
│ GET    /api/scanner/findings/        # List findings        │
│ POST   /api/scanner/scan/            # Trigger scan         │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ HEALTH CHECK ENDPOINTS                                       │
├─────────────────────────────────────────────────────────────┤
│ GET    /health/                      # Basic health check   │
│ GET    /health/ready/                # Readiness probe      │
│ GET    /health/live/                 # Liveness probe       │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ API DOCUMENTATION                                            │
├─────────────────────────────────────────────────────────────┤
│ GET    /api/docs/                    # Swagger UI           │
│ GET    /api/redoc/                   # ReDoc UI             │
│ GET    /api/schema/                  # OpenAPI schema       │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ ADMIN PANEL                                                  │
├─────────────────────────────────────────────────────────────┤
│ GET    /admin/                       # Django Admin         │
└─────────────────────────────────────────────────────────────┘
```

---

## 🧩 Component Interactions

### How Apps Interact

```
┌───────────────────────────────────────────────────────────┐
│                     apps.api (Central)                     │
│  • Handles ALL incoming API requests                       │
│  • Routes to appropriate sub-modules                       │
│  • Provides authentication views                           │
│  • Centralizes API documentation                           │
└─────────┬─────────────────────────────────┬───────────────┘
          │                                 │
          │                                 │
          ▼                                 ▼
┌───────────────────────┐       ┌───────────────────────┐
│   apps/api/todos/     │       │  apps/api/scanner/    │
│   • TodoViewSet       │       │  • ResourceViewSet    │
│   • TodoSerializer    │       │  • RuleViewSet        │
└──────────┬────────────┘       └────────┬──────────────┘
           │                             │
           │ imports models              │ imports models
           ▼                             ▼
┌───────────────────────┐       ┌───────────────────────┐
│   apps.todos          │       │   apps.scanner        │
│   • Todo (model)      │       │   • Resource (model)  │
│   • Management cmds   │       │   • Rule (model)      │
└──────────┬────────────┘       │   • Scanner engine    │
           │                    └────────┬──────────────┘
           │ Django ORM                  │ pymongo
           ▼                             ▼
     ┌──────────┐                  ┌──────────┐
     │PostgreSQL│                  │ MongoDB  │
     └──────────┘                  └──────────┘
```

### Key Principles

1. **Separation of Concerns**:

   - Models live in domain apps (`apps.todos`, `apps.scanner`)
   - API logic lives in `apps.api/`
   - Configuration lives in `config/`

2. **Centralized Routing**:

   - All API routes go through `apps.api.urls`
   - Makes API structure clear and maintainable

3. **Database Flexibility**:

   - PostgreSQL for structured, relational data
   - MongoDB for flexible, document-based data

4. **Clear Dependencies**:
   ```
   Client → apps.api → apps.todos → PostgreSQL
                    → apps.scanner → MongoDB
   ```

---

## 🚀 Deployment Architecture

### Local Development (Docker Compose)

```
┌─────────────────────────────────────────────────────────────┐
│  Host Machine (localhost)                                    │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ Docker Compose (docker-compose.yml)                   │  │
│  │                                                        │  │
│  │  ┌──────────┐  ┌──────────┐  ┌────────┐  ┌────────┐ │  │
│  │  │  Django  │  │PostgreSQL│  │ Redis  │  │MongoDB │ │  │
│  │  │  :8000   │  │  :5432   │  │ :6379  │  │:27017  │ │  │
│  │  └──────────┘  └──────────┘  └────────┘  └────────┘ │  │
│  │                                                        │  │
│  │  All services in same network                         │  │
│  │  Persistent volumes for data                          │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                              │
│  Ports exposed to host:                                      │
│  • 8000 (Django API)                                         │
│  • 5432 (PostgreSQL)                                         │
│  • 6379 (Redis)                                              │
│  • 27017 (MongoDB)                                           │
└─────────────────────────────────────────────────────────────┘
```

### Kubernetes Deployment (Minikube/Production)

```
┌─────────────────────────────────────────────────────────────────┐
│  Kubernetes Cluster                                              │
│                                                                  │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │ Namespace: easm-rnd                                         │ │
│  │                                                             │ │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐       │ │
│  │  │   Ingress   │  │   Service   │  │   Service   │       │ │
│  │  │             │  │  (Django)   │  │ (PostgreSQL)│       │ │
│  │  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘       │ │
│  │         │                │                 │              │ │
│  │         │                ▼                 ▼              │ │
│  │         │         ┌─────────────┐  ┌─────────────┐       │ │
│  │         └────────▶│  Deployment │  │ StatefulSet │       │ │
│  │                   │   (Django)  │  │(PostgreSQL) │       │ │
│  │                   │             │  │             │       │ │
│  │                   │  Replicas:3 │  │  Replicas:1 │       │ │
│  │                   └─────────────┘  └─────────────┘       │ │
│  │                                                           │ │
│  │  ┌─────────────┐  ┌─────────────┐                        │ │
│  │  │   Service   │  │   Service   │                        │ │
│  │  │   (Redis)   │  │  (MongoDB)  │                        │ │
│  │  └──────┬──────┘  └──────┬──────┘                        │ │
│  │         │                 │                               │ │
│  │         ▼                 ▼                               │ │
│  │  ┌─────────────┐  ┌─────────────┐                        │ │
│  │  │ StatefulSet │  │ StatefulSet │                        │ │
│  │  │   (Redis)   │  │  (MongoDB)  │                        │ │
│  │  │             │  │             │                        │ │
│  │  │  Replicas:1 │  │  Replicas:1 │                        │ │
│  │  └─────────────┘  └─────────────┘                        │ │
│  │                                                           │ │
│  │  ┌────────────────────────────────────────────────────┐  │ │
│  │  │  Persistent Volumes (PV)                           │  │ │
│  │  │  • postgres-data                                   │  │ │
│  │  │  • redis-data                                      │  │ │
│  │  │  • mongodb-data                                    │  │ │
│  │  └────────────────────────────────────────────────────┘  │ │
│  │                                                           │ │
│  │  ┌────────────────────────────────────────────────────┐  │ │
│  │  │  ConfigMaps & Secrets                              │  │ │
│  │  │  • django-config (env vars)                        │  │ │
│  │  │  • postgres-secret (credentials)                   │  │ │
│  │  │  • redis-secret (password)                         │  │ │
│  │  └────────────────────────────────────────────────────┘  │ │
│  └────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📊 Technology Stack Summary

| Layer                | Technology            | Purpose               |
| -------------------- | --------------------- | --------------------- |
| **Frontend**         | React 18+             | User interface        |
| **API Framework**    | Django 5.1 + DRF 3.15 | REST API backend      |
| **Authentication**   | JWT (SimpleJWT)       | Token-based auth      |
| **Database (SQL)**   | PostgreSQL 17         | Relational data       |
| **Database (NoSQL)** | MongoDB 8             | Document storage      |
| **Cache**            | Redis 7               | Caching & sessions    |
| **API Docs**         | drf-spectacular       | OpenAPI/Swagger       |
| **WSGI Server**      | Gunicorn 21+          | Production server     |
| **Reverse Proxy**    | Nginx (optional)      | Load balancing        |
| **Containerization** | Docker                | Application packaging |
| **Orchestration**    | Kubernetes + Helm     | Production deployment |
| **Dev Workflow**     | Skaffold              | Local K8s development |
| **Package Manager**  | Poetry                | Python dependencies   |

---

## 🔧 Configuration Files

| File                 | Purpose                            |
| -------------------- | ---------------------------------- |
| `.env`               | Environment variables (gitignored) |
| `.env.example`       | Environment template               |
| `config/settings.py` | Django settings                    |
| `docker-compose.yml` | Local dev orchestration            |
| `Dockerfile`         | Container image definition         |
| `skaffold.yaml`      | Kubernetes dev workflow            |
| `requirements.txt`   | Python dependencies                |
| `pyproject.toml`     | Poetry configuration               |
| `charts/easm-api/`   | Helm chart templates               |

---

## 🎯 Design Patterns Used

### 1. **Model-View-Serializer (MVS) Pattern**

- **Model**: Database schema (`apps.todos.models.Todo`)
- **View**: Business logic (`apps.api.todos.views.TodoViewSet`)
- **Serializer**: Data validation (`apps.api.todos.serializers.TodoSerializer`)

### 2. **Repository Pattern** (MongoDB apps)

- Database operations abstracted in model classes
- `Resource.create()`, `Resource.find_all()`, etc.

### 3. **Dependency Injection**

- Django's built-in DI for views, serializers
- Request object injected into views

### 4. **Factory Pattern**

- ViewSet creates appropriate serializer based on action
- `get_serializer_class()` method

### 5. **Observer Pattern**

- Django signals (`post_save`, `pre_delete`)
- Used for auto-creating related models

---

## 📈 Scalability Considerations

### Horizontal Scaling

- **Stateless Django app**: Can run multiple replicas
- **Load balancing**: Kubernetes Service distributes traffic
- **Database connection pooling**: pgbouncer for PostgreSQL

### Caching Strategy

```python
# Cache frequently accessed data
from django.core.cache import cache

# Example: Cache todo list for 5 minutes
todos = cache.get(f'user_{user_id}_todos')
if not todos:
    todos = Todo.objects.filter(user=user_id)
    cache.set(f'user_{user_id}_todos', todos, 300)
```

### Database Optimization

- **Indexes**: Added on frequently queried fields
- **Query optimization**: Use `select_related()`, `prefetch_related()`
- **Read replicas**: PostgreSQL read replicas for heavy read workloads

---

## 🛡️ Security Architecture

### Security Layers

1. **Network Layer**

   - HTTPS/TLS encryption
   - CORS policies
   - Rate limiting

2. **Authentication Layer**

   - JWT tokens (stateless)
   - Token expiration
   - Refresh token rotation

3. **Authorization Layer**

   - Permission classes (`IsAuthenticated`)
   - Object-level permissions
   - User-based queryset filtering

4. **Data Layer**

   - SQL injection prevention (ORM)
   - NoSQL injection prevention (parameterized queries)
   - Secrets management (environment variables)

5. **Application Layer**
   - Input validation (serializers)
   - CSRF protection
   - XSS prevention (React)

---

## 📞 Monitoring & Logging

### Health Checks

```python
# config/health.py
/health/       # Basic health check
/health/ready/ # Kubernetes readiness probe
/health/live/  # Kubernetes liveness probe
```

### Logging

```python
import logging
logger = logging.getLogger(__name__)

logger.info("User logged in")
logger.error("Database connection failed")
```

### Metrics (Future)

- Prometheus exporters
- Grafana dashboards
- Application performance monitoring (APM)

---

## 🚦 What's Next?

### Potential Additions

1. **Celery** - Background tasks & async processing
2. **WebSockets** - Real-time notifications
3. **GraphQL** - Alternative API layer
4. **File Storage** - S3/MinIO for file uploads
5. **Search** - Elasticsearch for full-text search
6. **Monitoring** - Prometheus + Grafana
7. **CI/CD** - GitHub Actions / GitLab CI
8. **Testing** - Expanded test coverage

---

**Last Updated**: November 2024
**Version**: 1.0
**Maintained By**: EASM-RND Team
