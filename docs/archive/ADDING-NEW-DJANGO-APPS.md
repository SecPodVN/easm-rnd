# Adding New Django Apps to EASM-RND Project

## 📋 Project Structure Overview

The EASM-RND project follows a **hybrid architecture** for Django apps:

### Current App Architecture

```
src/backend/
├── config/                          # Django project configuration
│   ├── settings.py                  # Main settings
│   ├── urls.py                      # Root URL configuration
│   ├── wsgi.py / asgi.py           # WSGI/ASGI config
│   └── health.py                    # Health check endpoints
│
├── apps/                            # Django applications directory
│   ├── api/                         # **Centralized REST API app**
│   │   ├── apps.py                  # App config: ApiConfig
│   │   ├── views.py                 # Auth & API root views
│   │   ├── serializers.py           # Auth serializers
│   │   ├── urls.py                  # Central API routing
│   │   ├── permissions.py           # Custom permissions
│   │   ├── pagination.py            # Custom pagination
│   │   ├── filters.py               # Custom filters
│   │   ├── todos/                   # Todo views/serializers (under api/)
│   │   │   ├── views.py
│   │   │   ├── serializers.py
│   │   │   └── __init__.py
│   │   └── scanner/                 # Scanner views/serializers (under api/)
│   │       ├── views.py
│   │       ├── serializers.py
│   │       └── __init__.py
│   │
│   ├── todos/                       # **Standalone Todo app** (models only)
│   │   ├── apps.py                  # App config: TodosConfig
│   │   ├── models.py                # Todo model (PostgreSQL)
│   │   ├── management/              # Management commands
│   │   │   └── commands/
│   │   │       ├── seed_data.py
│   │   │       ├── quick_seed.py
│   │   │       └── clear_seed_data.py
│   │   └── migrations/              # Database migrations
│   │
│   └── scanner/                     # **Standalone Scanner app** (MongoDB)
│       ├── apps.py                  # App config: ScannerConfig
│       ├── models.py                # MongoDB models (pymongo)
│       ├── db.py                    # MongoDB connection
│       ├── engine.py                # Scanner engine logic
│       ├── admin.py                 # Admin interface
│       └── migrations/              # (empty - uses MongoDB)
│
└── manage.py                        # Django management script
```

### Key Architectural Decisions

1. **Centralized API Routing**: All REST API endpoints go through `apps.api`
2. **Separation of Concerns**:
   - Models live in standalone apps (`apps.todos`, `apps.scanner`)
   - Views/Serializers for APIs live under `apps.api/`
3. **Mixed Database Support**: PostgreSQL (Django ORM) + MongoDB (pymongo)

---

## 🚀 Method 1: Adding a New Feature to Existing API (Recommended)

Use this when adding new features that belong to existing functionality.

### Example: Adding a "Comments" feature to Todos

#### Step 1: Add Model to `apps.todos`

```bash
# Location: src/backend/apps/todos/models.py
```

```python
# Add to apps/todos/models.py

class TodoComment(models.Model):
    """
    Comments for Todo items
    """
    todo = models.ForeignKey(Todo, on_delete=models.CASCADE, related_name='comments')
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='todo_comments')
    content = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-created_at']
        verbose_name = 'Todo Comment'
        verbose_name_plural = 'Todo Comments'

    def __str__(self):
        return f"Comment by {self.user.username} on {self.todo.title}"
```

#### Step 2: Create and Run Migrations

```bash
cd src/backend

# Create migration
python manage.py makemigrations todos

# Apply migration
python manage.py migrate
```

#### Step 3: Add Serializer to `apps.api.todos`

```bash
# Location: src/backend/apps/api/todos/serializers.py
```

```python
# Add to apps/api/todos/serializers.py

from apps.todos.models import TodoComment

class TodoCommentSerializer(serializers.ModelSerializer):
    user = serializers.StringRelatedField(read_only=True)

    class Meta:
        model = TodoComment
        fields = ['id', 'todo', 'user', 'content', 'created_at', 'updated_at']
        read_only_fields = ['id', 'user', 'created_at', 'updated_at']
```

#### Step 4: Add ViewSet to `apps.api.todos`

