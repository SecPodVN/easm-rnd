"""
Todos Business Logic Services
Contains business logic and complex operations for the todos app
"""
from django.utils import timezone
from django.db.models import Q, Count
from typing import Optional, Dict, Any
from .models import Todo


class TodoService:
    """
    Service class for Todo business logic
    Separates business logic from views
    """

    @staticmethod
    def get_user_statistics(user) -> Dict[str, Any]:
        """
        Calculate comprehensive statistics for a user's todos
        
        Args:
            user: The user object
            
        Returns:
            Dictionary with statistics
        """
        queryset = Todo.objects.filter(user=user)
        total = queryset.count()
        
        stats = queryset.aggregate(
            pending=Count('id', filter=Q(status='pending')),
            in_progress=Count('id', filter=Q(status='in_progress')),
            completed=Count('id', filter=Q(status='completed')),
        )
        
        overdue = queryset.filter(
            due_date__lt=timezone.now(),
            status__in=['pending', 'in_progress']
        ).count()
        
        return {
            'total': total,
            'pending': stats['pending'],
            'in_progress': stats['in_progress'],
            'completed': stats['completed'],
            'overdue': overdue,
            'completion_rate': (stats['completed'] / total * 100) if total > 0 else 0
        }

    @staticmethod
    def mark_todo_complete(todo_id: int, user) -> Optional[Todo]:
        """
        Mark a todo as completed
        
        Args:
            todo_id: The ID of the todo
            user: The user object (for permission check)
            
        Returns:
            Updated Todo object or None if not found
        """
        try:
            todo = Todo.objects.get(id=todo_id, user=user)
            todo.mark_complete()
            return todo
        except Todo.DoesNotExist:
            return None

    @staticmethod
    def bulk_update_priority(todo_ids: list, priority: str, user) -> int:
        """
        Update priority for multiple todos
        
        Args:
            todo_ids: List of todo IDs
            priority: New priority value
            user: The user object (for permission check)
            
        Returns:
            Number of todos updated
        """
        return Todo.objects.filter(
            id__in=todo_ids,
            user=user
        ).update(priority=priority)

    @staticmethod
    def get_overdue_todos(user):
        """
        Get all overdue todos for a user
        
        Args:
            user: The user object
            
        Returns:
            QuerySet of overdue todos
        """
        return Todo.objects.filter(
            user=user,
            due_date__lt=timezone.now(),
            status__in=['pending', 'in_progress']
        ).select_related('user')
