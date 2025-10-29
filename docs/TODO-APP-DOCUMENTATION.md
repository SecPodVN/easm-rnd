# Todo App Documentation

## Overview

The Todo App is a RESTful task management application built with Django REST Framework that allows users to create, manage, and track their personal tasks. It provides a complete CRUD (Create, Read, Update, Delete) interface with advanced features like filtering, sorting, and task statistics.

## Table of Contents

1. [Architecture](#architecture)
2. [Features](#features)
3. [API Endpoints](#api-endpoints)
4. [Data Models](#data-models)
5. [Authentication](#authentication)
6. [Setup & Installation](#setup--installation)
7. [Usage Examples](#usage-examples)
8. [Error Handling](#error-handling)
9. [Testing](#testing)

## Architecture

### Project Structure
```
src/backend/
├── apps/
│   ├── api/                 # Centralized API controller
│   │   ├── views.py        # Todo API views and endpoints
│   │   ├── serializers.py  # API serializers
│   │   ├── urls.py         # API routing
│   │   └── ...
│   └── todos/              # Todo data models
│       ├── models.py       # Todo model definition
│       └── apps.py         # App configuration
└── config/
    ├── settings.py         # Django settings
    └── urls.py             # Main URL configuration
```

### Design Pattern
- **Centralized API Pattern**: All API logic is handled by the `api` app
- **Separation of Concerns**: Data models in `todos` app, API logic in `api` app
- **RESTful Design**: Standard HTTP methods for CRUD operations
- **Token-based Authentication**: JWT tokens for secure API access

## Features

### Core Features
- ✅ **CRUD Operations**: Create, Read, Update, Delete todos
- ✅ **User Authentication**: JWT-based secure authentication
- ✅ **User Isolation**: Users only see their own todos
- ✅ **Status Management**: Pending, In Progress, Completed statuses
- ✅ **Priority System**: Low, Medium, High priority levels
- ✅ **Due Date Tracking**: Set and manage task deadlines

### Advanced Features
- ✅ **Search & Filtering**: Find todos by title/description
- ✅ **Sorting**: Order by date, priority, status
- ✅ **Pagination**: Efficient handling of large todo lists
- ✅ **Statistics**: Task completion rates and counts
- ✅ **Bulk Operations**: Mark todos as complete
- ✅ **API Documentation**: Swagger/OpenAPI documentation

## API Endpoints

### Base URL: `/api/`

### Authentication Endpoints
```http
POST /api/token/register/    # Register new user
POST /api/token/             # Login (get JWT tokens)
POST /api/token/refresh/     # Refresh access token
```

### Todo Management Endpoints
```http
GET    /api/todos/           # List all user's todos
POST   /api/todos/           # Create new todo
GET    /api/todos/{id}/      # Get specific todo
PUT    /api/todos/{id}/      # Update entire todo
PATCH  /api/todos/{id}/      # Partial update todo
DELETE /api/todos/{id}/      # Delete todo
```

### Special Todo Endpoints
```http
POST /api/todos/{id}/complete/    # Mark todo as completed
GET  /api/todos/my_todos/         # Alternative list endpoint
GET  /api/todos/statistics/       # Get completion statistics
```

### Documentation Endpoints
```http
GET /api/docs/              # Swagger UI documentation
GET /api/redoc/             # ReDoc documentation
GET /api/schema/            # OpenAPI schema
```

## Data Models

### Todo Model
```python
class Todo(models.Model):
    # Basic Information
    title = CharField(max_length=200)           # Required
    description = TextField(blank=True)         # Optional

    # Status & Priority
    status = CharField(max_length=20)           # pending/in_progress/completed
    priority = CharField(max_length=10)         # low/medium/high

    # User Association
    user = ForeignKey(User)                     # Owner of the todo

    # Timestamps
    created_at = DateTimeField(auto_now_add=True)
    updated_at = DateTimeField(auto_now=True)
    due_date = DateTimeField(null=True, blank=True)
    completed_at = DateTimeField(null=True, blank=True)
```

### Status Choices
- `pending` - Task not started yet
- `in_progress` - Currently working on task
- `completed` - Task finished

### Priority Choices
- `low` - Can be done later
- `medium` - Normal priority
- `high` - Important, should be done soon

## Authentication

### JWT Token Authentication
The API uses JWT (JSON Web Tokens) for secure authentication.

#### Getting Tokens
```http
POST /api/token/
Content-Type: application/json

{
    "username": "your_username",
    "password": "your_password"
}
```

**Response:**
```json
{
    "access": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
    "refresh": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."
}
```

#### Using Tokens
Include the access token in the Authorization header:
```http
Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...
```

#### Token Expiration
- **Access Token**: 60 minutes (configurable)
- **Refresh Token**: 24 hours (configurable)

## Setup & Installation

### Prerequisites
- Docker & Docker Compose
- Python 3.13+
- PostgreSQL (via Docker)

### Quick Start
```bash
# Clone repository
git clone <repository-url>
cd easm-rnd

# Start services
docker compose up -d

# Run migrations
docker compose exec api python manage.py migrate

# Create superuser (optional)
docker compose exec api python manage.py createsuperuser

# Access API
# http://localhost:8000/api/
# http://localhost:8000/api/docs/
```

### Environment Variables
```env
SECRET_KEY=your-secret-key
DEBUG=True
JWT_ACCESS_TOKEN_LIFETIME=60
JWT_REFRESH_TOKEN_LIFETIME=1440
```

## Usage Examples

### 1. User Registration
```bash
curl -X POST http://localhost:8000/api/token/register/ \
  -H "Content-Type: application/json" \
  -d '{
    "username": "johndoe",
    "email": "john@example.com",
    "password": "securepass123",
    "password_confirm": "securepass123",
    "first_name": "John",
    "last_name": "Doe"
  }'
```

### 2. Login & Get Token
```bash
curl -X POST http://localhost:8000/api/token/ \
  -H "Content-Type: application/json" \
  -d '{
    "username": "johndoe",
    "password": "securepass123"
  }'
```

### 3. Create Todo
```bash
curl -X POST http://localhost:8000/api/todos/ \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -d '{
    "title": "Complete project documentation",
    "description": "Write comprehensive docs for the todo app",
    "status": "pending",
    "priority": "high",
    "due_date": "2025-10-30T17:00:00Z"
  }'
```

### 4. List Todos with Filtering
```bash
# All todos
curl -H "Authorization: Bearer YOUR_TOKEN" \
  http://localhost:8000/api/todos/

# Filter by status
curl -H "Authorization: Bearer YOUR_TOKEN" \
  "http://localhost:8000/api/todos/?status=pending"

# Search by title
curl -H "Authorization: Bearer YOUR_TOKEN" \
  "http://localhost:8000/api/todos/?search=project"

# Sort by priority
curl -H "Authorization: Bearer YOUR_TOKEN" \
  "http://localhost:8000/api/todos/?ordering=-priority"
```

### 5. Update Todo
```bash
# Partial update (PATCH)
curl -X PATCH http://localhost:8000/api/todos/1/ \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "status": "in_progress"
  }'
```

### 6. Mark Todo as Complete
```bash
curl -X POST http://localhost:8000/api/todos/1/complete/ \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### 7. Get Statistics
```bash
curl -H "Authorization: Bearer YOUR_TOKEN" \
  http://localhost:8000/api/todos/statistics/
```

**Response:**
```json
{
    "total": 10,
    "pending": 3,
    "in_progress": 2,
    "completed": 5,
    "completion_rate": 50.0
}
```

## Error Handling

### Common HTTP Status Codes
- `200 OK` - Successful GET, PATCH, PUT
- `201 Created` - Successful POST
- `204 No Content` - Successful DELETE
- `400 Bad Request` - Invalid data
- `401 Unauthorized` - Missing or invalid token
- `403 Forbidden` - Permission denied
- `404 Not Found` - Resource doesn't exist
- `500 Internal Server Error` - Server error

### Error Response Format
```json
{
    "detail": "Error message",
    "code": "error_code",
    "field_errors": {
        "field_name": ["Field-specific error message"]
    }
}
```

### Authentication Errors
```json
{
    "detail": "Given token not valid for any token type",
    "code": "token_not_valid"
}
```

### Validation Errors
```json
{
    "title": ["This field is required."],
    "status": ["Invalid status value."]
}
```

## Testing

### Manual Testing with API Docs
1. Visit `http://localhost:8000/api/docs/`
2. Use the interactive Swagger interface
3. Test all endpoints with sample data

### Testing with Curl/Postman
Use the examples in the [Usage Examples](#usage-examples) section.

### Automated Testing
```bash
# Run Django tests
docker compose exec api python manage.py test

# Run with coverage
docker compose exec api python manage.py test --with-coverage
```

## API Response Examples

### List Todos Response
```json
{
    "count": 25,
    "next": "http://localhost:8000/api/todos/?page=2",
    "previous": null,
    "results": [
        {
            "id": 1,
            "title": "Complete project documentation",
            "description": "Write comprehensive docs",
            "status": "pending",
            "priority": "high",
            "user": {
                "id": 1,
                "username": "johndoe",
                "email": "john@example.com",
                "first_name": "John",
                "last_name": "Doe"
            },
            "created_at": "2025-10-28T10:00:00Z",
            "updated_at": "2025-10-28T10:00:00Z",
            "due_date": "2025-10-30T17:00:00Z",
            "completed_at": null
        }
    ]
}
```

### Create Todo Response
```json
{
    "title": "Complete project documentation",
    "description": "Write comprehensive docs",
    "status": "pending",
    "priority": "high",
    "due_date": "2025-10-30T17:00:00Z"
}
```

## Filtering & Sorting Options

### Available Filters
- `status` - Filter by todo status
- `priority` - Filter by priority level
- `search` - Search in title and description

### Available Sorting
- `created_at` - Sort by creation date
- `updated_at` - Sort by last update
- `due_date` - Sort by due date
- `priority` - Sort by priority level

### Examples
```bash
# Multiple filters
?status=pending&priority=high

# Sorting (descending with -)
?ordering=-created_at

# Search with pagination
?search=project&page=2
```

## Security Features

### Authentication & Authorization
- JWT token-based authentication
- User isolation (users only see their own todos)
- Token expiration and refresh mechanism

### Data Validation
- Input sanitization
- Field validation (required fields, max lengths)
- Status and priority validation

### CORS Configuration
- Configured for frontend integration
- Secure headers and middleware

## Future Enhancements

### Planned Features
- [ ] Todo categories/tags
- [ ] Shared todos (collaboration)
- [ ] File attachments
- [ ] Recurring todos
- [ ] Email notifications
- [ ] Export functionality
- [ ] Mobile app API support

### Performance Optimizations
- [ ] Database indexing
- [ ] Caching layer
- [ ] API rate limiting
- [ ] Bulk operations API

---

## Support & Contributing

For questions, issues, or contributions, please refer to the main project repository.

**API Base URL**: `http://localhost:8000/api/`
**Documentation**: `http://localhost:8000/api/docs/`
**Version**: 1.0.0
