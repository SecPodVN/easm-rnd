# EASM API Documentation

## Overview

The EASM Django REST API provides a comprehensive todo management system with JWT authentication, pagination, filtering, and search capabilities.

**Base URL:** `http://localhost:8000`

## Authentication

All API endpoints (except token endpoints) require JWT authentication.

### Obtain Token

**Endpoint:** `POST /api/token/`

**Request:**
```json
{
  "username": "your_username",
  "password": "your_password"
}
```

**Response:**
```json
{
  "access": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "refresh": "eyJ0eXAiOiJKV1QiLCJhbGc..."
}
```

### Refresh Token

**Endpoint:** `POST /api/token/refresh/`

**Request:**
```json
{
  "refresh": "eyJ0eXAiOiJKV1QiLCJhbGc..."
}
```

**Response:**
```json
{
  "access": "eyJ0eXAiOiJKV1QiLCJhbGc..."
}
```

### Using Token

Include the access token in the Authorization header:
```
Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGc...
```

## Todo Endpoints

### List Todos

**Endpoint:** `GET /api/todos/`

**Query Parameters:**
- `page` (integer): Page number (default: 1)
- `page_size` (integer): Items per page (default: 10)
- `status` (string): Filter by status (pending, in_progress, completed)
- `priority` (string): Filter by priority (low, medium, high)
- `search` (string): Search in title and description
- `ordering` (string): Sort by field (created_at, updated_at, due_date, priority)

**Example:**
```bash
GET /api/todos/?page=1&status=pending&priority=high&ordering=-created_at
```

**Response:**
```json
{
  "count": 50,
  "next": "http://localhost:8000/api/todos/?page=2",
  "previous": null,
  "results": [
    {
      "id": 1,
      "title": "Complete project documentation",
      "description": "Write comprehensive API documentation",
      "status": "pending",
      "priority": "high",
      "user": {
        "id": 1,
        "username": "admin",
        "email": "admin@example.com",
        "first_name": "Admin",
        "last_name": "User"
      },
      "created_at": "2025-10-22T10:30:00Z",
      "updated_at": "2025-10-22T10:30:00Z",
      "due_date": "2025-10-25T23:59:59Z",
      "completed_at": null
    }
  ]
}
```

### Create Todo

**Endpoint:** `POST /api/todos/`

**Request:**
```json
{
  "title": "New Todo",
  "description": "Todo description",
  "status": "pending",
  "priority": "medium",
  "due_date": "2025-10-30T23:59:59Z"
}
```

**Response:** `201 Created`
```json
{
  "id": 2,
  "title": "New Todo",
  "description": "Todo description",
  "status": "pending",
  "priority": "medium",
  "user": {
    "id": 1,
    "username": "admin",
    "email": "admin@example.com",
    "first_name": "Admin",
    "last_name": "User"
  },
  "created_at": "2025-10-22T11:00:00Z",
  "updated_at": "2025-10-22T11:00:00Z",
  "due_date": "2025-10-30T23:59:59Z",
  "completed_at": null
}
```

### Get Todo Detail

**Endpoint:** `GET /api/todos/{id}/`

**Response:** `200 OK`
```json
{
  "id": 1,
  "title": "Complete project documentation",
  "description": "Write comprehensive API documentation",
  "status": "pending",
  "priority": "high",
  "user": {
    "id": 1,
    "username": "admin",
    "email": "admin@example.com",
    "first_name": "Admin",
    "last_name": "User"
  },
  "created_at": "2025-10-22T10:30:00Z",
  "updated_at": "2025-10-22T10:30:00Z",
  "due_date": "2025-10-25T23:59:59Z",
  "completed_at": null
}
```

### Update Todo (Full)

**Endpoint:** `PUT /api/todos/{id}/`

**Request:**
```json
{
  "title": "Updated Todo",
  "description": "Updated description",
  "status": "in_progress",
  "priority": "high",
  "due_date": "2025-10-30T23:59:59Z"
}
```

**Response:** `200 OK` (same structure as GET)

### Update Todo (Partial)

**Endpoint:** `PATCH /api/todos/{id}/`

**Request:**
```json
{
  "status": "completed"
}
```

