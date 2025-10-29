"""
REST API Views - Authentication and API Root
"""
from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from rest_framework.permissions import AllowAny
from drf_spectacular.utils import extend_schema, OpenApiExample

from .serializers import (
    UserSerializer, UserRegistrationSerializer
)


@extend_schema(
    summary="Register a new user",
    description="Create a new user account with username, password, and optional profile information.",
    request=UserRegistrationSerializer,
    responses={
        201: {
            'type': 'object',
            'properties': {
                'message': {'type': 'string', 'example': 'User registered successfully'},
                'user': {
                    'type': 'object',
                    'properties': {
                        'id': {'type': 'integer'},
                        'username': {'type': 'string'},
                        'email': {'type': 'string'},
                        'first_name': {'type': 'string'},
                        'last_name': {'type': 'string'}
                    }
                }
            }
        },
        400: {
            'type': 'object',
            'properties': {
                'username': {'type': 'array', 'items': {'type': 'string'}},
                'password': {'type': 'array', 'items': {'type': 'string'}},
                'email': {'type': 'array', 'items': {'type': 'string'}}
            }
        }
    },
    examples=[
        OpenApiExample(
            'Registration Example',
            value={
                'username': 'newuser',
                'email': 'newuser@example.com',
                'password': 'securepassword123',
                'password_confirm': 'securepassword123',
                'first_name': 'John',
                'last_name': 'Doe'
            },
            request_only=True
        )
    ],
    tags=['Authentication']
)
@api_view(['POST'])
@permission_classes([AllowAny])
def register(request):
    """
    Register a new user
    """
    serializer = UserRegistrationSerializer(data=request.data)
    if serializer.is_valid():
        user = serializer.save()
        user_data = UserSerializer(user).data
        return Response({
            'message': 'User registered successfully',
            'user': user_data
        }, status=status.HTTP_201_CREATED)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@extend_schema(
    summary="API Root",
    description="Provides information about available API endpoints.",
    responses={200: {
        'type': 'object',
        'properties': {
            'message': {'type': 'string'},
            'version': {'type': 'string'},
            'endpoints': {'type': 'object'}
        }
    }},
    tags=['API Info']
)
@api_view(['GET'])
@permission_classes([AllowAny])
def api_root(request):
    """
    API Root endpoint - provides information about available endpoints
    """
    return Response({
        'message': 'EASM REST API',
        'version': '1.0.0',
        'endpoints': {
            'auth': {
                'register': '/api/token/register/',
                'token_obtain': '/api/token/',
                'token_refresh': '/api/token/refresh/',
            },
            'todos': {
                'list': '/api/todos/',
                'create': '/api/todos/',
                'retrieve': '/api/todos/{id}/',
                'update': '/api/todos/{id}/',
                'delete': '/api/todos/{id}/',
                'complete': '/api/todos/{id}/complete/',
                'my_todos': '/api/todos/my_todos/',
                'statistics': '/api/todos/statistics/',
            },
            'scanner': {
                'resources': '/api/scanner/resources/',
                'rules': '/api/scanner/rules/',
                'findings': '/api/scanner/findings/',
                'scan': '/api/scanner/scan/',
            },
            'docs': {
                'swagger': '/api/docs/',
                'redoc': '/api/redoc/',
                'schema': '/api/schema/',
            }
        }
    })
