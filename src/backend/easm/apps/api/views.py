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
                'profile': '/api/auth/profile/',
            },
            'example': {
                'list': '/api/example/',
                'detail': '/api/example/{id}/',
            },
            'documentation': {
                'swagger': '/api/docs/',
                'redoc': '/api/redoc/',
                'schema': '/api/schema/',
            },
        },
        'description': 'External Attack Surface Management API',
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