```python
# Add to apps/api/todos/views.py

from apps.todos.models import TodoComment
from .serializers import TodoCommentSerializer

@extend_schema(tags=['Todos'])
class TodoCommentViewSet(viewsets.ModelViewSet):
    """
    ViewSet for Todo Comment CRUD operations
    """
    permission_classes = [IsAuthenticated]
    serializer_class = TodoCommentSerializer

    def get_queryset(self):
        return TodoComment.objects.filter(todo__user=self.request.user)

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)
```

#### Step 5: Register Routes in `apps.api.urls`

```python
# Update apps/api/urls.py

from .todos.views import TodoViewSet, TodoCommentViewSet  # Add import

# Add to router
router.register(r'todos/comments', TodoCommentViewSet, basename='todo-comment')
```

#### Step 6: Update API Documentation Tags (Optional)

```python
# In config/settings.py - SPECTACULAR_SETTINGS

'TAGS': [
    {'name': 'Authentication', 'description': 'Authentication endpoints (JWT tokens)'},
    {'name': 'Todos', 'description': 'Todo and Comment management endpoints'},  # Updated
    {'name': 'Scanner', 'description': 'Security scanner endpoints'},
],
```

---

## 🏗️ Method 2: Adding a Completely New Django App

Use this when adding a major new feature domain (e.g., User Profiles, Notifications, Reports).

### Example: Creating a "Profiles" App

#### Step 1: Create Django App

```bash
cd src/backend

# Create new app in apps/ directory
python manage.py startapp profiles apps/profiles
```

This creates:

```
apps/profiles/
├── __init__.py
├── admin.py
├── apps.py
├── models.py
├── tests.py
└── views.py
```

#### Step 2: Update App Configuration

```python
# Edit apps/profiles/apps.py

from django.apps import AppConfig

class ProfilesConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'apps.profiles'  # ⚠️ IMPORTANT: Full path
    verbose_name = 'User Profiles'
```

#### Step 3: Register App in Settings

```python
# Edit config/settings.py

INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    # ... other Django apps ...

    # Third party apps
    'rest_framework',
    'rest_framework_simplejwt',
    'corsheaders',
    'drf_spectacular',
    'django_filters',

    # Local apps
    'apps.api.apps.ApiConfig',
    'apps.todos.apps.TodosConfig',
    'apps.scanner.apps.ScannerConfig',
    'apps.profiles.apps.ProfilesConfig',  # ⬅️ ADD THIS
]
```

#### Step 4: Create Models

```python
# Edit apps/profiles/models.py

from django.db import models
from django.contrib.auth.models import User
from django.db.models.signals import post_save
from django.dispatch import receiver

class UserProfile(models.Model):
    """
    Extended user profile information
    """
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='profile')
    bio = models.TextField(blank=True)
    avatar = models.URLField(blank=True)
    phone = models.CharField(max_length=20, blank=True)
    location = models.CharField(max_length=100, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name = 'User Profile'
        verbose_name_plural = 'User Profiles'

    def __str__(self):
        return f"{self.user.username}'s Profile"

# Auto-create profile when user is created
@receiver(post_save, sender=User)
def create_user_profile(sender, instance, created, **kwargs):
    if created:
        UserProfile.objects.create(user=instance)

@receiver(post_save, sender=User)
def save_user_profile(sender, instance, **kwargs):
    instance.profile.save()
```

#### Step 5: Create Migrations

```bash
python manage.py makemigrations profiles
python manage.py migrate
```

#### Step 6: Create API Views/Serializers under `apps.api`

```bash
# Create subdirectory for profile API
mkdir src/backend/apps/api/profiles
```

Create files:

**`apps/api/profiles/__init__.py`**

```python
# Empty file
```

**`apps/api/profiles/serializers.py`**

```python
from rest_framework import serializers
from apps.profiles.models import UserProfile
from django.contrib.auth.models import User

class UserProfileSerializer(serializers.ModelSerializer):
    username = serializers.CharField(source='user.username', read_only=True)
    email = serializers.EmailField(source='user.email', read_only=True)

    class Meta:
        model = UserProfile
        fields = ['id', 'username', 'email', 'bio', 'avatar', 'phone', 'location', 'created_at', 'updated_at']
        read_only_fields = ['id', 'username', 'email', 'created_at', 'updated_at']
```

