"""
Central URL routing for the API presentation layer.
All domain-specific API routes are included here.
"""
from django.urls import path, include
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView
from .views import api_root, health_check

urlpatterns = [
    # API root and health
    path('', api_root, name='api-root'),
    path('health/', health_check, name='api-health'),

    # Authentication
    path('token/', TokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('auth/', include('easm.apps.api.authentication.urls')),

    # Domain APIs
    path('example/', include('easm.apps.api.example.urls')),

    # Future domain APIs will be added here:
    # path('asset-discovery/', include('easm.apps.api.asset_discovery.urls')),
    # path('vulnerability-scanning/', include('easm.apps.api.vulnerability_scanning.urls')),
    # path('risk-assessment/', include('easm.apps.api.risk_assessment.urls')),
    # path('reporting/', include('easm.apps.api.reporting.urls')),
]
