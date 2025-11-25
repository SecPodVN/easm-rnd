"""
URL configuration for EASM project.
Main routing - uses ViewSets with DefaultRouter (DRF standard).
"""
from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static
from rest_framework.routers import DefaultRouter
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView
from drf_spectacular.views import (
    SpectacularAPIView,
    SpectacularRedocView,
    SpectacularSwaggerView,
)

# Import ViewSets from domain apps
from easm.auth.views import (
    AuthenticationViewSet,
    UserProfileViewSet,
    UserViewSet
)
from easm.example.views import TodoViewSet

# Create a simple API root and health check
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework.reverse import reverse


@api_view(['GET'])
def api_root(request, format=None):
    """API root endpoint"""
    return Response({
        'auth': reverse('auth-list', request=request, format=format),
        'users': reverse('user-list', request=request, format=format),
        'profiles': reverse('userprofile-list', request=request, format=format),
        'todos': reverse('todo-list', request=request, format=format),
    })


@api_view(['GET'])
@permission_classes([AllowAny])
def health_check(request):
    """Health check endpoint"""
    return Response({'status': 'healthy'})


# Create router and register all viewsets
router = DefaultRouter()

# Authentication endpoints
router.register(r'auth', AuthenticationViewSet, basename='auth')
router.register(r'profile', UserProfileViewSet, basename='profile')
router.register(r'account', UserViewSet, basename='account')

# Domain endpoints
router.register(r'todos', TodoViewSet, basename='todo')

# Future domain ViewSets will be added here:
# router.register(r'assets', AssetViewSet, basename='asset')
# router.register(r'vulnerabilities', VulnerabilityViewSet, basename='vulnerability')
# router.register(r'risks', RiskAssessmentViewSet, basename='risk')

urlpatterns = [
    # Admin
    path('admin/', admin.site.urls),

    # API Root and Health
    path('api/', api_root, name='api-root'),
    path('api/health/', health_check, name='api-health'),

    # JWT Token endpoints (separate from router)
    path('api/token/', TokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('api/token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),

    # All ViewSet routes under /api/
    path('api/', include(router.urls)),

    # API Documentation
    path('api/schema/', SpectacularAPIView.as_view(), name='schema'),
    path('api/docs/', SpectacularSwaggerView.as_view(url_name='schema'), name='swagger-ui'),
    path('api/redoc/', SpectacularRedocView.as_view(url_name='schema'), name='redoc'),
]

# Serve static/media files in development
if settings.DEBUG:
    urlpatterns += static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
