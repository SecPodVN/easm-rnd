"""
Authentication URL Configuration
"""
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from . import views

app_name = 'authentication'

# Router for viewsets
router = DefaultRouter()
router.register(r'profile', views.UserProfileViewSet, basename='profile')
router.register(r'account', views.UserViewSet, basename='account')

urlpatterns = [
    # Authentication endpoints
    path('register/', views.register, name='register'),
    path('login/', views.login, name='login'),
    path('me/', views.current_user, name='current-user'),

    # Password management
    path('change-password/', views.change_password, name='change-password'),
    path('password-reset/', views.password_reset_request, name='password-reset'),
    path('password-reset/confirm/', views.password_reset_confirm, name='password-reset-confirm'),

    # ViewSet routes (profile, account)
    path('', include(router.urls)),
]
