"""
REST API Serializers - Centralized serializers for API
NOTE: Todo-related serializers have been moved to apps.api.todo.serializers
"""
from rest_framework import serializers
from django.contrib.auth.models import User


class UserSerializer(serializers.ModelSerializer):
    """
    User serializer for user information
    """
    class Meta:
        model = User
        fields = ['id', 'username', 'email', 'first_name', 'last_name']
        read_only_fields = ['id']
