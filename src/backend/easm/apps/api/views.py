"""
Common API views and utilities.
"""
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework import status
from drf_spectacular.utils import extend_schema


@extend_schema(
    summary="API Root",
    description="Get information about available API endpoints",
    tags=['API Info']
)
@api_view(['GET'])
@permission_classes([AllowAny])
def api_root(request):
    """
    API root endpoint - provides information about available endpoints.
    """
    return Response({
        'version': '1.0.0',
        'endpoints': {
            'authentication': {
                'token': '/api/token/',
                'token_refresh': '/api/token/refresh/',
                'register': '/api/auth/register/',
                'login': '/api/auth/login/',
                'me': '/api/auth/me/',
                'change_password': '/api/auth/change-password/',
                'password_reset': '/api/auth/password-reset/',
                'password_reset_confirm': '/api/auth/password-reset/confirm/',
            },
            'profile': {
                'detail': '/api/profile/{id}/',
            },
            'account': {
                'detail': '/api/account/{id}/',
            },
            'example': {
                'list': '/api/example/',
                'detail': '/api/example/{id}/',
                'stats': '/api/example/stats/',
                'overdue': '/api/example/overdue/',
                'complete': '/api/example/{id}/complete/',
                'bulk_update_priority': '/api/example/bulk_update_priority/',
            },
            'documentation': {
                'swagger': '/api/docs/',
                'redoc': '/api/redoc/',
                'schema': '/api/schema/',
            },
        },
        'description': 'External Attack Surface Management API - All endpoints use ViewSet-based routing',
    })


@extend_schema(
    summary="Health Check",
    description="Check API health status",
    tags=['API Info']
)
@api_view(['GET'])
@permission_classes([AllowAny])
def health_check(request):
    """
    Health check endpoint for monitoring.
    """
    return Response({
        'status': 'healthy',
        'service': 'EASM API',
    })