**Response:** `200 OK` (same structure as GET)

### Delete Todo

**Endpoint:** `DELETE /api/todos/{id}/`

**Response:** `204 No Content`

### Complete Todo

**Endpoint:** `POST /api/todos/{id}/complete/`

Marks a todo as completed and sets the `completed_at` timestamp.

**Response:** `200 OK`
```json
{
  "id": 1,
  "title": "Complete project documentation",
  "description": "Write comprehensive API documentation",
  "status": "completed",
  "priority": "high",
  "user": {
    "id": 1,
    "username": "admin",
    "email": "admin@example.com",
    "first_name": "Admin",
    "last_name": "User"
  },
  "created_at": "2025-10-22T10:30:00Z",
  "updated_at": "2025-10-22T11:30:00Z",
  "due_date": "2025-10-25T23:59:59Z",
  "completed_at": "2025-10-22T11:30:00Z"
}
```

### Get My Todos

**Endpoint:** `GET /api/todos/my_todos/`

Returns all todos for the authenticated user (supports same query parameters as list).

**Response:** Same structure as List Todos

### Get Statistics

**Endpoint:** `GET /api/todos/statistics/`

**Response:** `200 OK`
```json
{
  "total": 50,
  "pending": 20,
  "in_progress": 15,
  "completed": 15,
  "completion_rate": 30.0
}
```

## Models

### Todo

| Field | Type | Description |
|-------|------|-------------|
| id | Integer | Primary key |
| title | String (255) | Todo title (required) |
| description | Text | Todo description (optional) |
| status | String | Status: pending, in_progress, completed |
| priority | String | Priority: low, medium, high |
| user | ForeignKey | Owner of the todo |
| created_at | DateTime | Creation timestamp |
| updated_at | DateTime | Last update timestamp |
| due_date | DateTime | Due date (optional) |
| completed_at | DateTime | Completion timestamp (optional) |

## Error Responses

### 400 Bad Request
```json
{
  "field_name": [
    "This field is required."
  ]
}
```

### 401 Unauthorized
```json
{
  "detail": "Authentication credentials were not provided."
}
```

### 403 Forbidden
```json
{
  "detail": "You do not have permission to perform this action."
}
```

### 404 Not Found
```json
{
  "detail": "Not found."
}
```

### 500 Internal Server Error
```json
{
  "detail": "Internal server error."
}
```

## Pagination

All list endpoints support pagination with the following parameters:

- `page`: Page number (default: 1)
- `page_size`: Items per page (default: 10, max: 100)

Response includes:
- `count`: Total number of items
- `next`: URL to next page (null if last page)
- `previous`: URL to previous page (null if first page)
- `results`: Array of items

## Filtering

### Status Filter
```bash
GET /api/todos/?status=pending
GET /api/todos/?status=in_progress
GET /api/todos/?status=completed
```

### Priority Filter
```bash
GET /api/todos/?priority=low
GET /api/todos/?priority=medium
GET /api/todos/?priority=high
```

### Combined Filters
```bash
GET /api/todos/?status=pending&priority=high
```

## Searching

Search in title and description:
```bash
GET /api/todos/?search=documentation
```

## Sorting

Sort by fields (prefix with `-` for descending):
```bash
GET /api/todos/?ordering=created_at        # Ascending
GET /api/todos/?ordering=-created_at       # Descending
GET /api/todos/?ordering=-priority,created_at  # Multiple fields
```

Available sort fields:
- `created_at`
- `updated_at`
- `due_date`
- `priority`

## Rate Limiting

Currently no rate limiting is implemented. Consider adding rate limiting in production.

## CORS

CORS is configured to allow requests from:
- `http://localhost:3000`
- `http://127.0.0.1:3000`

In development mode (`DEBUG=True`), all origins are allowed.

## API Documentation

Interactive API documentation is available at:

- **Swagger UI:** `http://localhost:8000/api/docs/`
- **ReDoc:** `http://localhost:8000/api/redoc/`
- **OpenAPI Schema:** `http://localhost:8000/api/schema/`

## Examples

### Complete Workflow

