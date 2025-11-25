"""
Views for the Example domain API.
Presentation layer - handles HTTP requests/responses, delegates to service layer.
"""
from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django_filters.rest_framework import DjangoFilterBackend
from rest_framework.filters import SearchFilter, OrderingFilter
from drf_spectacular.utils import extend_schema, extend_schema_view, OpenApiParameter

from easm.apps.example.models import Todo
from easm.apps.example.services import TodoService
from .serializers import TodoSerializer, TodoCreateUpdateSerializer, TodoStatsSerializer
from .filters import TodoFilter


@extend_schema_view(
    list=extend_schema(
        summary="List Todos",
        description="Get a paginated list of todos for the authenticated user",
        tags=['Example']
    ),
    retrieve=extend_schema(
        summary="Get Todo",
        description="Get a specific todo by ID",
        tags=['Example']
    ),
    create=extend_schema(
        summary="Create Todo",
        description="Create a new todo",
        tags=['Example']
    ),
    update=extend_schema(
        summary="Update Todo",
        description="Update an existing todo",
        tags=['Example']
    ),
    partial_update=extend_schema(
        summary="Partial Update Todo",
        description="Partially update an existing todo",
        tags=['Example']
    ),
    destroy=extend_schema(
        summary="Delete Todo",
        description="Delete a todo",
        tags=['Example']
    ),
)
class TodoViewSet(viewsets.ModelViewSet):
    """
    ViewSet for Todo CRUD operations.
    Demonstrates the API presentation layer pattern.
    """
    permission_classes = [IsAuthenticated]
    filter_backends = [DjangoFilterBackend, SearchFilter, OrderingFilter]
    filterset_class = TodoFilter
    search_fields = ['title', 'description']
    ordering_fields = ['created_at', 'updated_at', 'due_date', 'priority']
    ordering = ['-created_at']

    def get_queryset(self):
        """Get todos for the authenticated user."""
        return Todo.objects.filter(user=self.request.user)

    def get_serializer_class(self):
        """Return appropriate serializer class based on action."""
        if self.action in ['create', 'update', 'partial_update']:
            return TodoCreateUpdateSerializer
        return TodoSerializer

    def perform_create(self, serializer):
        """Create todo with the authenticated user."""
        serializer.save(user=self.request.user)

    @extend_schema(
        summary="Mark Todo as Complete",
        description="Mark a todo as completed",
        tags=['Example'],
        request=None,
        responses={200: TodoSerializer}
    )
    @action(detail=True, methods=['post'])
    def complete(self, request, pk=None):
        """Mark todo as completed using service layer."""
        todo = self.get_object()
        updated_todo = TodoService.mark_todo_complete(todo_id=todo.id)
        serializer = TodoSerializer(updated_todo)
        return Response(serializer.data)

    @extend_schema(
        summary="Get User Statistics",
        description="Get todo statistics for the authenticated user",
        tags=['Example'],
        responses={200: TodoStatsSerializer}
    )
    @action(detail=False, methods=['get'])
    def stats(self, request):
        """Get statistics for user's todos using service layer."""
        stats = TodoService.get_user_statistics(user=request.user)
        serializer = TodoStatsSerializer(stats)
        return Response(serializer.data)

    @extend_schema(
        summary="Bulk Update Priority",
        description="Update priority for multiple todos",
        tags=['Example'],
        request={
            'application/json': {
                'type': 'object',
                'properties': {
                    'todo_ids': {
                        'type': 'array',
                        'items': {'type': 'integer'}
                    },
                    'priority': {
                        'type': 'string',
                        'enum': ['low', 'medium', 'high']
                    }
                },
                'required': ['todo_ids', 'priority']
            }
        },
        responses={200: {'description': 'Updated count'}}
    )
    @action(detail=False, methods=['post'])
    def bulk_update_priority(self, request):
        """Bulk update priority using service layer."""
        todo_ids = request.data.get('todo_ids', [])
        priority = request.data.get('priority')

        if not todo_ids or not priority:
            return Response(
                {'error': 'todo_ids and priority are required'},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Ensure user can only update their own todos
        user_todos = self.get_queryset().filter(id__in=todo_ids)
        updated_count = TodoService.bulk_update_priority(
            todo_ids=list(user_todos.values_list('id', flat=True)),
            priority=priority
        )

        return Response({
            'updated_count': updated_count,
            'message': f'Successfully updated {updated_count} todos'
        })

    @extend_schema(
        summary="Get Overdue Todos",
        description="Get all overdue todos for the authenticated user",
        tags=['Example'],
        responses={200: TodoSerializer(many=True)}
    )
    @action(detail=False, methods=['get'])
    def overdue(self, request):
        """Get overdue todos using service layer."""
        overdue_todos = TodoService.get_overdue_todos(user=request.user)
        serializer = TodoSerializer(overdue_todos, many=True)
        return Response(serializer.data)
