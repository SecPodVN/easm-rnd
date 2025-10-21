"""
REST API URL Configuration - Centralized API routing
"""
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import TodoViewSet, api_root

# Create router and register viewsets
router = DefaultRouter()
router.register(r'todos', TodoViewSet, basename='todo')

app_name = 'api'

urlpatterns = [
    # API root endpoint
    path('', api_root, name='api-root'),
    
    # Router URLs
    path('', include(router.urls)),
]
