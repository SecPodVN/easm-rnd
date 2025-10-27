"""
REST API URL Configuration - Centralized API routing
"""
from django.urls import path, include
from .views import api_root

app_name = 'api'

urlpatterns = [
    # API root endpoint
    path('', api_root, name='api-root'),

    # Todos API endpoints
    path('todos/', include('apps.api.todo.urls')),
]
