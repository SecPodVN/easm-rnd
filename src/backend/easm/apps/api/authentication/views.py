"""
Authentication API Views
Re-exports from domain layer
"""
from easm.apps.authentication.views import (
    register,
    login,
    current_user,
    change_password,
    password_reset_request,
    password_reset_confirm,
    UserProfileViewSet,
    UserViewSet
)

__all__ = [
    'register',
    'login',
    'current_user',
    'change_password',
    'password_reset_request',
    'password_reset_confirm',
    'UserProfileViewSet',
    'UserViewSet'
]
