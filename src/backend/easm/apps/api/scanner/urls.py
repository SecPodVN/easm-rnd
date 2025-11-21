"""
Scanner API URL Configuration - Scanner sub-routes
"""
from django.urls import path, include
from rest_framework.routers import DefaultRouter

from .views import (
    scanner_health,
    ResourceViewSet,
    RuleViewSet,
    FindingViewSet,
    ScanViewSet
)

# Scanner router for sub-routes
router = DefaultRouter()
router.register(r'resources', ResourceViewSet, basename='scanner-resource')
router.register(r'rules', RuleViewSet, basename='scanner-rule')
router.register(r'findings', FindingViewSet, basename='scanner-finding')
router.register(r'scan', ScanViewSet, basename='scanner-scan')

app_name = 'scanner'

urlpatterns = [
    # Health check endpoint
    path('healthStatus', scanner_health, name='health'),

    # Router URLs
    path('', include(router.urls)),
]
