# Example Domain App

This is a **template domain app** that demonstrates the proper architecture pattern for EASM domain apps.

## Purpose

The Example app (formerly "todos") serves as a reference implementation showing:
- Domain model design with proper relationships
- Service layer for business logic
- Async tasks using Celery
- Admin configuration
- Management commands for seeding data

## Architecture

```
apps/example/                    # Domain Layer (Business Logic)
├── models.py                    # Todo domain model
├── services.py                  # TodoService - business logic
├── tasks.py                     # Celery async tasks
├── admin.py                     # Django admin configuration
├── management/commands/         # CLI commands
│   ├── seed_data.py            # Seed sample data
│   ├── clear_seed_data.py      # Clear sample data
│   └── quick_seed.py           # Quick seed helper
└── tests.py                     # Domain logic tests

apps/api/example/                # Presentation Layer (REST API)
├── serializers.py               # Todo API serializers
├── views.py                     # TodoViewSet - API endpoints
├── filters.py                   # TodoFilter - query filtering
└── urls.py                      # API routing
```

## Models

### Todo
- Tracks tasks/items with status, priority, and due dates
- Links to Django User model
- Inherits TimeStampedModel for automatic timestamps

## Services

### TodoService
Business logic methods:
- `get_user_statistics(user)` - Get todo stats for a user
- `mark_todo_complete(todo_id)` - Mark todo as completed
- `bulk_update_priority(todo_ids, priority)` - Bulk priority update
- `get_overdue_todos(user)` - Get overdue todos

## Tasks (Celery)

- `process_items_task` - Async batch processing
- `periodic_cleanup_task` - Scheduled cleanup
- `send_notification_task` - Notifications

## Management Commands

### Seed Data
```bash
# Default: 3 users, 10 todos each
python manage.py seed_data

# Custom
python manage.py seed_data --users 5 --todos-per-user 20

# Clear and reseed
python manage.py seed_data --clear

# Quick seed (default values)
python manage.py quick_seed
```

### Clear Data
```bash
# Clear non-superuser data
python manage.py clear_seed_data --confirm

# Clear all data
python manage.py clear_seed_data --all --confirm
```

## API Endpoints

All endpoints are in the **apps/api** presentation layer:

- `GET/POST /api/example/` - List/Create todos
- `GET/PUT/PATCH/DELETE /api/example/{id}/` - Todo CRUD
- `POST /api/example/{id}/complete/` - Mark complete
- `GET /api/example/stats/` - User statistics
- `GET /api/example/overdue/` - Overdue todos
- `POST /api/example/bulk_update_priority/` - Bulk update

## Using as a Template

To create a new domain app following this pattern:

1. **Create domain app:**
   ```bash
   python manage.py startapp new_domain apps/new_domain
   ```

2. **Add required files:**
   - `models.py` - Domain models
   - `services.py` - Business logic
   - `tasks.py` - Async tasks (optional)
   - `admin.py` - Admin interface

3. **Create API presentation layer:**
   ```
   apps/api/new_domain/
   ├── __init__.py
   ├── serializers.py
   ├── views.py
   ├── filters.py
   └── urls.py
   ```

4. **Register in settings:**
   ```python
   INSTALLED_APPS = [
       ...
       'easm.apps.new_domain.apps.NewDomainConfig',
   ]
   ```

5. **Add to API routing:**
   ```python
   # apps/api/urls.py
   path('new-domain/', include('easm.apps.api.new_domain.urls')),
   ```

## Key Principles

1. **Separation of Concerns**
   - Domain logic in `apps/example/`
   - API presentation in `apps/api/example/`

2. **Service Layer Pattern**
   - Business logic in `services.py`
   - Views stay thin, delegate to services

3. **Async Tasks**
   - Long-running operations in `tasks.py`
   - Use Celery for background processing

4. **Proper Testing**
   - Test domain logic separately from API
   - Use Django TestCase for models/services
   - Use APITestCase for API endpoints