#### 1. Create User and Get Token
```bash
# Create superuser
docker-compose exec web python manage.py createsuperuser

# Get token
curl -X POST http://localhost:8000/api/token/ \
  -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "admin123"}'

# Save the access token
export TOKEN="eyJ0eXAiOiJKV1QiLCJhbGc..."
```

#### 2. Create Todos
```bash
# Create todo 1
curl -X POST http://localhost:8000/api/todos/ \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Setup development environment",
    "description": "Install Docker, Python, and dependencies",
    "status": "completed",
    "priority": "high"
  }'

# Create todo 2
curl -X POST http://localhost:8000/api/todos/ \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Write API documentation",
    "description": "Document all endpoints and examples",
    "status": "in_progress",
    "priority": "high",
    "due_date": "2025-10-25T23:59:59Z"
  }'

# Create todo 3
curl -X POST http://localhost:8000/api/todos/ \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Deploy to production",
    "description": "Deploy using Kubernetes and Helm",
    "status": "pending",
    "priority": "medium",
    "due_date": "2025-10-30T23:59:59Z"
  }'
```

#### 3. List and Filter
```bash
# Get all todos
curl -X GET http://localhost:8000/api/todos/ \
  -H "Authorization: Bearer $TOKEN"

# Get high priority todos
curl -X GET "http://localhost:8000/api/todos/?priority=high" \
  -H "Authorization: Bearer $TOKEN"

# Get pending todos
curl -X GET "http://localhost:8000/api/todos/?status=pending" \
  -H "Authorization: Bearer $TOKEN"

# Search for documentation
curl -X GET "http://localhost:8000/api/todos/?search=documentation" \
  -H "Authorization: Bearer $TOKEN"
```

#### 4. Update Todo
```bash
# Update status to completed
curl -X PATCH http://localhost:8000/api/todos/2/ \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"status": "completed"}'

# Or use the complete action
curl -X POST http://localhost:8000/api/todos/2/complete/ \
  -H "Authorization: Bearer $TOKEN"
```

#### 5. Get Statistics
```bash
curl -X GET http://localhost:8000/api/todos/statistics/ \
  -H "Authorization: Bearer $TOKEN"
```

#### 6. Delete Todo
```bash
curl -X DELETE http://localhost:8000/api/todos/3/ \
  -H "Authorization: Bearer $TOKEN"
```

## Testing with Python

```python
import requests

# Base URL
BASE_URL = "http://localhost:8000"

# Get token
response = requests.post(
    f"{BASE_URL}/api/token/",
    json={"username": "admin", "password": "admin123"}
)
token = response.json()["access"]

# Set headers
headers = {"Authorization": f"Bearer {token}"}

# Create todo
todo_data = {
    "title": "Test Todo",
    "description": "Created via Python",
    "status": "pending",
    "priority": "medium"
}
response = requests.post(
    f"{BASE_URL}/api/todos/",
    json=todo_data,
    headers=headers
)
todo = response.json()
print(f"Created todo: {todo['id']}")

# List todos
response = requests.get(f"{BASE_URL}/api/todos/", headers=headers)
todos = response.json()
print(f"Total todos: {todos['count']}")

# Update todo
response = requests.patch(
    f"{BASE_URL}/api/todos/{todo['id']}/",
    json={"status": "completed"},
    headers=headers
)
print("Todo updated")

# Get statistics
response = requests.get(f"{BASE_URL}/api/todos/statistics/", headers=headers)
stats = response.json()
print(f"Completion rate: {stats['completion_rate']}%")
```

## WebSocket Support

Currently not implemented. Consider adding Django Channels for real-time updates.

## API Versioning

Currently not versioned. For production, consider adding versioning:
- URL versioning: `/api/v1/todos/`
- Header versioning: `Accept: application/vnd.easm.v1+json`

## Security Best Practices

1. **Always use HTTPS in production**
2. **Rotate SECRET_KEY regularly**
3. **Set strong JWT token lifetimes**
4. **Implement rate limiting**
5. **Add request validation**
6. **Enable CORS only for trusted origins**
7. **Use environment variables for secrets**
8. **Regular security audits**
9. **Keep dependencies updated**
10. **Monitor and log API access**

## Support

For issues and questions, please refer to the main README.md or create an issue in the repository.
