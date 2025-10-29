"""
REST API URL Configuration - Centralized API routing (Todos and Scanner)
"""
from django.urls import path, include
from rest_framework.routers import DefaultRouter

# Import todos and auth views
from .views import api_root, TodoViewSet

# Import scanner views
from .scanner.views import (
    scanner_health, ResourceViewSet, RuleViewSet,
    FindingViewSet, ScannerViewSet
)

# Central API router
router = DefaultRouter()
router.register(r'todos', TodoViewSet, basename='todo')
router.register(r'scanner/resources', ResourceViewSet, basename='scanner-resource')
router.register(r'scanner/rules', RuleViewSet, basename='scanner-rule')
router.register(r'scanner/findings', FindingViewSet, basename='scanner-finding')
router.register(r'scanner/scan', ScannerViewSet, basename='scanner-scan')

app_name = 'api'

urlpatterns = [
    # API root endpoint
    path('', api_root, name='api-root'),

    # Scanner health check
    path('scanner/healthStatus', scanner_health, name='scanner-health'),

    # Router URLs
    path('', include(router.urls)),
]
