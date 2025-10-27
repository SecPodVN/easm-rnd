"""
Todo API URL Configuration
"""
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import TodoViewSet

# Create router and register viewsets
router = DefaultRouter()
router.register(r'', TodoViewSet, basename='todo')

app_name = 'todo'

urlpatterns = [
    path('', include(router.urls)),
]
