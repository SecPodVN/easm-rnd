# Backend API Development Guide

**A comprehensive guide for developers new to the EASM Platform project**

This guide will walk you through adding new REST APIs to the EASM Platform backend. Whether you're adding a simple CRUD endpoint or a complex feature, this guide has you covered.

---

## 📚 Table of Contents

1. [Quick Start](#-quick-start)
2. [Poetry Workflow](#-poetry-workflow)
3. [Understanding the Architecture](#-understanding-the-architecture)
4. [Before You Start](#-before-you-start)
5. [Adding Your First API - Quick Recipe](#-adding-your-first-api---quick-recipe)
6. [Method 1: Adding to Existing API Module](#-method-1-adding-to-existing-api-module)
7. [Method 2: Creating a New API Module](#-method-2-creating-a-new-api-module)
8. [Method 3: MongoDB-Based API](#-method-3-mongodb-based-api)
9. [Testing Your API](#-testing-your-api)
10. [API Best Practices](#-api-best-practices)
11. [Common Patterns & Examples](#-common-patterns--examples)
12. [Troubleshooting](#-troubleshooting)
13. [Checklist & Quick Reference](#-checklist--quick-reference)

---

## 🚀 Quick Start

### The 5-Minute Overview

**Our backend structure follows this pattern:**

```
easm-platform/
└── src/
    └── backend/
        ├── easm/                      # 🎯 Main Django Project
        │   ├── config/                # Django project settings
        │   │   ├── settings.py       # Main configuration
        │   │   └── urls.py           # Root URL routing (registers /api/)
        │   │
        │   ├── apps/
        │   │   ├── api/              # 🎯 CENTRAL API HUB
        │   │   │   ├── urls.py      # ⭐ Register all API routes HERE
        │   │   │   ├── views.py     # Authentication views
        │   │   │   └── todos/       # Todo API endpoints
        │   │   │       ├── views.py
        │   │   │       └── serializers.py
        │   │   │
        │   │   └── todos/           # 📦 Todo domain (models & logic)
        │   │       └── models.py
        │   │
        │   └── manage.py
        │
        └── easm-core/                # 📚 Shared libraries & utilities
```

**Key Concept:**

- **Models** live in domain apps (`apps/todos/`, `apps/scanner/`)
- **API Views & Serializers** live in `apps/api/[domain]/`
- **All routes** are registered in `apps/api/urls.py`

### Your First API in 3 Steps

```bash
# 1. Create your model in a domain app
# Edit: src/backend/easm/apps/[your_app]/models.py

# 2. Create API views/serializers
# Create: src/backend/easm/apps/api/[your_app]/views.py
# Create: src/backend/easm/apps/api/[your_app]/serializers.py

# 3. Register routes
# Edit: src/backend/easm/apps/api/urls.py
```

---

## 🎯 Poetry Workflow

**EASM Platform uses Poetry for dependency management**. All Python commands must be run through Poetry.

### Understanding Poetry in EASM

```
src/backend/easm/
├── pyproject.toml      # ⭐ Poetry configuration & dependencies
├── poetry.lock         # Locked dependency versions
└── manage.py           # Django management
```

### Essential Poetry Commands

```bash
# Navigate to the Django project directory first
cd src/backend/easm

# Install all dependencies
poetry install

# Add a new dependency
poetry add <package-name>
poetry add requests django-extensions

# Add development dependency
poetry add --group dev pytest-cov

# Update dependencies
poetry update
poetry update <package-name>

# Show installed packages
poetry show
poetry show --tree

# Activate virtual environment (Option 1 - Recommended)
poetry shell
# Now you can run commands directly: python manage.py runserver

# Run commands without activating shell (Option 2)
poetry run python manage.py runserver
poetry run python manage.py migrate
poetry run pytest

# Check Python version
poetry run python --version

# Exit poetry shell
exit
```

### Poetry vs pip

| Task                     | Poetry Command                        | Old pip Way                       |
| ------------------------ | ------------------------------------- | --------------------------------- |
| **Install dependencies** | `poetry install`                      | `pip install -r requirements.txt` |
| **Add package**          | `poetry add django-extensions`        | `pip install django-extensions`   |
| **Run Django command**   | `poetry run python manage.py migrate` | `python manage.py migrate`        |
| **Activate environment** | `poetry shell`                        | `source venv/bin/activate`        |
| **Run tests**            | `poetry run pytest`                   | `pytest`                          |
| **Format code**          | `poetry run black .`                  | `black .`                         |

### Why Poetry?

✅ **Dependency Resolution** - Automatically resolves compatible versions
✅ **Lock File** - Ensures consistent installs across environments
✅ **Separation** - Dev and production dependencies separated
✅ **Virtual Environments** - Automatically manages virtual environments
✅ **pyproject.toml** - Modern Python standard (PEP 518)

### Working Directory

**⚠️ Important**: All Poetry commands must be run from `src/backend/easm/` where `pyproject.toml` is located.

```bash
# ✅ Correct
cd src/backend/easm
poetry run python manage.py runserver

# ❌ Wrong - No pyproject.toml here
cd src/backend
poetry run python manage.py runserver  # Error!

# ❌ Wrong - No pyproject.toml here
cd easm-rnd
poetry run python manage.py runserver  # Error!
```

### Common Workflow

```bash
# 1. One-time setup
cd src/backend/easm
poetry install

# 2. Start development (choose one method)

# Method A: Using poetry shell (recommended for active development)
poetry shell
python manage.py runserver
python manage.py makemigrations
python manage.py migrate
black .
pytest
exit  # when done

# Method B: Using poetry run (good for quick commands)
poetry run python manage.py runserver
poetry run python manage.py migrate
poetry run black .
poetry run pytest
```

---

## 🏗️ Understanding the Architecture

### Why This Structure?

Our architecture separates **domain logic** from **API logic**:

```
┌─────────────────────────────────────────────────────┐
│  CLIENT (React Frontend, Mobile App, etc.)          │
└────────────────────┬────────────────────────────────┘
                     │ HTTP/HTTPS
                     ▼
┌─────────────────────────────────────────────────────┐
│  config/urls.py → path('api/', include('apps.api')) │
└────────────────────┬────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────┐
│  apps/api/urls.py (CENTRAL ROUTING)                 │
│  • router.register('todos', TodoViewSet)            │
│  • router.register('profiles', ProfileViewSet)       │
└────────────────────┬────────────────────────────────┘
                     │
        ┌────────────┴────────────┐
        ▼                         ▼
┌──────────────────┐    ┌──────────────────┐
│ apps/api/todos/  │    │ apps/api/scanner/│
│ • views.py       │    │ • views.py       │
│ • serializers.py │    │ • serializers.py │
└────────┬─────────┘    └────────┬─────────┘
         │                       │
         ▼                       ▼
┌──────────────────┐    ┌──────────────────┐
│ apps/todos/      │    │ apps/scanner/    │
│ • models.py      │    │ • models.py      │
│ (PostgreSQL)     │    │ (MongoDB)        │
└──────────────────┘    └──────────────────┘
```

### Current API Endpoints

Base URL: `http://localhost:8000/api/`

| Endpoint                  | Method                  | Description            | App     |
| ------------------------- | ----------------------- | ---------------------- | ------- |
| `/api/token/`             | POST                    | Login (get JWT tokens) | auth    |
| `/api/token/refresh/`     | POST                    | Refresh access token   | auth    |
| `/api/token/register/`    | POST                    | Register new user      | auth    |
| `/api/todos/`             | GET, POST               | List/Create todos      | todos   |
| `/api/todos/{id}/`        | GET, PUT, PATCH, DELETE | Todo detail            | todos   |

---

## ✅ Before You Start

### Prerequisites

1. **Environment Setup**

   ```bash
   # Ensure you have .env configured (from project root)
   cp .env.example .env

   # Navigate to the Django project directory
   cd src/backend/easm

   # Install dependencies with Poetry
   poetry install

   # Activate Poetry shell (recommended)
   poetry shell

   # Or run commands with 'poetry run' prefix
   poetry run python --version
   ```

   **Important**: All Poetry commands must be run from `src/backend/easm/` where `pyproject.toml` is located.

2. **Understand These Files**

   - `config/settings.py` - Django configuration, `INSTALLED_APPS`
   - `config/urls.py` - Root URL routing
   - `apps/api/urls.py` - **Central API routing** (you'll edit this often!)
   - Existing examples: `apps/api/todos/` and `apps/api/scanner/`

3. **Know Your Database Choice**
   - **PostgreSQL** (via Django ORM) - For structured, relational data
   - **MongoDB** (via pymongo) - For flexible, document-based data

---

## 🎯 Adding Your First API - Quick Recipe

Let's add a **"Notes" API** step-by-step (PostgreSQL example):

### Step 1: Create Domain App

```bash
# Navigate to Django project directory
cd src/backend/easm

# Create new app using Poetry
poetry run poetry run python manage.py startapp notes apps/notes
```

### Step 2: Configure the App

**Edit `apps/notes/apps.py`:**

```python
from django.apps import AppConfig

class NotesConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'apps.notes'  # ⚠️ MUST include 'apps.' prefix
    verbose_name = 'Notes'
```

**Register in `config/settings.py`:**

```python
INSTALLED_APPS = [
    # ... existing apps ...
    'apps.api.apps.ApiConfig',
    'apps.todos.apps.TodosConfig',
    'apps.scanner.apps.ScannerConfig',
    'apps.notes.apps.NotesConfig',  # ⬅️ ADD THIS
]
```

### Step 3: Create Model

**Edit `apps/notes/models.py`:**

```python
from django.db import models
from django.contrib.auth.models import User

class Note(models.Model):
    """Simple note model"""
    title = models.CharField(max_length=200)
    content = models.TextField()
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='notes')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-created_at']
        verbose_name = 'Note'
        verbose_name_plural = 'Notes'

    def __str__(self):
        return self.title
```

### Step 4: Create & Run Migrations

```bash
# Run from src/backend/easm/
poetry run poetry run python manage.py makemigrations notes
poetry run poetry run python manage.py migrate
```

### Step 5: Create API Directory

```bash
mkdir -p apps/api/notes
touch apps/api/notes/__init__.py
touch apps/api/notes/views.py
touch apps/api/notes/serializers.py
```

### Step 6: Create Serializer

**Create `apps/api/notes/serializers.py`:**

```python
from rest_framework import serializers
from apps.notes.models import Note

class NoteSerializer(serializers.ModelSerializer):
    """Serializer for Note model"""
    class Meta:
        model = Note
        fields = ['id', 'title', 'content', 'created_at', 'updated_at']
        read_only_fields = ['id', 'created_at', 'updated_at']
```

### Step 7: Create ViewSet

**Create `apps/api/notes/views.py`:**

```python
from rest_framework import viewsets
from rest_framework.permissions import IsAuthenticated
from drf_spectacular.utils import extend_schema
from apps.notes.models import Note
from .serializers import NoteSerializer

@extend_schema(tags=['Notes'])
class NoteViewSet(viewsets.ModelViewSet):
    """
    API endpoints for Notes

    Provides:
    - list: GET /api/notes/
    - create: POST /api/notes/
    - retrieve: GET /api/notes/{id}/
    - update: PUT /api/notes/{id}/
    - partial_update: PATCH /api/notes/{id}/
    - destroy: DELETE /api/notes/{id}/
    """
    permission_classes = [IsAuthenticated]
    serializer_class = NoteSerializer

    def get_queryset(self):
        """Return notes for current user only"""
        return Note.objects.filter(user=self.request.user)

    def perform_create(self, serializer):
        """Set user when creating note"""
        serializer.save(user=self.request.user)
```

### Step 8: Register Routes

**Edit `apps/api/urls.py`:**

```python
from django.urls import path, include
from rest_framework.routers import DefaultRouter

from .views import api_root
from .todos.views import TodoViewSet
from .scanner.views import (
    scanner_health, ResourceViewSet, RuleViewSet,
    FindingViewSet, ScannerViewSet
)
from .notes.views import NoteViewSet  # ⬅️ ADD IMPORT

# Central API router
router = DefaultRouter()
router.register(r'todos', TodoViewSet, basename='todo')
router.register(r'scanner/resources', ResourceViewSet, basename='scanner-resource')
router.register(r'scanner/rules', RuleViewSet, basename='scanner-rule')
router.register(r'scanner/findings', FindingViewSet, basename='scanner-finding')
router.register(r'scanner/scan', ScannerViewSet, basename='scanner-scan')
router.register(r'notes', NoteViewSet, basename='note')  # ⬅️ ADD ROUTE

app_name = 'api'

urlpatterns = [
    path('', api_root, name='api-root'),
    path('scanner/healthStatus', scanner_health, name='scanner-health'),
    path('', include(router.urls)),
]
```

### Step 9: Update API Documentation Tags (Optional)

**Edit `config/settings.py` - SPECTACULAR_SETTINGS:**

```python
SPECTACULAR_SETTINGS = {
    'TITLE': 'EASM API',
    'DESCRIPTION': 'EASM Django REST API',
    'VERSION': '1.0.0',
    'SERVE_INCLUDE_SCHEMA': False,
    'TAGS': [
        {'name': 'Authentication', 'description': 'Authentication endpoints (JWT tokens)'},
        {'name': 'Todos', 'description': 'Todo management endpoints'},
        {'name': 'Scanner', 'description': 'Security scanner endpoints'},
        {'name': 'Notes', 'description': 'Note management endpoints'},  # ⬅️ ADD THIS
    ],
    'SCHEMA_COERCE_PATH_PK_SUFFIX': True,
    'COMPONENT_SPLIT_REQUEST': True,
}
```

### Step 10: Test Your API

```bash
# Start development server
poetry run python manage.py runserver

# Visit Swagger UI
# http://localhost:8000/api/docs/

# Test with curl (after getting JWT token)
curl -H "Authorization: Bearer YOUR_TOKEN" http://localhost:8000/api/notes/
```

**🎉 Congratulations! You just created your first API!**

---

## 📦 Method 1: Adding to Existing API Module

Use this when adding features to an existing domain (e.g., adding "Comments" to Todos).

### Example: Adding Comments to Todos

#### Step 1: Add Model to Existing Domain App

**Edit `apps/todos/models.py`:**

```python
from django.db import models
from django.contrib.auth.models import User

# ... existing Todo model ...

class TodoComment(models.Model):
    """Comments for Todo items"""
    todo = models.ForeignKey(Todo, on_delete=models.CASCADE, related_name='comments')
    user = models.ForeignKey(User, on_delete=models.CASCADE)
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

#### Step 2: Create & Run Migration

```bash
poetry run python manage.py makemigrations todos
poetry run python manage.py migrate
```

#### Step 3: Add Serializer

**Edit `apps/api/todos/serializers.py`:**

```python
from rest_framework import serializers
from apps.todos.models import Todo, TodoComment  # Add TodoComment

# ... existing serializers ...

class TodoCommentSerializer(serializers.ModelSerializer):
    """Serializer for Todo Comments"""
    user = serializers.StringRelatedField(read_only=True)

    class Meta:
        model = TodoComment
        fields = ['id', 'todo', 'user', 'content', 'created_at', 'updated_at']
        read_only_fields = ['id', 'user', 'created_at', 'updated_at']
```

#### Step 4: Add ViewSet

**Edit `apps/api/todos/views.py`:**

```python
from rest_framework import viewsets
from rest_framework.permissions import IsAuthenticated
from drf_spectacular.utils import extend_schema
from apps.todos.models import Todo, TodoComment
from .serializers import TodoSerializer, TodoCommentSerializer

# ... existing TodoViewSet ...

@extend_schema(tags=['Todos'])
class TodoCommentViewSet(viewsets.ModelViewSet):
    """API endpoints for Todo Comments"""
    permission_classes = [IsAuthenticated]
    serializer_class = TodoCommentSerializer

    def get_queryset(self):
        """Return comments for todos owned by current user"""
        return TodoComment.objects.filter(todo__user=self.request.user)

    def perform_create(self, serializer):
        """Set user when creating comment"""
        serializer.save(user=self.request.user)
```

#### Step 5: Register Route

**Edit `apps/api/urls.py`:**

```python
from .todos.views import TodoViewSet, TodoCommentViewSet  # Add import

router.register(r'todos', TodoViewSet, basename='todo')
router.register(r'todos/comments', TodoCommentViewSet, basename='todo-comment')  # Add route
```

---

## 🏗️ Method 2: Creating a New API Module

Use this for major new features (e.g., User Profiles, Notifications, Projects).

### Example: Creating a "Profiles" API

#### Step 1: Create Django App

```bash
cd src/backend
poetry run python manage.py startapp profiles apps/profiles
```

This creates:

```
apps/profiles/
├── __init__.py
├── admin.py
├── apps.py
├── models.py
├── tests.py
└── migrations/
```

#### Step 2: Configure App

**Edit `apps/profiles/apps.py`:**

```python
from django.apps import AppConfig

class ProfilesConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'apps.profiles'  # ⚠️ Must include 'apps.' prefix
    verbose_name = 'User Profiles'
```

**Register in `config/settings.py`:**

```python
INSTALLED_APPS = [
    # Django apps...
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

#### Step 3: Create Models

**Edit `apps/profiles/models.py`:**

```python
from django.db import models
from django.contrib.auth.models import User
from django.db.models.signals import post_save
from django.dispatch import receiver

class UserProfile(models.Model):
    """Extended user profile information"""
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
    if hasattr(instance, 'profile'):
        instance.profile.save()
```

#### Step 4: Create & Run Migrations

```bash
poetry run python manage.py makemigrations profiles
poetry run python manage.py migrate
```

#### Step 5: Create API Structure

```bash
mkdir -p apps/api/profiles
touch apps/api/profiles/__init__.py
touch apps/api/profiles/views.py
touch apps/api/profiles/serializers.py
```

#### Step 6: Create Serializers

**Create `apps/api/profiles/serializers.py`:**

```python
from rest_framework import serializers
from apps.profiles.models import UserProfile
from django.contrib.auth.models import User

class UserProfileSerializer(serializers.ModelSerializer):
    """Serializer for UserProfile model"""
    username = serializers.CharField(source='user.username', read_only=True)
    email = serializers.EmailField(source='user.email', read_only=True)

    class Meta:
        model = UserProfile
        fields = [
            'id', 'username', 'email', 'bio', 'avatar',
            'phone', 'location', 'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'username', 'email', 'created_at', 'updated_at']
```

#### Step 7: Create ViewSet

**Create `apps/api/profiles/views.py`:**

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
    API endpoints for User Profiles

    Provides:
    - list: GET /api/profiles/
    - retrieve: GET /api/profiles/{id}/
    - update: PUT /api/profiles/{id}/
    - partial_update: PATCH /api/profiles/{id}/
    - me: GET /api/profiles/me/ (custom action for current user)
    """
    permission_classes = [IsAuthenticated]
    serializer_class = UserProfileSerializer

    def get_queryset(self):
        """Users can only see their own profile"""
        return UserProfile.objects.filter(user=self.request.user)

    @extend_schema(
        summary="Get current user's profile",
        description="Retrieve or update the authenticated user's profile"
    )
    @action(detail=False, methods=['get', 'put', 'patch'])
    def me(self, request):
        """Get or update current user's profile"""
        profile = request.user.profile

        if request.method == 'GET':
            serializer = self.get_serializer(profile)
            return Response(serializer.data)

        # PUT or PATCH
        partial = request.method == 'PATCH'
        serializer = self.get_serializer(profile, data=request.data, partial=partial)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(serializer.data)
```

#### Step 8: Register Routes

**Edit `apps/api/urls.py`:**

```python
from django.urls import path, include
from rest_framework.routers import DefaultRouter

from .views import api_root
from .todos.views import TodoViewSet
from .scanner.views import scanner_health, ResourceViewSet, RuleViewSet, FindingViewSet, ScannerViewSet
from .profiles.views import ProfileViewSet  # ⬅️ ADD IMPORT

router = DefaultRouter()
router.register(r'todos', TodoViewSet, basename='todo')
router.register(r'scanner/resources', ResourceViewSet, basename='scanner-resource')
router.register(r'scanner/rules', RuleViewSet, basename='scanner-rule')
router.register(r'scanner/findings', FindingViewSet, basename='scanner-finding')
router.register(r'scanner/scan', ScannerViewSet, basename='scanner-scan')
router.register(r'profiles', ProfileViewSet, basename='profile')  # ⬅️ ADD ROUTE

app_name = 'api'

urlpatterns = [
    path('', api_root, name='api-root'),
    path('scanner/healthStatus', scanner_health, name='scanner-health'),
    path('', include(router.urls)),
]
```

#### Step 9: Configure Admin Interface (Optional)

**Edit `apps/profiles/admin.py`:**

```python
from django.contrib import admin
from .models import UserProfile

@admin.register(UserProfile)
class UserProfileAdmin(admin.ModelAdmin):
    list_display = ['user', 'phone', 'location', 'created_at']
    search_fields = ['user__username', 'user__email', 'phone']
    list_filter = ['created_at']
    readonly_fields = ['created_at', 'updated_at']
```

#### Step 10: Update API Documentation

**Edit `config/settings.py` - SPECTACULAR_SETTINGS:**

```python
'TAGS': [
    {'name': 'Authentication', 'description': 'Authentication endpoints (JWT tokens)'},
    {'name': 'Profiles', 'description': 'User profile management'},  # ⬅️ ADD
    {'name': 'Todos', 'description': 'Todo management endpoints'},
    {'name': 'Scanner', 'description': 'Security scanner endpoints'},
],
```

---

## 🗄️ Method 3: MongoDB-Based API

Use this for apps requiring flexible schemas or document storage (like the scanner app).

### Example: Creating a "Logs" API with MongoDB

#### Step 1: Create Django App

```bash
cd src/backend
poetry run python manage.py startapp logs apps/logs
```

#### Step 2: Configure App

**Edit `apps/logs/apps.py`:**

```python
from django.apps import AppConfig

class LogsConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'apps.logs'
    verbose_name = 'Application Logs'
```

**Register in `config/settings.py`:**

```python
INSTALLED_APPS = [
    # ... existing apps ...
    'apps.logs.apps.LogsConfig',  # ⬅️ ADD
]
```

#### Step 3: Create MongoDB Connection

**Create `apps/logs/db.py`:**

```python
from pymongo import MongoClient
from django.conf import settings
import logging

logger = logging.getLogger(__name__)

_mongo_client = None
_mongo_db = None

def get_mongodb():
    """Get MongoDB database connection"""
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

#### Step 4: Create MongoDB Models

**Create `apps/logs/models.py`:**

```python
from bson import ObjectId
from datetime import datetime
from .db import get_mongodb
import logging

logger = logging.getLogger(__name__)

class BaseMongoModel:
    """Base class for MongoDB models"""
    collection_name = None

    @classmethod
    def get_collection(cls):
        """Get MongoDB collection"""
        db = get_mongodb()
        if db is None:
            raise RuntimeError("MongoDB is not available")
        return db[cls.collection_name]

    @classmethod
    def to_dict(cls, document):
        """Convert MongoDB document to dict with string _id"""
        if document is None:
            return None
        doc_dict = dict(document)
        if '_id' in doc_dict:
            doc_dict['_id'] = str(doc_dict['_id'])
        return doc_dict

    @classmethod
    def to_dict_list(cls, documents):
        """Convert list of documents to list of dicts"""
        return [cls.to_dict(doc) for doc in documents]


class ApplicationLog(BaseMongoModel):
    """MongoDB model for application logs"""

    collection_name = 'application_logs'

    @classmethod
    def create(cls, log_data):
        """Create a new log entry"""
        collection = cls.get_collection()
        log_data['created_at'] = datetime.utcnow()
        result = collection.insert_one(log_data)
        return str(result.inserted_id)

    @classmethod
    def find_all(cls, filters=None, limit=100, skip=0):
        """Get all logs with optional filters"""
        collection = cls.get_collection()
        filters = filters or {}
        cursor = collection.find(filters).sort('created_at', -1).limit(limit).skip(skip)
        return cls.to_dict_list(cursor)

    @classmethod
    def find_by_id(cls, log_id):
        """Get log by ID"""
        collection = cls.get_collection()
        document = collection.find_one({'_id': ObjectId(log_id)})
        return cls.to_dict(document)

    @classmethod
    def delete(cls, log_id):
        """Delete a log entry"""
        collection = cls.get_collection()
        result = collection.delete_one({'_id': ObjectId(log_id)})
        return result.deleted_count > 0
```

#### Step 5: Create API Structure

```bash
mkdir -p apps/api/logs
touch apps/api/logs/__init__.py
touch apps/api/logs/views.py
touch apps/api/logs/serializers.py
```

#### Step 6: Create Serializers

**Create `apps/api/logs/serializers.py`:**

```python
from rest_framework import serializers

class ApplicationLogSerializer(serializers.Serializer):
    """Serializer for Application Log (MongoDB)"""
    _id = serializers.CharField(read_only=True)
    level = serializers.ChoiceField(
        choices=['debug', 'info', 'warning', 'error', 'critical'],
        required=True
    )
    message = serializers.CharField(required=True)
    source = serializers.CharField(required=False, allow_blank=True)
    user_id = serializers.IntegerField(required=False, allow_null=True)
    metadata = serializers.JSONField(required=False)
    created_at = serializers.DateTimeField(read_only=True)
```

#### Step 7: Create ViewSet

**Create `apps/api/logs/views.py`:**

```python
from rest_framework import viewsets, status
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from drf_spectacular.utils import extend_schema
from bson import ObjectId
from apps.logs.models import ApplicationLog
from .serializers import ApplicationLogSerializer

@extend_schema(tags=['Logs'])
class LogViewSet(viewsets.ViewSet):
    """
    API endpoints for Application Logs (MongoDB)

    Provides:
    - list: GET /api/logs/
    - create: POST /api/logs/
    - retrieve: GET /api/logs/{id}/
    - destroy: DELETE /api/logs/{id}/
    """
    permission_classes = [IsAuthenticated]

    @extend_schema(
        summary="List all logs",
        responses={200: ApplicationLogSerializer(many=True)}
    )
    def list(self, request):
        """Get all logs with pagination"""
        try:
            page = int(request.query_params.get('page', 1))
            page_size = int(request.query_params.get('page_size', 10))
            skip = (page - 1) * page_size

            logs = ApplicationLog.find_all(limit=page_size, skip=skip)
            serializer = ApplicationLogSerializer(logs, many=True)
            return Response(serializer.data)
        except Exception as e:
            return Response(
                {'error': str(e)},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

    @extend_schema(
        summary="Create a log entry",
        request=ApplicationLogSerializer,
        responses={201: ApplicationLogSerializer}
    )
    def create(self, request):
        """Create a new log entry"""
        serializer = ApplicationLogSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        try:
            log_id = ApplicationLog.create(serializer.validated_data)
            log = ApplicationLog.find_by_id(log_id)
            return Response(
                ApplicationLogSerializer(log).data,
                status=status.HTTP_201_CREATED
            )
        except Exception as e:
            return Response(
                {'error': str(e)},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

    @extend_schema(
        summary="Get log by ID",
        responses={200: ApplicationLogSerializer}
    )
    def retrieve(self, request, pk=None):
        """Get a specific log entry"""
        try:
            log = ApplicationLog.find_by_id(pk)
            if log is None:
                return Response(
                    {'error': 'Log not found'},
                    status=status.HTTP_404_NOT_FOUND
                )
            serializer = ApplicationLogSerializer(log)
            return Response(serializer.data)
        except Exception as e:
            return Response(
                {'error': str(e)},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

    @extend_schema(summary="Delete a log entry")
    def destroy(self, request, pk=None):
        """Delete a log entry"""
        try:
            deleted = ApplicationLog.delete(pk)
            if not deleted:
                return Response(
                    {'error': 'Log not found'},
                    status=status.HTTP_404_NOT_FOUND
                )
            return Response(status=status.HTTP_204_NO_CONTENT)
        except Exception as e:
            return Response(
                {'error': str(e)},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
```

#### Step 8: Register Routes

**Edit `apps/api/urls.py`:**

```python
from .logs.views import LogViewSet  # ⬅️ ADD IMPORT

router.register(r'logs', LogViewSet, basename='log')  # ⬅️ ADD ROUTE
```

#### Step 9: Update API Documentation

**Edit `config/settings.py`:**

```python
'TAGS': [
    {'name': 'Authentication', 'description': 'Authentication endpoints (JWT tokens)'},
    {'name': 'Logs', 'description': 'Application log management'},  # ⬅️ ADD
    {'name': 'Todos', 'description': 'Todo management endpoints'},
    {'name': 'Scanner', 'description': 'Security scanner endpoints'},
],
```

---

## 🧪 Testing Your API

### Manual Testing with Swagger UI

1. **Start Development Server**

   ```bash
   cd src/backend
   poetry run python manage.py runserver
   ```

2. **Open Swagger UI**

   - Navigate to: `http://localhost:8000/api/docs/`
   - You'll see all your endpoints organized by tags

3. **Authenticate**

   - Click "Authorize" button (top right)
   - Get token from `/api/token/` endpoint
   - Enter: `Bearer YOUR_ACCESS_TOKEN`
   - Click "Authorize"

4. **Test Endpoints**
   - Expand your API section
   - Click "Try it out"
   - Fill in parameters
   - Click "Execute"

### Testing with curl

```bash
# 1. Get JWT Token
curl -X POST http://localhost:8000/api/token/ \
  -H "Content-Type: application/json" \
  -d '{"username": "your_username", "password": "your_password"}'

# Response: {"access": "...", "refresh": "..."}

# 2. Use Token to Access Protected Endpoint
curl -X GET http://localhost:8000/api/notes/ \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"

# 3. Create a New Resource
curl -X POST http://localhost:8000/api/notes/ \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"title": "My Note", "content": "Note content here"}'
```

### Testing with Python requests

```python
import requests

# Base URL
BASE_URL = "http://localhost:8000/api"

# 1. Get token
response = requests.post(f"{BASE_URL}/token/", json={
    "username": "your_username",
    "password": "your_password"
})
token = response.json()['access']

# 2. Set up headers
headers = {
    "Authorization": f"Bearer {token}",
    "Content-Type": "application/json"
}

# 3. Test your API
response = requests.get(f"{BASE_URL}/notes/", headers=headers)
print(response.json())

# 4. Create resource
response = requests.post(
    f"{BASE_URL}/notes/",
    headers=headers,
    json={"title": "Test Note", "content": "Content"}
)
print(response.json())
```

### Writing Unit Tests

**Create `apps/api/notes/tests.py`:**

```python
from django.test import TestCase
from django.contrib.auth.models import User
from rest_framework.test import APIClient
from rest_framework import status
from apps.notes.models import Note

class NoteAPITestCase(TestCase):
    def setUp(self):
        """Set up test fixtures"""
        self.client = APIClient()
        self.user = User.objects.create_user(
            username='testuser',
            password='testpass123'
        )
        self.client.force_authenticate(user=self.user)

        self.note = Note.objects.create(
            title='Test Note',
            content='Test content',
            user=self.user
        )

    def test_list_notes(self):
        """Test listing notes"""
        response = self.client.get('/api/notes/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data['results']), 1)

    def test_create_note(self):
        """Test creating a note"""
        data = {
            'title': 'New Note',
            'content': 'New content'
        }
        response = self.client.post('/api/notes/', data)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(Note.objects.count(), 2)

    def test_retrieve_note(self):
        """Test retrieving a specific note"""
        response = self.client.get(f'/api/notes/{self.note.id}/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['title'], 'Test Note')

    def test_update_note(self):
        """Test updating a note"""
        data = {'title': 'Updated Title'}
        response = self.client.patch(f'/api/notes/{self.note.id}/', data)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.note.refresh_from_db()
        self.assertEqual(self.note.title, 'Updated Title')

    def test_delete_note(self):
        """Test deleting a note"""
        response = self.client.delete(f'/api/notes/{self.note.id}/')
        self.assertEqual(response.status_code, status.HTTP_204_NO_CONTENT)
        self.assertEqual(Note.objects.count(), 0)

    def test_unauthenticated_access(self):
        """Test that unauthenticated requests are rejected"""
        self.client.force_authenticate(user=None)
        response = self.client.get('/api/notes/')
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)
```

**Run tests:**

```bash
# Run all tests
poetry run python manage.py test

# Run specific app tests
poetry run python manage.py test apps.api.notes

# Run with coverage
coverage run --source='apps' manage.py test
coverage report
coverage html  # Open htmlcov/index.html
```

---

## 💡 API Best Practices

### 1. **Always Use Authentication**

```python
from rest_framework.permissions import IsAuthenticated

class YourViewSet(viewsets.ModelViewSet):
    permission_classes = [IsAuthenticated]  # ⬅️ ALWAYS ADD THIS
```

### 2. **Filter by Current User**

```python
def get_queryset(self):
    """Users should only see their own data"""
    return Model.objects.filter(user=self.request.user)
```

### 3. **Auto-Set User on Creation**

```python
def perform_create(self, serializer):
    """Automatically set user when creating"""
    serializer.save(user=self.request.user)
```

### 4. **Use Proper HTTP Methods**

| Method | Purpose             | Example                 |
| ------ | ------------------- | ----------------------- |
| GET    | Retrieve data       | List items, get details |
| POST   | Create new resource | Create new item         |
| PUT    | Full update         | Replace entire resource |
| PATCH  | Partial update      | Update specific fields  |
| DELETE | Remove resource     | Delete item             |

### 5. **Add API Documentation**

```python
from drf_spectacular.utils import extend_schema

@extend_schema(tags=['YourFeature'])
class YourViewSet(viewsets.ModelViewSet):
    """
    Clear description of what this API does

    Provides:
    - list: GET /api/your-feature/
    - create: POST /api/your-feature/
    - etc.
    """
    pass

@extend_schema(
    summary="Short description",
    description="Detailed description of this endpoint"
)
@action(detail=True, methods=['post'])
def custom_action(self, request, pk=None):
    """Custom action description"""
    pass
```

### 6. **Validate Input Data**

```python
class YourSerializer(serializers.ModelSerializer):
    class Meta:
        model = YourModel
        fields = ['id', 'field1', 'field2']
        read_only_fields = ['id', 'created_at']  # Never let users modify these

    def validate_field1(self, value):
        """Custom validation for field1"""
        if len(value) < 3:
            raise serializers.ValidationError("Too short")
        return value

    def validate(self, data):
        """Cross-field validation"""
        if data['field1'] == data['field2']:
            raise serializers.ValidationError("Fields must be different")
        return data
```

### 7. **Handle Errors Gracefully**

```python
from rest_framework.exceptions import ValidationError, NotFound

def some_action(self, request):
    try:
        # Your logic here
        pass
    except YourModel.DoesNotExist:
        raise NotFound("Resource not found")
    except Exception as e:
        return Response(
            {'error': str(e)},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )
```

### 8. **Use Pagination**

Pagination is already configured globally in `settings.py`:

```python
REST_FRAMEWORK = {
    'DEFAULT_PAGINATION_CLASS': 'rest_framework.pagination.PageNumberPagination',
    'PAGE_SIZE': 10,
}
```

Response format:

```json
{
  "count": 25,
  "next": "http://localhost:8000/api/notes/?page=2",
  "previous": null,
  "results": [...]
}
```

### 9. **Enable Filtering & Searching**

```python
from django_filters.rest_framework import DjangoFilterBackend
from rest_framework import filters

class YourViewSet(viewsets.ModelViewSet):
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['status', 'category']  # Filter by these fields
    search_fields = ['title', 'description']    # Search in these fields
    ordering_fields = ['created_at', 'title']   # Allow ordering by these
    ordering = ['-created_at']                   # Default ordering
```

Usage:

```bash
# Filter
GET /api/notes/?status=active&category=personal

# Search
GET /api/notes/?search=keyword

# Order
GET /api/notes/?ordering=-created_at

# Combine
GET /api/notes/?status=active&search=important&ordering=title
```

### 10. **Use Custom Actions for Special Operations**

```python
from rest_framework.decorators import action

@action(detail=True, methods=['post'])
def archive(self, request, pk=None):
    """Archive this item"""
    obj = self.get_object()
    obj.archived = True
    obj.save()
    return Response({'status': 'archived'})

@action(detail=False, methods=['get'])
def recent(self, request):
    """Get recent items"""
    recent_items = self.get_queryset().order_by('-created_at')[:5]
    serializer = self.get_serializer(recent_items, many=True)
    return Response(serializer.data)
```

---

## 📚 Common Patterns & Examples

### Pattern 1: Nested Resources

**Scenario:** Comments belong to Posts

```python
# apps/api/urls.py
from rest_framework_nested import routers

router = routers.DefaultRouter()
router.register(r'posts', PostViewSet, basename='post')

posts_router = routers.NestedDefaultRouter(router, r'posts', lookup='post')
posts_router.register(r'comments', CommentViewSet, basename='post-comments')

urlpatterns = [
    path('', include(router.urls)),
    path('', include(posts_router.urls)),
]

# Results in URLs:
# /api/posts/                    # All posts
# /api/posts/{id}/comments/      # Comments for specific post
# /api/posts/{id}/comments/{id}/ # Specific comment
```

### Pattern 2: Bulk Operations

```python
from rest_framework.decorators import action

@action(detail=False, methods=['post'])
def bulk_create(self, request):
    """Create multiple items at once"""
    serializer = self.get_serializer(data=request.data, many=True)
    serializer.is_valid(raise_exception=True)
    self.perform_create(serializer)
    return Response(serializer.data, status=status.HTTP_201_CREATED)

@action(detail=False, methods=['delete'])
def bulk_delete(self, request):
    """Delete multiple items"""
    ids = request.data.get('ids', [])
    queryset = self.get_queryset().filter(id__in=ids)
    count = queryset.count()
    queryset.delete()
    return Response({'deleted': count})
```

### Pattern 3: File Upload

```python
from rest_framework.parsers import MultiPartParser, FormParser

class DocumentViewSet(viewsets.ModelViewSet):
    parser_classes = (MultiPartParser, FormParser)

    @action(detail=False, methods=['post'])
    def upload(self, request):
        """Upload a file"""
        file = request.FILES.get('file')
        if not file:
            return Response(
                {'error': 'No file provided'},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Process file
        document = Document.objects.create(
            user=request.user,
            file=file,
            filename=file.name
        )

        serializer = self.get_serializer(document)
        return Response(serializer.data, status=status.HTTP_201_CREATED)
```

### Pattern 4: Statistics/Analytics Endpoint

```python
from django.db.models import Count, Sum, Avg

@action(detail=False, methods=['get'])
def statistics(self, request):
    """Get statistics for current user's data"""
    queryset = self.get_queryset()

    stats = {
        'total_count': queryset.count(),
        'status_breakdown': queryset.values('status').annotate(
            count=Count('id')
        ),
        'average_completion_time': queryset.aggregate(
            avg_time=Avg('completion_time')
        )['avg_time']
    }

    return Response(stats)
```

### Pattern 5: Custom Permissions

**Create `apps/api/permissions.py`:**

```python
from rest_framework import permissions

class IsOwnerOrReadOnly(permissions.BasePermission):
    """
    Custom permission to only allow owners of an object to edit it.
    """
    def has_object_permission(self, request, view, obj):
        # Read permissions allowed to any request
        if request.method in permissions.SAFE_METHODS:
            return True

        # Write permissions only to the owner
        return obj.user == request.user

class IsAdminOrReadOnly(permissions.BasePermission):
    """
    Custom permission to only allow admins to edit.
    """
    def has_permission(self, request, view):
        if request.method in permissions.SAFE_METHODS:
            return True
        return request.user and request.user.is_staff
```

**Use in ViewSet:**

```python
from apps.api.permissions import IsOwnerOrReadOnly

class NoteViewSet(viewsets.ModelViewSet):
    permission_classes = [IsAuthenticated, IsOwnerOrReadOnly]
```

### Pattern 6: Soft Delete

```python
# In model
class Note(models.Model):
    # ... other fields ...
    is_deleted = models.BooleanField(default=False)
    deleted_at = models.DateTimeField(null=True, blank=True)

    def soft_delete(self):
        self.is_deleted = True
        self.deleted_at = timezone.now()
        self.save()

# In ViewSet
def destroy(self, request, *args, **kwargs):
    """Soft delete instead of hard delete"""
    instance = self.get_object()
    instance.soft_delete()
    return Response(status=status.HTTP_204_NO_CONTENT)

def get_queryset(self):
    """Exclude soft-deleted items"""
    return Note.objects.filter(user=self.request.user, is_deleted=False)
```

---

## 🐛 Troubleshooting

### Common Issues & Solutions

#### 1. **Poetry Command Not Found**

**Error:** `poetry: command not found`

**Solution:**

```bash
# Install Poetry
# Windows (PowerShell)
(Invoke-WebRequest -Uri https://install.python-poetry.org -UseBasicParsing).Content | python -

# Linux/macOS
curl -sSL https://install.python-poetry.org | python3 -

# Add to PATH and restart terminal
# Verify installation
poetry --version
```

#### 2. **Wrong Working Directory**

**Error:** `Poetry could not find a pyproject.toml file in ... or its parents`

**Solution:**

```bash
# ❌ Wrong directory
cd src/backend
poetry install  # Error!

# ✅ Correct directory
cd src/backend/easm
poetry install  # Works!

# Always run Poetry commands from src/backend/easm/
```

#### 3. **Dependencies Not Installed**

**Error:** `ModuleNotFoundError: No module named 'django'`

**Solution:**

```bash
cd src/backend/easm

# Install dependencies
poetry install

# Verify installation
poetry run python -c "import django; print(django.VERSION)"

# If still issues, clear cache and reinstall
poetry cache clear . --all
rm poetry.lock
poetry install
```

#### 4. **Import Errors**

**Error:** `ModuleNotFoundError: No module named 'apps.yourapp'`

**Solution:**

```python
# Make sure app name in apps.py includes 'apps.' prefix
class YourAppConfig(AppConfig):
    name = 'apps.yourapp'  # Not just 'yourapp'
```

#### 5. **Migrations Not Found**

**Error:** `No changes detected` when running `makemigrations`

**Solution:**

```bash
# Specify the app name
cd src/backend/easm
poetry run python manage.py makemigrations yourapp

# Make sure app is in INSTALLED_APPS
# Check config/settings.py
```

#### 3. **Permission Denied (403)**

**Error:** API returns 403 Forbidden

**Solution:**

```python
# Check if permission_classes is set correctly
permission_classes = [IsAuthenticated]  # Not AllowAny for protected endpoints

# Make sure you're sending JWT token
# Header: Authorization: Bearer YOUR_TOKEN
```

#### 4. **Authentication Credentials Not Provided (401)**

**Error:** API returns 401 Unauthorized

**Solution:**

```bash
# Get token first
curl -X POST http://localhost:8000/api/token/ \
  -d '{"username": "user", "password": "pass"}'

# Then use it
curl -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  http://localhost:8000/api/yourapp/
```

#### 5. **CORS Errors**

**Error:** Browser shows CORS policy error

**Solution:**

```python
# In config/settings.py
CORS_ALLOWED_ORIGINS = [
    "http://localhost:3000",
    "http://127.0.0.1:3000",
    "http://your-frontend-url.com",  # Add your frontend URL
]

# For development, you can temporarily use:
CORS_ALLOW_ALL_ORIGINS = True  # Only for development!
```

#### 6. **MongoDB Connection Errors**

**Error:** `MongoDB is not available`

**Solution:**

```bash
# Check MongoDB is running
# Docker Compose: docker-compose ps
# Check .env file has correct settings:
MONGODB_HOST=localhost  # or 'mongodb' for Docker
MONGODB_PORT=27017
MONGODB_DB=easm_mongo

# Test connection
poetry run python manage.py shell
>>> from apps.yourapp.db import get_mongodb
>>> db = get_mongodb()
>>> print(db.list_collection_names())
```

#### 7. **Serializer Validation Errors**

**Error:** `This field is required` or validation errors

**Solution:**

```python
# Check your serializer Meta fields
class Meta:
    model = YourModel
    fields = '__all__'  # Or list specific fields
    read_only_fields = ['id', 'created_at', 'updated_at', 'user']  # Don't require these

# Check required fields in model
# Make sure model fields have blank=True, null=True if optional
```

#### 8. **URL Not Found (404)**

**Error:** API endpoint returns 404

**Solution:**

```python
# 1. Check route is registered in apps/api/urls.py
router.register(r'yourapp', YourViewSet, basename='yourapp')

# 2. Check import is correct
from .yourapp.views import YourViewSet

# 3. Verify URL pattern
# Should be: http://localhost:8000/api/yourapp/ (note the /api/ prefix)

# 4. Check router is included in urlpatterns
urlpatterns = [
    path('', include(router.urls)),
]
```

#### 9. **Related Objects Not Showing in API**

**Error:** Foreign key relationships return IDs instead of full objects

**Solution:**

```python
# Use nested serializers
class NoteSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)  # Nested serializer
    category = CategorySerializer(read_only=True)

    class Meta:
        model = Note
        fields = ['id', 'title', 'user', 'category']

# Or use SerializerMethodField for custom representation
class NoteSerializer(serializers.ModelSerializer):
    user_info = serializers.SerializerMethodField()

    def get_user_info(self, obj):
        return {
            'id': obj.user.id,
            'username': obj.user.username,
            'email': obj.user.email
        }

    class Meta:
        model = Note
        fields = ['id', 'title', 'user_info']
```

---

## ✅ Checklist & Quick Reference

### New API Module Checklist

Use this checklist every time you create a new API:

#### Domain App Setup

- [ ] Create app: `poetry run python manage.py startapp appname apps/appname`
- [ ] Configure `apps/appname/apps.py` with correct `name = 'apps.appname'`
- [ ] Add to `INSTALLED_APPS` in `config/settings.py`
- [ ] Create models in `apps/appname/models.py`
- [ ] Run migrations: `makemigrations appname` → `migrate`
- [ ] Configure admin in `apps/appname/admin.py` (optional)

#### API Setup

- [ ] Create API directory: `mkdir -p apps/api/appname`
- [ ] Create `apps/api/appname/__init__.py`
- [ ] Create `apps/api/appname/serializers.py`
- [ ] Create `apps/api/appname/views.py`
- [ ] Import ViewSet in `apps/api/urls.py`
- [ ] Register route in router: `router.register(r'appname', ViewSet)`
- [ ] Add API tag in `config/settings.py` SPECTACULAR_SETTINGS

#### Testing

- [ ] Test in Swagger UI: `http://localhost:8000/api/docs/`
- [ ] Test authentication works
- [ ] Test CRUD operations
- [ ] Write unit tests in `apps/api/appname/tests.py`
- [ ] Run tests: `poetry run python manage.py test`

### Quick Command Reference

```bash
# Django Management
poetry run python manage.py startapp appname apps/appname
poetry run python manage.py makemigrations [appname]
poetry run python manage.py migrate
poetry run python manage.py runserver
poetry run python manage.py shell
poetry run python manage.py createsuperuser

# Testing
poetry run python manage.py test
poetry run python manage.py test apps.api.yourapp
coverage run --source='apps' manage.py test
coverage report

# Database
poetry run python manage.py dbshell
poetry run python manage.py flush  # Clear database (careful!)

# Utilities
poetry run python manage.py check
poetry run python manage.py showmigrations
poetry run python manage.py sqlmigrate appname 0001
```

### File Structure Template

```
apps/
├── yourapp/                    # Domain app (models & logic)
│   ├── __init__.py
│   ├── apps.py                # name = 'apps.yourapp'
│   ├── models.py              # Your models here
│   ├── admin.py               # Admin configuration
│   ├── tests.py               # Domain tests
│   └── migrations/
│       └── __init__.py
│
└── api/
    ├── yourapp/               # API implementation
    │   ├── __init__.py
    │   ├── views.py          # ViewSets here
    │   ├── serializers.py    # Serializers here
    │   └── tests.py          # API tests
    └── urls.py               # Register routes HERE
```

### Code Snippets

#### Basic ModelViewSet Template

```python
from rest_framework import viewsets
from rest_framework.permissions import IsAuthenticated
from drf_spectacular.utils import extend_schema
from apps.yourapp.models import YourModel
from .serializers import YourSerializer

@extend_schema(tags=['YourApp'])
class YourViewSet(viewsets.ModelViewSet):
    """Your API documentation"""
    permission_classes = [IsAuthenticated]
    serializer_class = YourSerializer

    def get_queryset(self):
        return YourModel.objects.filter(user=self.request.user)

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)
```

#### Basic Serializer Template

```python
from rest_framework import serializers
from apps.yourapp.models import YourModel

class YourSerializer(serializers.ModelSerializer):
    class Meta:
        model = YourModel
        fields = ['id', 'field1', 'field2', 'created_at', 'updated_at']
        read_only_fields = ['id', 'created_at', 'updated_at']
```

#### Basic Model Template

```python
from django.db import models
from django.contrib.auth.models import User

class YourModel(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='your_items')
    field1 = models.CharField(max_length=200)
    field2 = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-created_at']
        verbose_name = 'Your Model'
        verbose_name_plural = 'Your Models'

    def __str__(self):
        return self.field1
```

---

## 📖 Additional Resources

### Documentation

- **Django Documentation**: https://docs.djangoproject.com/
- **Django REST Framework**: https://www.django-rest-framework.org/
- **drf-spectacular**: https://drf-spectacular.readthedocs.io/
- **JWT Authentication**: https://django-rest-framework-simplejwt.readthedocs.io/

### Project-Specific Docs

- [ADDING-NEW-DJANGO-APPS.md](./ADDING-NEW-DJANGO-APPS.md) - Detailed Django app guide
- [ARCHITECTURE-OVERVIEW.md](./ARCHITECTURE-OVERVIEW.md) - System architecture
- [API-DOCUMENTATION.md](./API-DOCUMENTATION.md) - Complete API reference
- Main README.md - Project overview

### Getting Help

- Check existing code in `apps/api/todos/` - Complete working example
- Check existing code in `apps/api/scanner/` - MongoDB example
- Review test files for examples
- Ask team members or create GitHub issues

---

## 🎓 Learning Path

### For Complete Beginners

1. **Week 1: Basics**

   - Read this guide completely
   - Study the `todos` app example
   - Follow the "Quick Recipe" section
   - Create a simple "Notes" API

2. **Week 2: Intermediate**

   - Add custom actions to your API
   - Implement filtering and searching
   - Add relationships between models
   - Write unit tests

3. **Week 3: Advanced**

   - Study the `scanner` MongoDB example
   - Create a MongoDB-based API
   - Implement complex permissions
   - Add bulk operations

4. **Week 4: Best Practices**
   - Optimize database queries
   - Implement caching
   - Add comprehensive error handling
   - Write integration tests

### Tips for Success

✅ **DO:**

- Start with simple CRUD operations
- Follow existing patterns in the codebase
- Test your API as you build
- Write clear documentation
- Ask questions when stuck
- Use version control (Git)

❌ **DON'T:**

- Modify core framework files
- Skip migrations
- Hardcode sensitive data
- Ignore authentication
- Copy-paste without understanding
- Deploy untested code

---

## 🚀 Next Steps

Now that you understand how to add APIs, consider:

1. **Add Your Feature**: Use this guide to implement your required API
2. **Review Code**: Get your code reviewed by team members
3. **Write Tests**: Ensure your API works correctly
4. **Document**: Update API documentation if needed
5. **Deploy**: Follow deployment procedures (see README.md)

**Remember:** This guide is a living document. If you find better patterns or encounter issues, please update this guide to help future developers!

---

---

## 📦 Poetry Command Reference

### Project Setup

```bash
# Initial setup (one-time)
cd src/backend/easm
poetry install                    # Install all dependencies
poetry install --without dev      # Install only production dependencies
poetry install --with dev         # Install with dev dependencies (default)
```

### Managing Dependencies

```bash
# Add packages
poetry add django-extensions      # Add production dependency
poetry add --group dev pytest-cov # Add dev dependency
poetry add "django>=5.2,<6.0"    # Add with version constraint

# Remove packages
poetry remove django-extensions

# Update packages
poetry update                     # Update all packages
poetry update django              # Update specific package
poetry lock                       # Update lock file only
```

### Running Commands

```bash
# Option 1: Using poetry shell (recommended for development)
poetry shell                      # Activate virtual environment
python manage.py runserver        # Run commands directly
python manage.py migrate
black .
pytest
exit                             # Exit shell when done

# Option 2: Using poetry run (for single commands)
poetry run python manage.py runserver
poetry run python manage.py migrate
poetry run black .
poetry run pytest
```

### Environment Management

```bash
# Show virtual environment info
poetry env info
poetry env list

# Show installed packages
poetry show                       # List all packages
poetry show --tree               # Show dependency tree
poetry show django               # Show package details

# Check for issues
poetry check                     # Validate pyproject.toml
poetry run python manage.py check  # Django system check
```

### Development Workflow

```bash
# Daily development workflow
cd src/backend/easm

# 1. Update dependencies (if needed)
poetry install

# 2. Activate shell
poetry shell

# 3. Run development server
python manage.py runserver

# 4. In another terminal (also in poetry shell)
python manage.py makemigrations
python manage.py migrate

# 5. Run tests
pytest

# 6. Format code before committing
black .
flake8
```

### Common Django Commands with Poetry

```bash
# All commands assume you're in: src/backend/easm/

# Server
poetry run python manage.py runserver
poetry run python manage.py runserver 0.0.0.0:8000

# Migrations
poetry run python manage.py makemigrations
poetry run python manage.py makemigrations appname
poetry run python manage.py migrate
poetry run python manage.py showmigrations
poetry run python manage.py sqlmigrate appname 0001

# Database
poetry run python manage.py dbshell
poetry run python manage.py flush
poetry run python manage.py dumpdata > data.json
poetry run python manage.py loaddata data.json

# Users
poetry run python manage.py createsuperuser
poetry run python manage.py changepassword username

# Shell
poetry run python manage.py shell
poetry run python manage.py shell_plus  # If django-extensions installed

# Testing
poetry run python manage.py test
poetry run python manage.py test apps.api.yourapp
poetry run pytest
poetry run pytest -v
poetry run pytest --cov=apps

# Code Quality
poetry run black .
poetry run black apps/
poetry run flake8
poetry run flake8 apps/

# Static Files
poetry run python manage.py collectstatic
poetry run python manage.py findstatic filename

# Apps
poetry run python manage.py startapp appname apps/appname
```

### Troubleshooting Poetry

```bash
# Clear cache
poetry cache clear . --all

# Reinstall dependencies
rm poetry.lock
poetry install

# Check for dependency conflicts
poetry lock --check

# Export requirements.txt (if needed)
poetry export -f requirements.txt --output requirements.txt
poetry export --without-hashes -f requirements.txt --output requirements.txt

# Update Poetry itself
poetry self update
poetry --version
```

### Poetry Configuration

```bash
# View configuration
poetry config --list

# Useful settings
poetry config virtualenvs.in-project true   # Create .venv in project
poetry config virtualenvs.create true       # Auto-create virtualenvs

# pyproject.toml location
# All Poetry commands read from: src/backend/easm/pyproject.toml
```

### Quick Tips

💡 **Always run from correct directory**: `cd src/backend/easm`
💡 **Use `poetry shell`** for active development
💡 **Use `poetry run`** for CI/CD or quick commands
💡 **Commit `poetry.lock`** to version control
💡 **Don't edit `poetry.lock`** manually
💡 **Use `poetry add`** instead of editing `pyproject.toml` manually

---

**Last Updated**: November 2025
**Version**: 2.0.0 (Poetry Edition)
**Maintainers**: EASM Platform Development Team

---

**Good luck building amazing APIs! 🎉**