**`apps/api/profiles/views.py`**

```python
from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from drf_spectacular.utils import extend_schema
from apps.profiles.models import UserProfile
from .serializers import UserProfileSerializer

@extend_schema(tags=['Profiles'])
class ProfileViewSet(viewsets.ModelViewSet):
    """
    ViewSet for User Profile operations
    """
    permission_classes = [IsAuthenticated]
    serializer_class = UserProfileSerializer

    def get_queryset(self):
        # Users can only see their own profile
        return UserProfile.objects.filter(user=self.request.user)

    @action(detail=False, methods=['get', 'put', 'patch'])
    def me(self, request):
        """Get or update current user's profile"""
        profile = request.user.profile

        if request.method == 'GET':
            serializer = self.get_serializer(profile)
            return Response(serializer.data)

        serializer = self.get_serializer(profile, data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(serializer.data)
```

#### Step 7: Register Routes in `apps.api.urls`

```python
# Update apps/api/urls.py

from .profiles.views import ProfileViewSet  # Add import

# Add to router
router.register(r'profiles', ProfileViewSet, basename='profile')
```

#### Step 8: Update Admin Interface

```python
# Edit apps/profiles/admin.py

from django.contrib import admin
from .models import UserProfile

@admin.register(UserProfile)
class UserProfileAdmin(admin.ModelAdmin):
    list_display = ['user', 'phone', 'location', 'created_at']
    search_fields = ['user__username', 'user__email', 'phone']
    list_filter = ['created_at']
    readonly_fields = ['created_at', 'updated_at']
```

#### Step 9: Update API Documentation

```python
# In config/settings.py - SPECTACULAR_SETTINGS

'TAGS': [
    {'name': 'Authentication', 'description': 'Authentication endpoints (JWT tokens)'},
    {'name': 'Profiles', 'description': 'User profile management'},  # ADD THIS
    {'name': 'Todos', 'description': 'Todo management endpoints'},
    {'name': 'Scanner', 'description': 'Security scanner endpoints'},
],
```

#### Step 10: Write Tests (Optional but Recommended)

```python
# Edit apps/profiles/tests.py

from django.test import TestCase
from django.contrib.auth.models import User
from apps.profiles.models import UserProfile

class UserProfileTestCase(TestCase):
    def setUp(self):
        self.user = User.objects.create_user(
            username='testuser',
            password='testpass123'
        )

    def test_profile_created_automatically(self):
        """Test that profile is auto-created when user is created"""
        self.assertTrue(hasattr(self.user, 'profile'))
        self.assertIsInstance(self.user.profile, UserProfile)

    def test_profile_str(self):
        """Test profile string representation"""
        self.assertEqual(str(self.user.profile), "testuser's Profile")
```

Run tests:

```bash
python manage.py test apps.profiles
```

---

## 📊 Method 3: Adding MongoDB-Based App (Like Scanner)

Use this for apps that need NoSQL database (flexible schemas, high scalability).

### Example: Creating a "Logs" App with MongoDB

#### Step 1: Create Django App

```bash
cd src/backend
python manage.py startapp logs apps/logs
```

#### Step 2: Update App Configuration

```python
# Edit apps/logs/apps.py

from django.apps import AppConfig

class LogsConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'apps.logs'
    verbose_name = 'Application Logs'
```

#### Step 3: Register in Settings

```python
# In config/settings.py - INSTALLED_APPS
'apps.logs.apps.LogsConfig',  # Add this
```

#### Step 4: Create MongoDB Connection Helper

```python
# Create apps/logs/db.py

from pymongo import MongoClient
from django.conf import settings
import logging

logger = logging.getLogger(__name__)

_mongo_client = None
_mongo_db = None

def get_mongodb():
    """Get MongoDB database connection."""
    global _mongo_client, _mongo_db

    if _mongo_db is None:
        try:
            mongo_settings = settings.MONGODB_SETTINGS
            _mongo_client = MongoClient(
                host=mongo_settings['host'],
                port=mongo_settings['port'],
                serverSelectionTimeoutMS=5000
            )
            _mongo_db = _mongo_client[mongo_settings['database']]
            logger.info(f"Connected to MongoDB: {mongo_settings['database']}")
        except Exception as e:
            logger.error(f"Failed to connect to MongoDB: {str(e)}")
            return None

    return _mongo_db
```

