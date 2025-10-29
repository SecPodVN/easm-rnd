"""
REST API Views - Centralized REST API business logic (Todos and Scanner)
"""
from rest_framework import viewsets, filters, status
from rest_framework.decorators import action, api_view, permission_classes
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated, AllowAny
from django_filters.rest_framework import DjangoFilterBackend
from django.utils import timezone
from drf_spectacular.utils import extend_schema, OpenApiResponse, OpenApiExample

from apps.todos.models import Todo
from apps.scanner.models import Resource, Rule, Finding
from apps.scanner.engine import ScanEngine

from .serializers import (
    UserSerializer, UserRegistrationSerializer,
    TodoSerializer, TodoCreateUpdateSerializer,
    ResourceSerializer, ResourceUploadSerializer, ResourceListSerializer,
    RuleSerializer, RuleUploadSerializer, FindingSerializer,
    DeleteSerializer, SeverityStatusSerializer,
    ResourceTypeIssueSerializer, RegionIssueSerializer
)


# ============================================================================
# TODO VIEWSETS
# ============================================================================


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

    @extend_schema(
        summary="Mark todo as completed",
        description="Mark a specific todo as completed and set completion timestamp.",
        responses={200: TodoSerializer}
    )
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


# ============================================================================
# SCANNER VIEWSETS
# ============================================================================

@extend_schema(
    tags=['Scanner'],
    summary='Scanner health check',
    description='Returns health status of the scanner service.',
    responses={200: OpenApiResponse(description='Scanner service is healthy')}
)
@api_view(['GET'])
@permission_classes([AllowAny])
def scanner_health(request):
    """Health check endpoint for scanner service."""
    return Response({
        'status': 'healthy',
        'service': 'scanner',
        'message': 'Scanner service is running'
    })


