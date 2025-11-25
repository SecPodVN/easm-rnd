"""
Authentication Views
"""
from rest_framework import status, viewsets
from rest_framework.decorators import api_view, permission_classes, action
from rest_framework.response import Response
from rest_framework.permissions import AllowAny, IsAuthenticated
from django.contrib.auth.models import User
from drf_spectacular.utils import extend_schema, OpenApiExample, OpenApiResponse
from easm.apps.core.permissions import IsOwner
from .models import UserProfile
from .serializers import (
    UserSerializer,
    UserRegistrationSerializer,
    LoginSerializer,
    ChangePasswordSerializer,
    PasswordResetRequestSerializer,
    PasswordResetConfirmSerializer,
    UserProfileUpdateSerializer,
    UserUpdateSerializer
)
from .services import AuthenticationService


@extend_schema(
    summary="Register a new user",
    description="Create a new user account with username, password, and optional profile information.",
    request=UserRegistrationSerializer,
    responses={
        201: OpenApiResponse(
            response={'type': 'object', 'properties': {
                'message': {'type': 'string'},
                'user': {'$ref': '#/components/schemas/User'},
                'tokens': {'type': 'object', 'properties': {
                    'access': {'type': 'string'},
                    'refresh': {'type': 'string'}
                }}
            }},
            description="User registered successfully"
        ),
        400: OpenApiResponse(description="Validation error")
    },
    examples=[
        OpenApiExample(
            'Registration Example',
            value={
                'username': 'newuser',
                'email': 'newuser@example.com',
                'password': 'SecurePass123!',
                'password_confirm': 'SecurePass123!',
                'first_name': 'John',
                'last_name': 'Doe',
                'profile': {
                    'phone_number': '+1234567890',
                    'organization': 'ACME Corp',
                    'job_title': 'Security Analyst'
                }
            },
            request_only=True
        )
    ],
    tags=['Authentication']
)
@api_view(['POST'])
@permission_classes([AllowAny])
def register(request):
    """Register a new user and return tokens"""
    serializer = UserRegistrationSerializer(data=request.data)
    if serializer.is_valid():
        user = serializer.save()
        tokens = AuthenticationService.generate_tokens(user)
        user_data = UserSerializer(user).data
        return Response({
            'message': 'User registered successfully',
            'user': user_data,
            'tokens': tokens
        }, status=status.HTTP_201_CREATED)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@extend_schema(
    summary="Login user",
    description="Authenticate user with username and password, returns JWT tokens",
    request=LoginSerializer,
    responses={
        200: OpenApiResponse(
            response={'type': 'object', 'properties': {
                'message': {'type': 'string'},
                'user': {'$ref': '#/components/schemas/User'},
                'tokens': {'type': 'object', 'properties': {
                    'access': {'type': 'string'},
                    'refresh': {'type': 'string'}
                }}
            }},
            description="Login successful"
        ),
        400: OpenApiResponse(description="Invalid credentials")
    },
    examples=[
        OpenApiExample(
            'Login Example',
            value={'username': 'admin', 'password': 'SecurePass123!'},
            request_only=True
        )
    ],
    tags=['Authentication']
)
@api_view(['POST'])
@permission_classes([AllowAny])
def login(request):
    """Login user and return tokens"""
    serializer = LoginSerializer(data=request.data)
    if serializer.is_valid():
        user = serializer.validated_data['user']
        tokens = AuthenticationService.generate_tokens(user)
        user_data = UserSerializer(user).data
        return Response({
            'message': 'Login successful',
            'user': user_data,
            'tokens': tokens
        }, status=status.HTTP_200_OK)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@extend_schema(
    summary="Get current user profile",
    description="Retrieve the authenticated user's profile information",
    responses={
        200: UserSerializer,
        401: OpenApiResponse(description="Authentication required")
    },
    tags=['Authentication']
)
@api_view(['GET'])
@permission_classes([IsAuthenticated])
def current_user(request):
    """Get current authenticated user"""
    serializer = UserSerializer(request.user)
    return Response(serializer.data)