#### Step 5: Create MongoDB Models

```python
# Create apps/logs/models.py

from bson import ObjectId
from datetime import datetime
from .db import get_mongodb

class BaseMongoModel:
    """Base class for MongoDB models."""
    collection_name = None

    @classmethod
    def get_collection(cls):
        """Get MongoDB collection."""
        db = get_mongodb()
        if db is None:
            raise RuntimeError("MongoDB is not available")
        return db[cls.collection_name]

    @classmethod
    def to_dict(cls, document):
        """Convert MongoDB document to dict with string _id."""
        if document is None:
            return None
        doc_dict = dict(document)
        if '_id' in doc_dict:
            doc_dict['_id'] = str(doc_dict['_id'])
        return doc_dict

class ApplicationLog(BaseMongoModel):
    """MongoDB model for application logs."""

    collection_name = 'application_logs'

    @classmethod
    def create(cls, log_data):
        """Create a new log entry."""
        collection = cls.get_collection()
        log_data['created_at'] = datetime.utcnow()
        result = collection.insert_one(log_data)
        return str(result.inserted_id)

    @classmethod
    def find_all(cls, filters=None, limit=100, skip=0):
        """Get all logs with optional filters."""
        collection = cls.get_collection()
        filters = filters or {}
        cursor = collection.find(filters).sort('created_at', -1).limit(limit).skip(skip)
        return cls.to_dict_list(cursor)

    @classmethod
    def find_by_id(cls, log_id):
        """Get log by ID."""
        collection = cls.get_collection()
        document = collection.find_one({'_id': ObjectId(log_id)})
        return cls.to_dict(document)
```

#### Step 6: Create API Serializers and Views

Follow same pattern as Method 2, Steps 6-7 (create under `apps.api/logs/`)

---

## 🔧 Configuration Checklist

### For Every New App, Ensure:

- [ ] **App created** in `apps/` directory
- [ ] **apps.py** configured with correct `name` path
- [ ] **Registered** in `config/settings.py` → `INSTALLED_APPS`
- [ ] **Models created** (PostgreSQL or MongoDB)
- [ ] **Migrations run** (if using PostgreSQL)
- [ ] **API views/serializers** created under `apps.api/<app_name>/`
- [ ] **Routes registered** in `apps.api.urls.py`
- [ ] **Admin interface** configured (if needed)
- [ ] **API docs tags** updated in `SPECTACULAR_SETTINGS`
- [ ] **Tests written** and passing
- [ ] **Documentation** updated

---

## 📝 Environment Variables

### For New Apps Requiring Config

Add to `.env.example` and `.env`:

```bash
# Example: Adding email configuration for new notifications app
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@example.com
SMTP_PASSWORD=your-password
SMTP_USE_TLS=True
```

Access in settings:

```python
# In config/settings.py
EMAIL_HOST = config('SMTP_HOST', default='localhost')
EMAIL_PORT = config('SMTP_PORT', default=587, cast=int)
EMAIL_USE_TLS = config('SMTP_USE_TLS', default=True, cast=bool)
```

---

## 🧪 Testing New Apps

```bash
# Test specific app
python manage.py test apps.<app_name>

# Test with coverage
pip install coverage
coverage run --source='apps' manage.py test
coverage report
coverage html  # Open htmlcov/index.html
```

---

## 🎯 Best Practices

### 1. **Naming Conventions**

- Apps: lowercase, plural (e.g., `todos`, `profiles`, `notifications`)
- Models: PascalCase, singular (e.g., `Todo`, `UserProfile`)
- Serializers: `<Model>Serializer` (e.g., `TodoSerializer`)
- ViewSets: `<Model>ViewSet` (e.g., `TodoViewSet`)

### 2. **File Organization**

```
apps/<app_name>/
├── models.py          # Database models
├── apps.py            # App configuration
├── admin.py           # Admin interface
├── tests.py           # Unit tests
└── management/        # Management commands
    └── commands/
```

