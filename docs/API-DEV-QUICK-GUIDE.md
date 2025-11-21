# API Development - Quick Guide

**Add new REST APIs to EASM Platform** 🚀

---

## ⚡ TL;DR - 3 Steps to Add API

```bash
# 1. Create model
cd src/backend/easm
poetry run python manage.py startapp myapp apps/myapp

# 2. Create API endpoints
mkdir apps/api/myapp
# Add views.py and serializers.py

# 3. Register routes
# Edit apps/api/urls.py
```

---

## 📁 Our Structure

```
src/backend/easm/
├── apps/
│   ├── myapp/              # 📦 Domain (models)
│   │   └── models.py
│   └── api/
│       └── myapp/          # 🎯 API (views, serializers)
│           ├── views.py
│           └── serializers.py
└── config/
    └── urls.py             # All routes go through apps/api/urls.py
```

**Rule**: Models in `apps/myapp/`, APIs in `apps/api/myapp/`

---

## 🎯 Example: Add "Notes" API

### Step 1: Create App & Model

```bash
cd src/backend/easm
poetry run python manage.py startapp notes apps/notes
```

**Edit `apps/notes/models.py`:**

```python
from django.db import models
from django.contrib.auth.models import User

class Note(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    title = models.CharField(max_length=200)
    content = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-created_at']
```

**Register in `config/settings.py`:**

```python
INSTALLED_APPS = [
    # ...
    'apps.notes.apps.NotesConfig',
]
```

**Create migrations:**

```bash
poetry run python manage.py makemigrations
poetry run python manage.py migrate
```

---

### Step 2: Create API

**Create directory:**

```bash
mkdir apps/api/notes
```

**Create `apps/api/notes/serializers.py`:**

```python
from rest_framework import serializers
from apps.notes.models import Note

class NoteSerializer(serializers.ModelSerializer):
    class Meta:
        model = Note
        fields = ['id', 'title', 'content', 'created_at']
        read_only_fields = ['created_at']
```

**Create `apps/api/notes/views.py`:**

```python
from rest_framework import viewsets
from rest_framework.permissions import IsAuthenticated
from drf_spectacular.utils import extend_schema
from apps.notes.models import Note
from .serializers import NoteSerializer

@extend_schema(tags=['Notes'])
class NoteViewSet(viewsets.ModelViewSet):
    queryset = Note.objects.all()
    serializer_class = NoteSerializer
    permission_classes = [IsAuthenticated]

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)

    def get_queryset(self):
        return self.queryset.filter(user=self.request.user)
```

---

### Step 3: Register Routes

**Edit `apps/api/urls.py`:**

```python
from .notes.views import NoteViewSet  # Add import

# Add to router
router.register(r'notes', NoteViewSet)
```

---

### Step 4: Test

```bash
# Start server
poetry run python manage.py runserver

# Visit API docs
http://localhost:8000/api/docs/

# Test endpoint
curl -H "Authorization: Bearer YOUR_TOKEN" \
     http://localhost:8000/api/notes/
```

---

## 🎨 Common Patterns

### Filter by User

```python
def get_queryset(self):
    return self.queryset.filter(user=self.request.user)
```

### Custom Action

```python
@action(detail=True, methods=['post'])
def publish(self, request, pk=None):
    note = self.get_object()
    note.published = True
    note.save()
    return Response({'status': 'published'})
```

### Nested Serializer

```python
class NoteDetailSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)

    class Meta:
        model = Note
        fields = ['id', 'title', 'content', 'user']
```

### Search & Filter

```python
from rest_framework import filters
from django_filters.rest_framework import DjangoFilterBackend

class NoteViewSet(viewsets.ModelViewSet):
    filter_backends = [DjangoFilterBackend, filters.SearchFilter]
    filterset_fields = ['title']
    search_fields = ['title', 'content']
```

---

## 🔑 Essential Commands

```bash
# Create app
poetry run python manage.py startapp appname apps/appname

# Migrations
poetry run python manage.py makemigrations
poetry run python manage.py migrate

# Shell
poetry run python manage.py shell

# Tests
poetry run pytest
```

---

## 🐛 Quick Fixes

**"No module named 'apps.myapp'"**

```python
# In apps/myapp/apps.py
name = 'apps.myapp'  # Must include 'apps.'
```

**"Permission denied (403)"**

```python
permission_classes = [IsAuthenticated]  # Check this
```

**"Migration not found"**

```bash
poetry run python manage.py makemigrations myapp
```

---

## 📚 More Details

- **Full Guide**: See `confluence/BACKEND-API-DEVELOPMENT-GUIDE.md`
- **When to create apps**: See [PROJECT-APP-CREATION-GUIDE.md](PROJECT-APP-CREATION-GUIDE.md)
- **Architecture**: See [ARCHITECTURE-OVERVIEW.md](ARCHITECTURE-OVERVIEW.md)

---

## 🎯 Checklist

- [ ] Model created in `apps/myapp/models.py`
- [ ] App registered in `INSTALLED_APPS`
- [ ] Migrations run
- [ ] Serializer created in `apps/api/myapp/serializers.py`
- [ ] ViewSet created in `apps/api/myapp/views.py`
- [ ] Route registered in `apps/api/urls.py`
- [ ] Tested in Swagger UI

---

**Last Updated**: November 2025
**Quick reference only - see confluence/ for complete guide**
