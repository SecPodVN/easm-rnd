# Todo API Module

This module contains all API endpoints for managing todos.

## Directory Structure

```
todo/
├── __init__.py       # Module initialization
├── views.py          # ViewSets and API logic
├── serializers.py    # Data serialization
├── urls.py           # URL routing
└── tests.py          # API tests
```

## API Endpoints

### Standard CRUD Operations

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/todos/` | List all todos (with pagination) |
| POST | `/api/todos/` | Create a new todo |
| GET | `/api/todos/{id}/` | Retrieve a specific todo |
| PUT | `/api/todos/{id}/` | Update a todo (full update) |
| PATCH | `/api/todos/{id}/` | Partially update a todo |
| DELETE | `/api/todos/{id}/` | Delete a todo |

### Custom Actions

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/todos/{id}/complete/` | Mark a todo as completed |
| POST | `/api/todos/{id}/uncomplete/` | Mark a completed todo as pending |
| GET | `/api/todos/my_todos/` | Get all todos for current user |
| GET | `/api/todos/statistics/` | Get todo statistics |
| GET | `/api/todos/overdue/` | Get overdue todos |
| GET | `/api/todos/by_status/?status={status}` | Filter todos by status |
| GET | `/api/todos/by_priority/?priority={priority}` | Filter todos by priority |
| POST | `/api/todos/bulk_update/` | Update multiple todos |
| POST | `/api/todos/bulk_delete/` | Delete multiple todos |
| POST | `/api/todos/bulk_complete/` | Complete multiple todos |

## Features

### Filtering
- **By Status**: `?status=pending|in_progress|completed`
- **By Priority**: `?priority=low|medium|high`
- **Combined**: `?status=pending&priority=high`

### Searching
- Search in title and description: `?search=keyword`

### Ordering
- **By created date**: `?ordering=-created_at` (descending) or `?ordering=created_at` (ascending)
- **By updated date**: `?ordering=-updated_at`
- **By due date**: `?ordering=-due_date`
- **By priority**: `?ordering=-priority`

### Pagination
All list endpoints support pagination. Default page size is configured in settings.

## Request/Response Examples

### Create a Todo

**Request:**
```http
POST /api/todos/
Content-Type: application/json
Authorization: Bearer {token}

{
  "title": "Complete project documentation",
  "description": "Write comprehensive API documentation",
  "status": "pending",
  "priority": "high",
  "due_date": "2025-10-30T12:00:00Z"
}
```

**Response:**
```json
{
  "id": 1,
  "title": "Complete project documentation",
  "description": "Write comprehensive API documentation",
  "status": "pending",
  "priority": "high",
  "user": {
    "id": 1,
    "username": "john",
    "email": "john@example.com",
    "first_name": "John",
    "last_name": "Doe"
  },
  "created_at": "2025-10-27T10:00:00Z",
  "updated_at": "2025-10-27T10:00:00Z",
  "due_date": "2025-10-30T12:00:00Z",
  "completed_at": null
}
```

### Bulk Update Todos

**Request:**
```http
POST /api/todos/bulk_update/
Content-Type: application/json
Authorization: Bearer {token}

{
  "ids": [1, 2, 3],
  "status": "completed",
  "priority": "low"
}
```

**Response:**
```json
{
  "message": "Successfully updated 3 todos",
  "updated_count": 3
}
```

### Get Statistics

**Request:**
```http
GET /api/todos/statistics/
Authorization: Bearer {token}
```

**Response:**
```json
{
  "total": 10,
  "by_status": {
    "pending": 3,
    "in_progress": 2,
    "completed": 5
  },
  "by_priority": {
    "high": 2,
    "medium": 5,
    "low": 3
  },
  "overdue": 1,
  "completion_rate": 50.0
}
```

## Authentication

All endpoints require authentication using JWT tokens. Include the token in the Authorization header:

```
Authorization: Bearer {your_jwt_token}
```

## Permissions

- Users can only access their own todos
- All CRUD operations are restricted to the todo owner
- Bulk operations only affect the authenticated user's todos

## Error Responses

### 400 Bad Request
```json
{
  "error": "Invalid status value"
}
```

### 401 Unauthorized
```json
{
  "detail": "Authentication credentials were not provided."
}
```

### 404 Not Found
```json
{
  "detail": "Not found."
}
```

## Testing

Run the tests with:
```bash
python manage.py test apps.api.todo
```

Or with pytest:
```bash
pytest apps/api/todo/tests.py
```