@extend_schema(tags=['Scanner'])
class ResourceViewSet(viewsets.ViewSet):
    """
    ViewSet for Resource CRUD operations with MongoDB.

    Provides:
    - upload: POST /api/scanner/resources/upload/
    - list: POST /api/scanner/resources/list/
    - delete: POST /api/scanner/resources/delete/
    """
    permission_classes = [AllowAny]

    @extend_schema(
        summary='Upload resources in bulk',
        description='Bulk inserts an array of resource objects into the MongoDB resources collection.',
        request=ResourceUploadSerializer,
        responses={
            201: OpenApiResponse(description='Resources uploaded successfully'),
            400: OpenApiResponse(description='Invalid request data')
        }
    )
    @action(detail=False, methods=['post'])
    def upload(self, request):
        """Bulk upload resources."""
        serializer = ResourceUploadSerializer(data=request.data)
        if serializer.is_valid():
            resources = serializer.validated_data['resources']
            count = Resource.bulk_create(resources)
            return Response({
                'message': 'Resources uploaded successfully',
                'count': count
            }, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    @extend_schema(
        summary='List resources with filtering and pagination',
        description='Returns a paginated list of resources matching the filter, with search and sort capabilities.',
        request=ResourceListSerializer,
        responses={
            200: OpenApiResponse(description='Resources retrieved successfully'),
            400: OpenApiResponse(description='Invalid request data')
        }
    )
    @action(detail=False, methods=['post'], url_path='list')
    def list_resources(self, request):
        """List resources with filtering, pagination, search, and sorting."""
        serializer = ResourceListSerializer(data=request.data)
        if serializer.is_valid():
            filter_dict = serializer.validated_data.get('filter', {})
            page_number = serializer.validated_data.get('page_number', 1)
            page_size = serializer.validated_data.get('page_size', 10)
            sort_by = serializer.validated_data.get('sort_by', 'name')
            sort_order = serializer.validated_data.get('sort_order', 'asc')
            search_str = serializer.validated_data.get('search_str', None)

            skip = (page_number - 1) * page_size

            result = Resource.find_all(
                filter_dict=filter_dict,
                skip=skip,
                limit=page_size,
                sort_by=sort_by,
                sort_order=sort_order,
                search_str=search_str
            )

            return Response(result, status=status.HTTP_200_OK)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    @extend_schema(
        summary='Delete resources by filter',
        description='Deletes resources matching the specified MongoDB filter.',
        request=DeleteSerializer,
        responses={
            200: OpenApiResponse(description='Resources deleted successfully'),
            400: OpenApiResponse(description='Invalid request data')
        }
    )
    @action(detail=False, methods=['post'])
    def delete(self, request):
        """Delete resources matching filter."""
        serializer = DeleteSerializer(data=request.data)
        if serializer.is_valid():
            filter_dict = serializer.validated_data['filter']
            count = Resource.bulk_delete(filter_dict)
            return Response({
                'message': 'Resources deleted successfully',
                'count': count
            }, status=status.HTTP_200_OK)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@extend_schema(tags=['Scanner'])
class RuleViewSet(viewsets.ViewSet):
    """
    ViewSet for Rule CRUD operations with MongoDB.

    Provides:
    - upload: POST /api/scanner/rules/upload/
    - delete: POST /api/scanner/rules/delete/
    """
    permission_classes = [AllowAny]

    @extend_schema(
        summary='Upload rules in bulk',
        description='Bulk inserts an array of rule objects into the MongoDB rules collection.',
        request=RuleUploadSerializer,
        responses={
            201: OpenApiResponse(description='Rules uploaded successfully'),
            400: OpenApiResponse(description='Invalid request data')
        }
    )
    @action(detail=False, methods=['post'])
    def upload(self, request):
        """Bulk upload rules."""
        serializer = RuleUploadSerializer(data=request.data)
        if serializer.is_valid():
            rules = serializer.validated_data['rules']
            count = Rule.bulk_create(rules)
            return Response({
                'message': 'Rules uploaded successfully',
                'count': count
            }, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    @extend_schema(
        summary='Delete rules by filter',
        description='Deletes rules matching the specified MongoDB filter.',
        request=DeleteSerializer,
        responses={
            200: OpenApiResponse(description='Rules deleted successfully'),
            400: OpenApiResponse(description='Invalid request data')
        }
    )
    @action(detail=False, methods=['post'])
    def delete(self, request):
        """Delete rules matching filter."""
        serializer = DeleteSerializer(data=request.data)
        if serializer.is_valid():
            filter_dict = serializer.validated_data['filter']
            count = Rule.bulk_delete(filter_dict)
            return Response({
                'message': 'Rules deleted successfully',
                'count': count
            }, status=status.HTTP_200_OK)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@extend_schema(tags=['Scanner'])
class FindingViewSet(viewsets.ViewSet):
    """
    ViewSet for Finding operations and analytics with MongoDB.

    Provides:
    - list: GET /api/scanner/findings/
    - severity_status: GET /api/scanner/findings/severity_status/
    - by_resource_type: GET /api/scanner/findings/by_resource_type/
    - by_region: GET /api/scanner/findings/by_region/
    """
    permission_classes = [AllowAny]

    @extend_schema(
        summary='List all findings',
        description='Returns all findings from the findings collection. Each finding represents a detected issue from resource scanning.',
        responses={
            200: OpenApiResponse(
                response=FindingSerializer(many=True),
                description='Findings retrieved successfully'
            )
        }
    )
    def list(self, request):
        """List all findings."""
        findings = Finding.find_all()
        return Response(findings, status=status.HTTP_200_OK)

    @extend_schema(
        summary='Get severity status summary',
        description='Aggregates findings by severity level (CRITICAL, HIGH, MEDIUM, LOW, INFO).',
        responses={
            200: OpenApiResponse(
                response=SeverityStatusSerializer,
                description='Severity summary retrieved successfully'
            )
        }
    )
    @action(detail=False, methods=['get'])
    def severity_status(self, request):
        """Get findings count by severity."""
        severity_counts = Finding.get_severity_summary()
        return Response(severity_counts, status=status.HTTP_200_OK)

    @extend_schema(
        summary='Get issues by resource type',
        description='Aggregates findings by resource type.',
        responses={
            200: OpenApiResponse(
                response=ResourceTypeIssueSerializer(many=True),
                description='Resource type issues retrieved successfully'
            )
        }
    )
    @action(detail=False, methods=['get'])
    def by_resource_type(self, request):
        """Get findings grouped by resource type."""
        results = Finding.get_by_resource_type()
        return Response(results, status=status.HTTP_200_OK)

    @extend_schema(
        summary='Get issues by region',
        description='Joins findings with resources to get region information and aggregates findings by region.',
        responses={
            200: OpenApiResponse(
                response=RegionIssueSerializer(many=True),
                description='Region issues retrieved successfully'
            )
        }
    )
    @action(detail=False, methods=['get'])
    def by_region(self, request):
        """Get findings grouped by region."""
        results = Finding.get_by_region()
        return Response(results, status=status.HTTP_200_OK)


@extend_schema(tags=['Scanner'])
class ScannerViewSet(viewsets.ViewSet):
    """
    ViewSet for scanning operations.

    Provides:
    - list: GET /api/scanner/scan/
    """
    permission_classes = [AllowAny]

    @extend_schema(
        summary='Scan all resources against rules',
        description='Fetches all resources and rules, evaluates each resource against all rules using the logic engine, and creates findings for any matches.',
        responses={
            200: OpenApiResponse(description='Scan completed successfully')
        }
    )
    def list(self, request):
        """Scan all resources against all rules."""
        result = ScanEngine.scan_all_resources()
        return Response({
            'message': 'Scan completed successfully',
            'results': result
        }, status=status.HTTP_200_OK)
