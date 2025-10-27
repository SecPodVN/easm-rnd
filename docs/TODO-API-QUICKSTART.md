# Quick Start: Using the New Todo API

## What's New?

The Todo API has been reorganized and enhanced with many new features!

## Location
All todo API code is now in: `src/backend/apps/api/todo/`

## New Endpoints Summary

### Standard Operations (Already existed, now enhanced)
```http
GET    /api/todos/              # List all todos
POST   /api/todos/              # Create a todo
GET    /api/todos/{id}/         # Get a specific todo
PUT    /api/todos/{id}/         # Update a todo (full)
PATCH  /api/todos/{id}/         # Update a todo (partial)
DELETE /api/todos/{id}/         # Delete a todo
```

### New Individual Operations
```http
POST   /api/todos/{id}/complete/    # Mark todo as completed
POST   /api/todos/{id}/uncomplete/  # Mark todo as pending (NEW!)
```

### New Query Operations
```http
GET    /api/todos/overdue/                      # Get overdue todos (NEW!)
GET    /api/todos/by_status/?status=pending     # Filter by status (NEW!)
GET    /api/todos/by_priority/?priority=high    # Filter by priority (NEW!)
GET    /api/todos/statistics/                   # Enhanced with more data!
```

### New Bulk Operations
```http
POST   /api/todos/bulk_update/     # Update multiple todos (NEW!)
POST   /api/todos/bulk_delete/     # Delete multiple todos (NEW!)
POST   /api/todos/bulk_complete/   # Complete multiple todos (NEW!)
```

## Quick Examples

### 1. Get All Pending High-Priority Todos
```bash
curl -H "Authorization: Bearer YOUR_TOKEN" \
  "http://localhost:8000/api/todos/?status=pending&priority=high"
```

### 2. Complete Multiple Todos at Once
```bash
curl -X POST \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"ids": [1, 2, 3]}' \
  "http://localhost:8000/api/todos/bulk_complete/"
```

### 3. Get Statistics
```bash
curl -H "Authorization: Bearer YOUR_TOKEN" \
  "http://localhost:8000/api/todos/statistics/"
```

Returns:
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

### 4. Search for Todos
```bash
curl -H "Authorization: Bearer YOUR_TOKEN" \
  "http://localhost:8000/api/todos/?search=documentation"
```

### 5. Bulk Update Todos
```bash
curl -X POST \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "ids": [1, 2, 3],
    "status": "in_progress",
    "priority": "high"
  }' \
  "http://localhost:8000/api/todos/bulk_update/"
```

## Testing

Run the test suite:
```bash
cd src/backend
python manage.py test apps.api.todo
```

## Documentation

- **Detailed API Docs**: `src/backend/apps/api/todo/README.md`
- **Migration Summary**: `docs/TODO-API-MIGRATION.md`
- **Checklist**: `docs/TODO-API-CHECKLIST.md`

## Features Overview

### Filtering
- By status: `?status=pending`
- By priority: `?priority=high`
- Combined: `?status=pending&priority=high`

### Searching
- Search title/description: `?search=keyword`

### Ordering
- By date: `?ordering=-created_at`
- By priority: `?ordering=-priority`
- Reverse: `?ordering=created_at`

### Pagination
- Automatic pagination on list endpoints
- Use `?page=2` to navigate

## All Available Filters & Options

```
# Filtering
?status=pending|in_progress|completed
?priority=low|medium|high

# Searching
?search=keyword

# Ordering (add - for descending)
?ordering=-created_at
?ordering=-updated_at
?ordering=-due_date
?ordering=-priority

# Pagination
?page=1
?page_size=20

# Combining (all can be used together)
?status=pending&priority=high&search=urgent&ordering=-due_date&page=1
```

## Next Steps

1. Test the endpoints with your favorite API client (Postman, Insomnia, etc.)
2. Check the interactive API docs at `/api/docs/`
3. Run the test suite to verify everything works
4. Update your frontend code to use the new bulk operations

Enjoy the enhanced Todo API! 🚀
