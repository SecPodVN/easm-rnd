"""
Authentication API URL Configuration
"""
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import (
    register,
    login,
    current_user,
    change_password,
    password_reset_request,
    password_reset_confirm,
    UserProfileViewSet,
    UserViewSet
)

# Router for viewsets
router = DefaultRouter()
router.register(r'profile', UserProfileViewSet, basename='profile')
router.register(r'account', UserViewSet, basename='account')

urlpatterns = [
    # Authentication endpoints
    path('register/', register, name='register'),
    path('login/', login, name='login'),
    path('me/', current_user, name='current-user'),
    
    # Password management
    path('change-password/', change_password, name='change-password'),
    path('password-reset/', password_reset_request, name='password-reset'),
    path('password-reset/confirm/', password_reset_confirm, name='password-reset-confirm'),
    
    # ViewSet routes (profile, account)
    path('', include(router.urls)),
]
