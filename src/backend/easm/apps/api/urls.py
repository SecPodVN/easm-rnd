"""
REST API URL Configuration - Centralized API routing (controls all apps)
"""
from django.urls import path, include
from rest_framework.routers import DefaultRouter

# Import auth views
from .views import api_root

# Import todos views
from .todos.views import TodoViewSet

# Central API router
router = DefaultRouter()
router.register(r'todos', TodoViewSet, basename='todo')

app_name = 'api'

urlpatterns = [
    # API root endpoint
    path('', api_root, name='api-root'),

    # Todos router URLs
    path('', include(router.urls)),
]