@extend_schema(
    summary="Change password",
    description="Change the password for the authenticated user",
    request=ChangePasswordSerializer,
    responses={
        200: OpenApiResponse(
            response={'type': 'object', 'properties': {'message': {'type': 'string'}}},
            description="Password changed successfully"
        ),
        400: OpenApiResponse(description="Validation error")
    },
    examples=[
        OpenApiExample(
            'Change Password Example',
            value={
                'old_password': 'OldPass123!',
                'new_password': 'NewSecurePass123!',
                'new_password_confirm': 'NewSecurePass123!'
            },
            request_only=True
        )
    ],
    tags=['Authentication']
)
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def change_password(request):
    """Change user password"""
    serializer = ChangePasswordSerializer(data=request.data)
    if serializer.is_valid():
        success = AuthenticationService.change_password(
            user=request.user,
            old_password=serializer.validated_data['old_password'],
            new_password=serializer.validated_data['new_password']
        )
        if success:
            return Response({
                'message': 'Password changed successfully'
            }, status=status.HTTP_200_OK)
        else:
            return Response({
                'old_password': ['Incorrect password']
            }, status=status.HTTP_400_BAD_REQUEST)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@extend_schema(
    summary="Request password reset",
    description="Send password reset email to user",
    request=PasswordResetRequestSerializer,
    responses={
        200: OpenApiResponse(
            response={'type': 'object', 'properties': {'message': {'type': 'string'}}},
            description="Password reset email sent"
        ),
        400: OpenApiResponse(description="Validation error")
    },
    examples=[
        OpenApiExample(
            'Password Reset Request',
            value={'email': 'user@example.com'},
            request_only=True
        )
    ],
    tags=['Authentication']
)
@api_view(['POST'])
@permission_classes([AllowAny])
def password_reset_request(request):
    """Request password reset (email functionality to be implemented)"""
    serializer = PasswordResetRequestSerializer(data=request.data)
    if serializer.is_valid():
        # TODO: Implement email sending logic
        return Response({
            'message': 'Password reset instructions sent to email'
        }, status=status.HTTP_200_OK)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@extend_schema(
    summary="Confirm password reset",
    description="Reset password using token from email",
    request=PasswordResetConfirmSerializer,
    responses={
        200: OpenApiResponse(
            response={'type': 'object', 'properties': {'message': {'type': 'string'}}},
            description="Password reset successful"
        ),
        400: OpenApiResponse(description="Invalid token or validation error")
    },
    tags=['Authentication']
)
@api_view(['POST'])
@permission_classes([AllowAny])
def password_reset_confirm(request):
    """Confirm password reset with token (to be implemented)"""
    serializer = PasswordResetConfirmSerializer(data=request.data)
    if serializer.is_valid():
        # TODO: Implement token validation and password reset
        return Response({
            'message': 'Password reset successful'
        }, status=status.HTTP_200_OK)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class UserProfileViewSet(viewsets.ModelViewSet):
    """
    ViewSet for user profile management.
    Users can only access and modify their own profile.
    """
    serializer_class = UserProfileUpdateSerializer
    permission_classes = [IsAuthenticated, IsOwner]

    def get_queryset(self):
        """Users can only see their own profile"""
        return UserProfile.objects.filter(user=self.request.user)

    def get_object(self):
        """Get the current user's profile"""
        return self.request.user.profile

    @extend_schema(
        summary="Get user profile",
        description="Retrieve the authenticated user's profile",
        responses={200: UserProfileUpdateSerializer},
        tags=['Profile']
    )
    def retrieve(self, request, *args, **kwargs):
        """Get current user's profile"""
        return super().retrieve(request, *args, **kwargs)

    @extend_schema(
        summary="Update user profile",
        description="Update the authenticated user's profile information",
        request=UserProfileUpdateSerializer,
        responses={200: UserProfileUpdateSerializer},
        tags=['Profile']
    )
    def update(self, request, *args, **kwargs):
        """Update current user's profile"""
        return super().update(request, *args, **kwargs)

    @extend_schema(
        summary="Partial update user profile",
        description="Partially update the authenticated user's profile",
        request=UserProfileUpdateSerializer,
        responses={200: UserProfileUpdateSerializer},
        tags=['Profile']
    )
    def partial_update(self, request, *args, **kwargs):
        """Partially update current user's profile"""
        return super().partial_update(request, *args, **kwargs)

    @extend_schema(exclude=True)
    def list(self, request, *args, **kwargs):
        """Not allowed - redirect to retrieve"""
        return self.retrieve(request, *args, **kwargs)

    @extend_schema(exclude=True)
    def create(self, request, *args, **kwargs):
        """Not allowed - profiles are auto-created"""
        return Response(
            {'detail': 'Profile creation not allowed. Profiles are auto-created with user registration.'},
            status=status.HTTP_405_METHOD_NOT_ALLOWED
        )

    @extend_schema(exclude=True)
    def destroy(self, request, *args, **kwargs):
        """Not allowed - use account deletion instead"""
        return Response(
            {'detail': 'Profile deletion not allowed. Use account deletion instead.'},
            status=status.HTTP_405_METHOD_NOT_ALLOWED
        )


