"""
REST API Permissions - Base permission classes
Shared permissions for all apps
"""
from rest_framework import permissions


class IsOwner(permissions.BasePermission):
    """
    Custom permission to only allow owners of an object to access it.
    Checks for 'user', 'owner' attributes, or if obj is a User instance.
    """
    def has_object_permission(self, request, view, obj):
        # Check if obj has a 'user' attribute
        if hasattr(obj, 'user'):
            return obj.user == request.user
        # Check if obj has an 'owner' attribute
        if hasattr(obj, 'owner'):
            return obj.owner == request.user
        # If neither, check if obj is a User instance
        return obj == request.user


class IsOwnerOrReadOnly(permissions.BasePermission):
    """
    Custom permission to only allow owners to edit, but allow read-only access to others.
    """
    def has_object_permission(self, request, view, obj):
        # Read permissions are allowed for any request
        if request.method in permissions.SAFE_METHODS:
            return True

        # Write permissions only for the owner
        if hasattr(obj, 'user'):
            return obj.user == request.user
        if hasattr(obj, 'owner'):
            return obj.owner == request.user
        return obj == request.user


class IsAdminOrReadOnly(permissions.BasePermission):
    """
    Permission to only allow admin users to edit.
    """
    def has_permission(self, request, view):
        if request.method in permissions.SAFE_METHODS:
            return True
        return request.user and request.user.is_staff


class IsAuthenticatedOrCreateOnly(permissions.BasePermission):
    """
    Allow unauthenticated users to create (e.g., registration),
    but require authentication for other operations.
    """
    def has_permission(self, request, view):
        if request.method == 'POST':
            return True
        return request.user and request.user.is_authenticated
