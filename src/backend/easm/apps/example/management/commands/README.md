# Seed Data Commands

This directory contains Django management commands for seeding and managing test data.

## Commands

### 1. seed_data
Seeds the database with sample users and todos.

**Usage:**
```bash
python manage.py seed_data
python manage.py seed_data --users 5 --todos-per-user 20
python manage.py seed_data --clear  # Clear existing data first
```

**Options:**
- `--users N`: Number of users to create (default: 3)
- `--todos-per-user N`: Number of todos per user (default: 10)
- `--clear`: Clear existing data before seeding

### 2. quick_seed
Quick seed with default values (3 users, 10 todos each).

**Usage:**
```bash
python manage.py quick_seed
```

### 3. clear_seed_data
Clears seed data from the database.

**Usage:**
```bash
python manage.py clear_seed_data              # Clear non-superusers only
python manage.py clear_seed_data --all        # Clear all users and data
python manage.py clear_seed_data --confirm    # Skip confirmation
```

## Docker Usage

### Seed data in Docker container:
```bash
docker-compose exec web python manage.py seed_data
docker-compose exec web python manage.py quick_seed
```

### Clear data in Docker:
```bash
docker-compose exec web python manage.py clear_seed_data
```

## Test Credentials

After seeding, you can use these credentials:

**Superuser:**
- Username: `admin`
- Password: `admin123`

**Regular Users:**
- Username: `user1`, `user2`, `user3`
- Password: `password123` (for all users)

## Example API Testing

1. **Get JWT Token:**
```bash
curl -X POST http://localhost:8000/api/token/ \
  -H "Content-Type: application/json" \
  -d '{"username":"user1","password":"password123"}'
```

2. **List Todos:**
```bash
curl http://localhost:8000/api/todos/ \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

3. **Get Statistics:**
```bash
curl http://localhost:8000/api/todos/statistics/ \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```
