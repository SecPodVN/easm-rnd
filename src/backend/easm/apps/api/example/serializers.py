"""
Serializers for the Example domain API.
Presentation layer - transforms domain models to/from JSON.
"""
from rest_framework import serializers
from easm.apps.example.models import Todo
from easm.common.enums import TodoStatus, TodoPriority


class TodoSerializer(serializers.ModelSerializer):
    """
    Standard serializer for Todo model.
    """
    user_username = serializers.CharField(source='user.username', read_only=True)
    is_overdue = serializers.SerializerMethodField()

    class Meta:
        model = Todo
        fields = [
            'id',
            'title',
            'description',
            'status',
            'priority',
            'user',
            'user_username',
            'due_date',
            'completed_at',
            'is_overdue',
            'created_at',
            'updated_at',
        ]
        read_only_fields = ['id', 'user', 'completed_at', 'created_at', 'updated_at']

    def get_is_overdue(self, obj):
        """Check if todo is overdue."""
        if obj.due_date and obj.status != TodoStatus.COMPLETED.value:
            from django.utils import timezone
            return timezone.now() > obj.due_date
        return False


class TodoCreateUpdateSerializer(serializers.ModelSerializer):
    """
    Serializer for creating and updating todos.
    """

    class Meta:
        model = Todo
        fields = [
            'title',
            'description',
            'status',
            'priority',
            'due_date',
        ]

    def validate_status(self, value):
        """Validate status field."""
        valid_statuses = [choice.value for choice in TodoStatus]
        if value not in valid_statuses:
            raise serializers.ValidationError(f"Invalid status. Choose from: {valid_statuses}")
        return value

    def validate_priority(self, value):
        """Validate priority field."""
        valid_priorities = [choice.value for choice in TodoPriority]
        if value not in valid_priorities:
            raise serializers.ValidationError(f"Invalid priority. Choose from: {valid_priorities}")
        return value


class TodoStatsSerializer(serializers.Serializer):
    """
    Serializer for todo statistics.
    """
    total_todos = serializers.IntegerField()
    completed_todos = serializers.IntegerField()
    pending_todos = serializers.IntegerField()
    in_progress_todos = serializers.IntegerField()
    overdue_todos = serializers.IntegerField()
    completion_rate = serializers.FloatField()
