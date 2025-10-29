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
    Todo serializer with user information
    """
    user = UserSerializer(read_only=True)

    class Meta:
        model = Todo
        fields = [
            'id', 'title', 'description', 'status', 'priority',
            'user', 'created_at', 'updated_at', 'due_date', 'completed_at'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at', 'user']

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