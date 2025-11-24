"""
URL configuration for EASM project.
"""
from django.contrib import admin
from django.urls import path, include
from rest_framework_simplejwt.views import (
    TokenObtainPairView,
    TokenRefreshView,
)
from drf_spectacular.views import (
    SpectacularAPIView,
    SpectacularRedocView,
    SpectacularSwaggerView,
)
from drf_spectacular.utils import extend_schema

from .health import health_check, readiness_check, liveness_check
from easm.apps.authentication.views import register
from django.conf import settings
from django.conf.urls.static import static


# Custom JWT views with proper tags for documentation
@extend_schema(tags=['Authentication'])
class CustomTokenObtainPairView(TokenObtainPairView):
    pass


@extend_schema(tags=['Authentication'])
class CustomTokenRefreshView(TokenRefreshView):
    pass

urlpatterns = [
    path('admin/', admin.site.urls),

    # Health checks
    path('health/', health_check, name='health'),
    path('health/ready/', readiness_check, name='readiness'),
    path('health/live/', liveness_check, name='liveness'),

    # JWT Authentication
    path('api/token/', CustomTokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('api/token/refresh/', CustomTokenRefreshView.as_view(), name='token_refresh'),
    path('api/token/register/', register, name='token_register'),

    # API endpoints - Centralized REST API
    path('api/todos/', include('easm.apps.todos.api.urls')),

    # API Documentation
    path('api/schema/', SpectacularAPIView.as_view(), name='schema'),
    path('api/docs/', SpectacularSwaggerView.as_view(url_name='schema'), name='swagger-ui'),
    path('api/redoc/', SpectacularRedocView.as_view(url_name='schema'), name='redoc'),
]

# Serve static files in development (including Docker dev)
if settings.DEBUG:
    urlpatterns += static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)
