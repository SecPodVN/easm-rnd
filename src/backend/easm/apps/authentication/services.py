"""
Authentication service layer for business logic
"""
from django.contrib.auth.models import User
from django.contrib.auth import authenticate
from rest_framework_simplejwt.tokens import RefreshToken
from typing import Dict, Optional, Tuple
from .models import UserProfile


class AuthenticationService:
    """
    Service class for authentication-related business logic.
    Keeps views thin and business logic centralized.
    """

    @staticmethod
    def create_user_with_profile(
        username: str,
        email: str,
        password: str,
        **profile_data
    ) -> Tuple[User, UserProfile]:
        """
        Create a user and associated profile.

        Args:
            username: Username for the new user
            email: Email address
            password: Password (will be hashed)
            **profile_data: Additional profile fields (phone_number, organization, etc.)

        Returns:
            Tuple of (User, UserProfile)
        """
        # Create user
        user = User.objects.create_user(
            username=username,
            email=email,
            password=password
        )

        # Create profile
        profile = UserProfile.objects.create(
            user=user,
            **profile_data
        )

        return user, profile

    @staticmethod
    def authenticate_user(username: str, password: str) -> Optional[User]:
        """
        Authenticate a user by username and password.

        Args:
            username: Username
            password: Password

        Returns:
            User object if authentication successful, None otherwise
        """
        return authenticate(username=username, password=password)

    @staticmethod
    def generate_tokens(user: User) -> Dict[str, str]:
        """
        Generate JWT access and refresh tokens for a user.

        Args:
            user: User object

        Returns:
            Dictionary with 'access' and 'refresh' tokens
        """
        refresh = RefreshToken.for_user(user)
        return {
            'refresh': str(refresh),
            'access': str(refresh.access_token),
        }

    @staticmethod
    def update_user_profile(user: User, **profile_data) -> UserProfile:
        """
        Update user profile information.

        Args:
            user: User object
            **profile_data: Profile fields to update

        Returns:
            Updated UserProfile
        """
        profile = user.profile
        for key, value in profile_data.items():
            if hasattr(profile, key):
                setattr(profile, key, value)
        profile.save()
        return profile

    @staticmethod
    def change_password(user: User, old_password: str, new_password: str) -> bool:
        """
        Change user password after verifying old password.

        Args:
            user: User object
            old_password: Current password
            new_password: New password

        Returns:
            True if password changed successfully, False otherwise
        """
        if not user.check_password(old_password):
            return False

        user.set_password(new_password)
        user.save()
        return True

    @staticmethod
    def deactivate_user(user: User) -> None:
        """
        Deactivate a user account.

        Args:
            user: User object to deactivate
        """
        user.is_active = False
        user.save()

    @staticmethod
    def activate_user(user: User) -> None:
        """
        Activate a user account.

        Args:
            user: User object to activate
        """
        user.is_active = True
        user.save()
