"""
REST API URL Configuration - Centralized API routing
"""
from django.urls import path, include
from rest_framework.routers import DefaultRouter

# Import routers from other apps
from .views import api_root, register, TodoViewSet

# Central API router
router = DefaultRouter()
router.register(r'todos', TodoViewSet, basename='todo')

app_name = 'api'

urlpatterns = [
    # API root endpoint
    path('', api_root, name='api-root'),

    # User registration
    path('register/', register, name='user-register'),

    # Router URLs
    path('', include(router.urls)),
]
