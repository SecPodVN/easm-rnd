"""URL configuration for scanner app."""
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from . import views

app_name = 'scanner'

# Create a router for ViewSets
router = DefaultRouter()
router.register(r'resources', views.ResourceViewSet, basename='resource')
router.register(r'rules', views.RuleViewSet, basename='rule')
router.register(r'findings', views.FindingViewSet, basename='finding')
router.register(r'scan', views.ScannerViewSet, basename='scan')

urlpatterns = [
    # Health check (standalone endpoint)
    path('healthStatus', views.health_check, name='health-check'),

    # Include router URLs
    path('', include(router.urls)),
]