```
apps/api/<app_name>/
├── views.py           # API ViewSets
├── serializers.py     # DRF Serializers
└── __init__.py
```

### 3. **Database Choices**

- **PostgreSQL** (Django ORM): Structured data, relationships, ACID compliance
- **MongoDB** (pymongo): Flexible schemas, high write throughput, nested documents

### 4. **API Design**

- Use **ViewSets** for standard CRUD operations
- Use **@action** decorators for custom endpoints
- Always use **@extend_schema** for API documentation
- Group related endpoints with **tags**

### 5. **Security**

- Always use `IsAuthenticated` permission class
- Filter querysets by current user
- Use `perform_create()` to set user automatically
- Validate all input data

### 6. **Documentation**

- Add docstrings to all models, views, and functions
- Update API documentation tags in settings
- Keep README files updated

---

## 🚨 Common Pitfalls

### ❌ Wrong App Name Path

```python
# WRONG
name = 'profiles'  # Will fail if app is in apps/ subdirectory

# CORRECT
name = 'apps.profiles'
```

### ❌ Forgetting to Register App

```python
# Must add to INSTALLED_APPS in config/settings.py
'apps.myapp.apps.MyAppConfig',
```

### ❌ Not Running Migrations

```bash
# Always run after model changes
python manage.py makemigrations
python manage.py migrate
```

### ❌ Wrong Import Paths

```python
# WRONG (circular imports, wrong paths)
from .models import Todo

# CORRECT (when in apps/api/)
from apps.todos.models import Todo
```

### ❌ Not Using Full Dotted Path in URLs

```python
# In config/urls.py - CORRECT
path('api/', include('apps.api.urls')),  # Full path
```

---

## 📚 Quick Reference

### File Locations Summary

| Component       | Location                        | Purpose                       |
| --------------- | ------------------------------- | ----------------------------- |
| Models          | `apps/<app>/models.py`          | Database schema               |
| App Config      | `apps/<app>/apps.py`            | App registration              |
| API Views       | `apps/api/<app>/views.py`       | REST API endpoints            |
| API Serializers | `apps/api/<app>/serializers.py` | Data validation/serialization |
| URL Routing     | `apps/api/urls.py`              | Central API routing           |
| Settings        | `config/settings.py`            | Project configuration         |
| Root URLs       | `config/urls.py`                | Root URL configuration        |
| Admin           | `apps/<app>/admin.py`           | Django admin interface        |
| Tests           | `apps/<app>/tests.py`           | Unit tests                    |
| Migrations      | `apps/<app>/migrations/`        | Database migrations           |

---

## 🎓 Examples in Current Project

### Example 1: Todos App (PostgreSQL + REST API)

- **Models**: `apps/todos/models.py` → Todo model
- **API Views**: `apps/api/todos/views.py` → TodoViewSet
- **API Serializers**: `apps/api/todos/serializers.py` → TodoSerializer
- **Routes**: `apps/api/urls.py` → `router.register(r'todos', TodoViewSet)`
- **Database**: PostgreSQL (Django ORM)

### Example 2: Scanner App (MongoDB + REST API)

- **Models**: `apps/scanner/models.py` → Resource, Rule, Finding (pymongo)
- **API Views**: `apps/api/scanner/views.py` → ResourceViewSet, etc.
- **API Serializers**: `apps/api/scanner/serializers.py` → ResourceSerializer
- **Routes**: `apps/api/urls.py` → Multiple scanner routes
- **Database**: MongoDB (pymongo)

### Example 3: API App (Centralized Routing)

- **Purpose**: Central API routing and authentication
- **Views**: `apps/api/views.py` → register, api_root
- **URLs**: `apps/api/urls.py` → Router + includes
- **No Models**: This app doesn't have its own models

---

## 📞 Need Help?

Refer to:

- Django Documentation: https://docs.djangoproject.com/
- DRF Documentation: https://www.django-rest-framework.org/
- Project docs: `docs/` directory
- Existing apps: Study `apps/todos` and `apps/scanner` as templates

---

**Last Updated**: November 2024
**Version**: 1.0
