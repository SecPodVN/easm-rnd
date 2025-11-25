"""
Central URL routing for the API presentation layer.
All domain-specific ViewSets are registered here using DRF routers.
"""
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView
from .views import api_root, health_check

# Import ViewSets from domain API layers
from .authentication.views import AuthViewSet, UserProfileViewSet, UserViewSet
from .example.views import TodoViewSet

# Create the main router
router = DefaultRouter()

# Register authentication ViewSets
router.register(r'auth', AuthViewSet, basename='auth')
router.register(r'profile', UserProfileViewSet, basename='profile')
router.register(r'account', UserViewSet, basename='account')

# Register domain ViewSets
router.register(r'example', TodoViewSet, basename='todo')

# Future domain ViewSets will be registered here:
# router.register(r'asset-discovery', AssetDiscoveryViewSet, basename='asset-discovery')
# router.register(r'vulnerability-scanning', VulnerabilityScanningViewSet, basename='vulnerability-scanning')
# router.register(r'risk-assessment', RiskAssessmentViewSet, basename='risk-assessment')
# router.register(r'reporting', ReportingViewSet, basename='reporting')

urlpatterns = [
    # API root and health
    path('', api_root, name='api-root'),
    path('health/', health_check, name='api-health'),

    # JWT Token endpoints (not using router)
    path('token/', TokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),

    # All registered ViewSets
    path('', include(router.urls)),
]
