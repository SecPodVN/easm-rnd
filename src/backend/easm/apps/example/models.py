from django.db import models
from django.contrib.auth.models import User
from django.utils import timezone

from easm.apps.core.models import TimeStampedModel
from easm.common.enums import TodoStatus, TodoPriority


class Todo(TimeStampedModel):
    """
    Todo model for task management
    Inherits created_at and updated_at from TimeStampedModel
    """
    STATUS_CHOICES = [
        (TodoStatus.PENDING.value, 'Pending'),
        (TodoStatus.IN_PROGRESS.value, 'In Progress'),
        (TodoStatus.COMPLETED.value, 'Completed'),
    ]
    
    PRIORITY_CHOICES = [
        (TodoPriority.LOW.value, 'Low'),
        (TodoPriority.MEDIUM.value, 'Medium'),
        (TodoPriority.HIGH.value, 'High'),
    ]
    
    title = models.CharField(max_length=255, db_index=True)
    description = models.TextField(blank=True, null=True)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending', db_index=True)
    priority = models.CharField(max_length=20, choices=PRIORITY_CHOICES, default='medium', db_index=True)
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='todos', db_index=True)
    due_date = models.DateTimeField(blank=True, null=True, db_index=True)
    completed_at = models.DateTimeField(blank=True, null=True)
    
    class Meta:
        ordering = ['-created_at']
        verbose_name = 'Todo'
        verbose_name_plural = 'Todos'
        indexes = [
            models.Index(fields=['user', 'status']),
            models.Index(fields=['user', '-created_at']),
        ]
    
    def __str__(self):
        return self.title
    
    def mark_complete(self):
        """Mark todo as completed"""
        self.status = TodoStatus.COMPLETED.value
        self.completed_at = timezone.now()
        self.save(update_fields=['status', 'completed_at', 'updated_at'])
