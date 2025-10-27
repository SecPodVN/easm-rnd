# Project Structure After Migration

## New Directory Structure

```
src/backend/
├── apps/
│   ├── api/                          # Centralized REST API
│   │   ├── __init__.py
│   │   ├── admin.py
│   │   ├── apps.py
│   │   ├── filters.py
│   │   ├── models.py
│   │   ├── pagination.py
│   │   ├── permissions.py
│   │   ├── serializers.py           # General serializers (UserSerializer)
│   │   ├── tests.py
│   │   ├── urls.py                  # Main API routing (→ todo.urls)
│   │   ├── views.py                 # api_root endpoint only
│   │   └── todo/                    # ✨ NEW: Todo API Module
│   │       ├── __init__.py          # Exports TodoViewSet
│   │       ├── views.py             # TodoViewSet with all endpoints
│   │       ├── serializers.py       # Todo serializers
│   │       ├── urls.py              # Todo routing
│   │       ├── tests.py             # Todo API tests
│   │       └── README.md            # Todo API documentation
│   │
│   ├── todos/                        # Todo Data Models (unchanged)
│   │   ├── __init__.py
│   │   ├── admin.py
│   │   ├── apps.py
│   │   ├── models.py                # Todo model (source of truth)
│   │   ├── serializers.py           # (deprecated, use api/todo/serializers.py)
│   │   ├── urls.py                  # (deprecated)
│   │   ├── views.py                 # (deprecated, use api/todo/views.py)
│   │   └── management/
│   │       └── commands/
│   │           ├── seed_data.py
│   │           ├── quick_seed.py
│   │           └── clear_seed_data.py
│   │
│   ├── core/
│   └── scanner/
│
├── config/
│   ├── __init__.py
│   ├── settings.py
│   ├── urls.py                      # Main URL config (routes to api/)
│   ├── wsgi.py
│   └── asgi.py
│
└── manage.py
```

## URL Routing Flow

```
Main URLs (config/urls.py)
│
├─→ /api/ → apps.api.urls
│           │
│           ├─→ / → api_root (view)
│           │
│           └─→ /todos/ → apps.api.todo.urls
│                         │
│                         └─→ All todo endpoints via TodoViewSet
│
├─→ /admin/ → Django Admin
│
├─→ /api/token/ → JWT Auth
│
└─→ /api/docs/ → API Documentation
```

## Data Flow

```
HTTP Request
    ↓
Django URL Router (config/urls.py)
    ↓
API URLs (apps/api/urls.py)
    ↓
Todo URLs (apps/api/todo/urls.py)
    ↓
TodoViewSet (apps/api/todo/views.py)
    ↓
Serializers (apps/api/todo/serializers.py)
    ↓
Todo Model (apps/todos/models.py)
    ↓
Database (PostgreSQL/SQLite)
```

## Module Responsibilities

### `apps/todos/` - Data Layer
- **Purpose**: Define data models and structure
- **Contains**: Models, Admin configuration, Management commands
- **Does NOT contain**: API views, serializers, or routing

### `apps/api/` - API Layer (Base)
- **Purpose**: General API infrastructure
- **Contains**: Common utilities, permissions, pagination, filters
- **Routes**: Main API routing to sub-modules

### `apps/api/todo/` - Todo API Module
- **Purpose**: All Todo REST API endpoints
- **Contains**:
  - ViewSets (business logic)
  - Serializers (data validation & transformation)
  - URL routing (endpoint definitions)
  - Tests (API testing)
  - Documentation

## Endpoint Architecture

```
TodoViewSet (ModelViewSet)
│
├─→ Standard CRUD Methods
│   ├── list()           → GET /api/todos/
│   ├── create()         → POST /api/todos/
│   ├── retrieve()       → GET /api/todos/{id}/
│   ├── update()         → PUT /api/todos/{id}/
│   ├── partial_update() → PATCH /api/todos/{id}/
│   └── destroy()        → DELETE /api/todos/{id}/
│
├─→ Custom Actions (@action)
│   ├── complete()       → POST /api/todos/{id}/complete/
│   ├── uncomplete()     → POST /api/todos/{id}/uncomplete/
│   ├── my_todos()       → GET /api/todos/my_todos/
│   ├── statistics()     → GET /api/todos/statistics/
│   ├── overdue()        → GET /api/todos/overdue/
│   ├── by_status()      → GET /api/todos/by_status/
│   ├── by_priority()    → GET /api/todos/by_priority/
│   ├── bulk_update()    → POST /api/todos/bulk_update/
│   ├── bulk_delete()    → POST /api/todos/bulk_delete/
│   └── bulk_complete()  → POST /api/todos/bulk_complete/
│
└─→ Built-in Features
    ├── DjangoFilterBackend (status, priority filtering)
    ├── SearchFilter (title, description search)
    ├── OrderingFilter (sort by any field)
    └── Pagination (automatic page splitting)
```

