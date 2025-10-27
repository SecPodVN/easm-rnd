"""
Todo API Views - All todo-related REST API endpoints
"""
from rest_framework import viewsets, filters, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django_filters.rest_framework import DjangoFilterBackend
from django.utils import timezone
from django.db.models import Q
from apps.todos.models import Todo
from .serializers import (
    TodoSerializer,
    TodoCreateUpdateSerializer,
    TodoBulkUpdateSerializer,
    TodoBulkDeleteSerializer
)


class TodoViewSet(viewsets.ModelViewSet):
    """
    ViewSet for Todo CRUD operations

    Provides standard CRUD operations:
    - list: GET /api/todos/
    - create: POST /api/todos/
    - retrieve: GET /api/todos/{id}/
    - update: PUT /api/todos/{id}/
    - partial_update: PATCH /api/todos/{id}/
    - destroy: DELETE /api/todos/{id}/

    Additional custom actions:
    - complete: POST /api/todos/{id}/complete/
    - uncomplete: POST /api/todos/{id}/uncomplete/
    - my_todos: GET /api/todos/my_todos/
    - statistics: GET /api/todos/statistics/
    - overdue: GET /api/todos/overdue/
    - by_status: GET /api/todos/by_status/?status={status}
    - by_priority: GET /api/todos/by_priority/?priority={priority}
    - bulk_update: POST /api/todos/bulk_update/
    - bulk_delete: POST /api/todos/bulk_delete/
    - bulk_complete: POST /api/todos/bulk_complete/
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
        return Todo.objects.filter(user=self.request.user)

    def get_serializer_class(self):
        """
        Return appropriate serializer based on action
        """
        if self.action in ['create', 'update', 'partial_update']:
            return TodoCreateUpdateSerializer
        elif self.action == 'bulk_update':
            return TodoBulkUpdateSerializer
        elif self.action == 'bulk_delete':
            return TodoBulkDeleteSerializer
        return TodoSerializer

    def perform_create(self, serializer):
        """
        Set the user when creating a todo
        """
        serializer.save(user=self.request.user)

    def destroy(self, request, *args, **kwargs):
        """
        Delete a todo (soft delete in future if needed)
        """
        instance = self.get_object()
        self.perform_destroy(instance)
        return Response(
            {'message': 'Todo deleted successfully'},
            status=status.HTTP_204_NO_CONTENT
        )

    @action(detail=True, methods=['post'])
    def complete(self, request, pk=None):
        """
        Mark a todo as completed
        POST /api/todos/{id}/complete/
        """
        todo = self.get_object()
        todo.status = 'completed'
        todo.completed_at = timezone.now()
        todo.save()
        serializer = self.get_serializer(todo)
        return Response(serializer.data)

    @action(detail=True, methods=['post'])
    def uncomplete(self, request, pk=None):
        """
        Mark a completed todo as pending/in-progress
        POST /api/todos/{id}/uncomplete/
        """
        todo = self.get_object()
        if todo.status == 'completed':
            todo.status = 'pending'
            todo.completed_at = None
            todo.save()
            serializer = self.get_serializer(todo)
            return Response(serializer.data)
        else:
            return Response(
                {'error': 'Todo is not completed'},
                status=status.HTTP_400_BAD_REQUEST
            )

    @action(detail=False, methods=['get'])
    def my_todos(self, request):
        """
        Get all todos for the current user with pagination
        GET /api/todos/my_todos/
        """
        queryset = self.filter_queryset(self.get_queryset())
        page = self.paginate_queryset(queryset)
        if page is not None:
            serializer = self.get_serializer(page, many=True)
            return self.get_paginated_response(serializer.data)

        serializer = self.get_serializer(queryset, many=True)
        return Response(serializer.data)

    @action(detail=False, methods=['get'])
    def statistics(self, request):
        """
        Get statistics about user's todos
        GET /api/todos/statistics/
        """
        queryset = self.get_queryset()
        total = queryset.count()
        pending = queryset.filter(status='pending').count()
        in_progress = queryset.filter(status='in_progress').count()
        completed = queryset.filter(status='completed').count()

        # Priority statistics
        high_priority = queryset.filter(priority='high').count()
        medium_priority = queryset.filter(priority='medium').count()
        low_priority = queryset.filter(priority='low').count()

        # Overdue todos
        now = timezone.now()
        overdue = queryset.filter(
            due_date__lt=now,
            status__in=['pending', 'in_progress']
        ).count()

        return Response({
            'total': total,
            'by_status': {
                'pending': pending,
                'in_progress': in_progress,
                'completed': completed,
            },
            'by_priority': {
                'high': high_priority,
                'medium': medium_priority,
                'low': low_priority,
            },
            'overdue': overdue,
            'completion_rate': (completed / total * 100) if total > 0 else 0
        })

    @action(detail=False, methods=['get'])
    def overdue(self, request):
        """
        Get all overdue todos (with due_date in the past and not completed)
        GET /api/todos/overdue/
        """
        now = timezone.now()
        queryset = self.get_queryset().filter(
            due_date__lt=now,
            status__in=['pending', 'in_progress']
        )

        page = self.paginate_queryset(queryset)
        if page is not None:
            serializer = self.get_serializer(page, many=True)
            return self.get_paginated_response(serializer.data)

        serializer = self.get_serializer(queryset, many=True)
        return Response(serializer.data)

    @action(detail=False, methods=['get'])
    def by_status(self, request):
        """
        Get todos filtered by status
        GET /api/todos/by_status/?status=pending
        """
        status_param = request.query_params.get('status', None)
        if not status_param:
            return Response(
                {'error': 'Status parameter is required'},
                status=status.HTTP_400_BAD_REQUEST
            )

        queryset = self.get_queryset().filter(status=status_param)
        page = self.paginate_queryset(queryset)
        if page is not None:
            serializer = self.get_serializer(page, many=True)
            return self.get_paginated_response(serializer.data)

        serializer = self.get_serializer(queryset, many=True)
        return Response(serializer.data)

    @action(detail=False, methods=['get'])
    def by_priority(self, request):
        """
        Get todos filtered by priority
        GET /api/todos/by_priority/?priority=high
        """
        priority_param = request.query_params.get('priority', None)
        if not priority_param:
            return Response(
                {'error': 'Priority parameter is required'},
                status=status.HTTP_400_BAD_REQUEST
            )

        queryset = self.get_queryset().filter(priority=priority_param)
        page = self.paginate_queryset(queryset)
        if page is not None:
            serializer = self.get_serializer(page, many=True)
            return self.get_paginated_response(serializer.data)

        serializer = self.get_serializer(queryset, many=True)
        return Response(serializer.data)

    @action(detail=False, methods=['post'])
    def bulk_update(self, request):
        """
        Bulk update multiple todos (status, priority)
        POST /api/todos/bulk_update/
        Body: {
            "ids": [1, 2, 3],
            "status": "completed",  // optional
            "priority": "high"      // optional
        }
        """
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        ids = serializer.validated_data['ids']
        update_data = {}

        if 'status' in serializer.validated_data:
            update_data['status'] = serializer.validated_data['status']
            if update_data['status'] == 'completed':
                update_data['completed_at'] = timezone.now()

        if 'priority' in serializer.validated_data:
            update_data['priority'] = serializer.validated_data['priority']

        # Only update todos belonging to the current user
        updated_count = self.get_queryset().filter(id__in=ids).update(**update_data)

        return Response({
            'message': f'Successfully updated {updated_count} todos',
            'updated_count': updated_count
        })

    @action(detail=False, methods=['post'])
    def bulk_delete(self, request):
        """
        Bulk delete multiple todos
        POST /api/todos/bulk_delete/
        Body: {
            "ids": [1, 2, 3]
        }
        """
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        ids = serializer.validated_data['ids']

        # Only delete todos belonging to the current user
        deleted_count, _ = self.get_queryset().filter(id__in=ids).delete()

        return Response({
            'message': f'Successfully deleted {deleted_count} todos',
            'deleted_count': deleted_count
        }, status=status.HTTP_204_NO_CONTENT)

    @action(detail=False, methods=['post'])
    def bulk_complete(self, request):
        """
        Bulk complete multiple todos
        POST /api/todos/bulk_complete/
        Body: {
            "ids": [1, 2, 3]
        }
        """
        serializer = TodoBulkDeleteSerializer(data=request.data)  # Reuse for IDs validation
        serializer.is_valid(raise_exception=True)

        ids = serializer.validated_data['ids']

        # Only update todos belonging to the current user
        updated_count = self.get_queryset().filter(id__in=ids).update(
            status='completed',
            completed_at=timezone.now()
        )

        return Response({
            'message': f'Successfully completed {updated_count} todos',
            'completed_count': updated_count
        })
