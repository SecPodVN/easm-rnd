"""
REST API Views - Centralized REST API business logic
"""
from rest_framework import viewsets, filters, status
from rest_framework.decorators import action, api_view, permission_classes
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated, AllowAny
from django_filters.rest_framework import DjangoFilterBackend
from django.utils import timezone
from django.contrib.auth.models import User
from drf_spectacular.utils import extend_schema, OpenApiExample
from apps.todos.models import Todo
from .serializers import TodoSerializer, TodoCreateUpdateSerializer, UserRegistrationSerializer, UserSerializer


@extend_schema(tags=['Todos'])
class TodoViewSet(viewsets.ModelViewSet):
    """
    ViewSet for Todo CRUD operations

    Provides:
    - list: GET /api/todos/
    - create: POST /api/todos/
    - retrieve: GET /api/todos/{id}/
    - update: PUT /api/todos/{id}/
    - partial_update: PATCH /api/todos/{id}/
    - destroy: DELETE /api/todos/{id}/
    - complete: POST /api/todos/{id}/complete/
    - my_todos: GET /api/todos/my_todos/
    - statistics: GET /api/todos/statistics/
    """
    permission_classes = [IsAuthenticated]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['status', 'priority']
    search_fields = ['title', 'description']
    ordering_fields = ['created_at', 'updated_at', 'due_date', 'priority']
    ordering = ['-created_at']

    def get_queryset(self):
        """
        Return todos for the current user
        """
        # Handle schema generation
        if getattr(self, 'swagger_fake_view', False):
            return Todo.objects.none()
        return Todo.objects.filter(user=self.request.user)

    def get_serializer_class(self):
        """
        Return appropriate serializer based on action
        """
        if self.action in ['create', 'update', 'partial_update']:
            return TodoCreateUpdateSerializer
        return TodoSerializer

    def perform_create(self, serializer):
        """
        Set the user when creating a todo
        """
        serializer.save(user=self.request.user)

    @action(detail=True, methods=['post'])
    def complete(self, request, pk=None):
        """
        Mark a todo as completed
        """
        todo = self.get_object()
        todo.status = 'completed'
        todo.completed_at = timezone.now()
        todo.save()
        serializer = self.get_serializer(todo)
        return Response(serializer.data)

    @extend_schema(
        summary="Get my todos",
        description="Get all todos for the authenticated user with filtering and pagination.",
        responses={200: TodoSerializer(many=True)}
    )
    @action(detail=False, methods=['get'])
    def my_todos(self, request):
        """
        Get all todos for the current user
        """
        queryset = self.filter_queryset(self.get_queryset())
        page = self.paginate_queryset(queryset)
        if page is not None:
            serializer = self.get_serializer(page, many=True)
            return self.get_paginated_response(serializer.data)

        serializer = self.get_serializer(queryset, many=True)
        return Response(serializer.data)

    @extend_schema(
        summary="Get todo statistics",
        description="Get statistics about the user's todos including completion rates.",
        responses={200: {
            'type': 'object',
            'properties': {
                'total': {'type': 'integer'},
                'pending': {'type': 'integer'},
                'in_progress': {'type': 'integer'},
                'completed': {'type': 'integer'},
                'completion_rate': {'type': 'number', 'format': 'float'}
            }
        }}
    )
    @action(detail=False, methods=['get'])
    def statistics(self, request):
        """
        Get statistics about user's todos
        """
        queryset = self.get_queryset()
        total = queryset.count()
        pending = queryset.filter(status='pending').count()
        in_progress = queryset.filter(status='in_progress').count()
        completed = queryset.filter(status='completed').count()

        return Response({
            'total': total,
            'pending': pending,
            'in_progress': in_progress,
            'completed': completed,
            'completion_rate': (completed / total * 100) if total > 0 else 0
        })


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
                'register': '/api/register/',
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
            'docs': {
                'swagger': '/api/docs/',
                'redoc': '/api/redoc/',
                'schema': '/api/schema/',
            }
        }
    })