## Serializer Architecture

```
apps/api/todo/serializers.py
│
├─→ TodoSerializer
│   ├── Purpose: Read operations (GET requests)
│   ├── Includes: All fields + nested user info
│   └── Read-only: id, created_at, updated_at, user, completed_at
│
├─→ TodoCreateUpdateSerializer
│   ├── Purpose: Write operations (POST, PUT, PATCH)
│   ├── Includes: Editable fields only
│   └── Validates: status, priority choices
│
├─→ TodoBulkUpdateSerializer
│   ├── Purpose: Bulk update validation
│   ├── Validates: ids list, status, priority
│   └── Ensures: At least one field to update
│
└─→ TodoBulkDeleteSerializer
    ├── Purpose: Bulk delete validation
    └── Validates: ids list not empty
```

## Test Coverage

```
apps/api/todo/tests.py
│
├─→ CRUD Tests
│   ├── test_list_todos()
│   ├── test_create_todo()
│   ├── test_retrieve_todo()
│   ├── test_update_todo()
│   ├── test_partial_update_todo()
│   └── test_delete_todo()
│
├─→ Custom Action Tests
│   ├── test_complete_todo()
│   ├── test_uncomplete_todo()
│   ├── test_statistics()
│   ├── test_by_status()
│   ├── test_by_priority()
│   └── test_overdue_todos()
│
├─→ Bulk Operation Tests
│   ├── test_bulk_update()
│   ├── test_bulk_delete()
│   └── test_bulk_complete()
│
├─→ Feature Tests
│   ├── test_search_todos()
│   ├── test_filter_todos()
│   └── test_ordering_todos()
│
└─→ Security Tests
    └── test_unauthorized_access()
```

## Migration Summary

### Before
```
apps/
├── api/
│   ├── views.py (contained TodoViewSet)
│   ├── serializers.py (contained Todo serializers)
│   └── urls.py (registered TodoViewSet)
└── todos/
    ├── models.py
    ├── views.py (duplicate TodoViewSet)
    ├── serializers.py (duplicate serializers)
    └── urls.py
```

### After
```
apps/
├── api/
│   ├── views.py (only api_root)
│   ├── serializers.py (only UserSerializer)
│   ├── urls.py (routes to todo/)
│   └── todo/  ← NEW MODULE
│       ├── views.py (TodoViewSet)
│       ├── serializers.py (Todo serializers)
│       ├── urls.py (Todo routing)
│       ├── tests.py
│       └── README.md
└── todos/
    ├── models.py (unchanged)
    └── management/ (unchanged)
```

## Benefits of New Structure

1. **Modularity**: Each resource (todos, future resources) has its own module
2. **Scalability**: Easy to add new API modules (e.g., `apps/api/tasks/`, `apps/api/projects/`)
3. **Organization**: Clear separation of concerns
4. **Testing**: Tests are co-located with the code they test
5. **Documentation**: Each module has its own README
6. **Maintainability**: Easier to find and update code
7. **Consistency**: All API code follows the same pattern

## Future Expansion Pattern

To add a new resource API (e.g., "projects"):

```
apps/api/projects/
├── __init__.py
├── views.py          # ProjectViewSet
├── serializers.py    # Project serializers
├── urls.py           # Project routing
├── tests.py          # Project tests
└── README.md         # Project API docs
```

Then update `apps/api/urls.py`:
```python
urlpatterns = [
    path('', api_root, name='api-root'),
    path('todos/', include('apps.api.todo.urls')),
    path('projects/', include('apps.api.projects.urls')),  # New!
]
```
