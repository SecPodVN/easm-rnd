"""
Todo API Serializers
"""
from rest_framework import serializers
from django.contrib.auth.models import User
from apps.todos.models import Todo


class UserSerializer(serializers.ModelSerializer):
    """
    User serializer for user information
    """
    class Meta:
        model = User
        fields = ['id', 'username', 'email', 'first_name', 'last_name']
        read_only_fields = ['id']


class TodoSerializer(serializers.ModelSerializer):
    """
    Todo serializer with user information - Used for read operations
    """
    user = UserSerializer(read_only=True)

    class Meta:
        model = Todo
        fields = [
            'id', 'title', 'description', 'status', 'priority',
            'user', 'created_at', 'updated_at', 'due_date', 'completed_at'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at', 'user', 'completed_at']

    def validate_status(self, value):
        """
        Validate status field
        """
        if value not in dict(Todo.STATUS_CHOICES).keys():
            raise serializers.ValidationError("Invalid status value")
        return value

    def validate_priority(self, value):
        """
        Validate priority field
        """
        if value not in dict(Todo.PRIORITY_CHOICES).keys():
            raise serializers.ValidationError("Invalid priority value")
        return value


class TodoCreateUpdateSerializer(serializers.ModelSerializer):
    """
    Todo serializer for create and update operations
    """
    class Meta:
        model = Todo
        fields = [
            'title', 'description', 'status', 'priority', 'due_date'
        ]

    def validate_status(self, value):
        """
        Validate status field
        """
        if value not in dict(Todo.STATUS_CHOICES).keys():
            raise serializers.ValidationError("Invalid status value")
        return value

    def validate_priority(self, value):
        """
        Validate priority field
        """
        if value not in dict(Todo.PRIORITY_CHOICES).keys():
            raise serializers.ValidationError("Invalid priority value")
        return value


class TodoBulkUpdateSerializer(serializers.Serializer):
    """
    Serializer for bulk update operations
    """
    ids = serializers.ListField(
        child=serializers.IntegerField(),
        required=True,
        help_text="List of todo IDs to update"
    )
    status = serializers.ChoiceField(
        choices=Todo.STATUS_CHOICES,
        required=False,
        help_text="New status for all selected todos"
    )
    priority = serializers.ChoiceField(
        choices=Todo.PRIORITY_CHOICES,
        required=False,
        help_text="New priority for all selected todos"
    )

    def validate_ids(self, value):
        """
        Validate that ids list is not empty
        """
        if not value:
            raise serializers.ValidationError("IDs list cannot be empty")
        return value

    def validate(self, data):
        """
        Validate that at least one field to update is provided
        """
        if 'status' not in data and 'priority' not in data:
            raise serializers.ValidationError(
                "At least one field (status or priority) must be provided"
            )
        return data


class TodoBulkDeleteSerializer(serializers.Serializer):
    """
    Serializer for bulk delete operations
    """
    ids = serializers.ListField(
        child=serializers.IntegerField(),
        required=True,
        help_text="List of todo IDs to delete"
    )

    def validate_ids(self, value):
        """
        Validate that ids list is not empty
        """
        if not value:
            raise serializers.ValidationError("IDs list cannot be empty")
        return value