class UserViewSet(viewsets.ModelViewSet):
    """
    ViewSet for user account management.
    Users can view and update their own account information.
    """
    serializer_class = UserSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        """Users can only see their own account"""
        return User.objects.filter(id=self.request.user.id)

    def get_object(self):
        """Get the current user"""
        return self.request.user

    def get_serializer_class(self):
        """Use different serializers for different actions"""
        if self.action in ['update', 'partial_update']:
            return UserUpdateSerializer
        return UserSerializer

    @extend_schema(
        summary="Get user account",
        description="Retrieve the authenticated user's account information",
        responses={200: UserSerializer},
        tags=['User Account']
    )
    def retrieve(self, request, *args, **kwargs):
        """Get current user's account"""
        return super().retrieve(request, *args, **kwargs)

    @extend_schema(
        summary="Update user account",
        description="Update the authenticated user's account information",
        request=UserUpdateSerializer,
        responses={200: UserSerializer},
        tags=['User Account']
    )
    def update(self, request, *args, **kwargs):
        """Update current user's account"""
        return super().update(request, *args, **kwargs)

    @extend_schema(
        summary="Partial update user account",
        description="Partially update the authenticated user's account",
        request=UserUpdateSerializer,
        responses={200: UserSerializer},
        tags=['User Account']
    )
    def partial_update(self, request, *args, **kwargs):
        """Partially update current user's account"""
        return super().partial_update(request, *args, **kwargs)

    @extend_schema(
        summary="Delete user account",
        description="Deactivate the authenticated user's account",
        responses={204: OpenApiResponse(description="Account deactivated")},
        tags=['User Account']
    )
    def destroy(self, request, *args, **kwargs):
        """Deactivate user account (soft delete)"""
        AuthenticationService.deactivate_user(request.user)
        return Response(
            {'message': 'Account deactivated successfully'},
            status=status.HTTP_204_NO_CONTENT
        )

    @extend_schema(exclude=True)
    def list(self, request, *args, **kwargs):
        """Not allowed - redirect to retrieve"""
        return self.retrieve(request, *args, **kwargs)

    @extend_schema(exclude=True)
    def create(self, request, *args, **kwargs):
        """Not allowed - use registration endpoint"""
        return Response(
            {'detail': 'User creation not allowed. Use /api/auth/register/ endpoint.'},
            status=status.HTTP_405_METHOD_NOT_ALLOWED
        )
