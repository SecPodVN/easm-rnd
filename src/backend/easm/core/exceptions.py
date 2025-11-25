"""
Custom API Exceptions and Error Handlers
"""
from rest_framework.views import exception_handler
from rest_framework.exceptions import APIException
from rest_framework import status
from typing import Dict, Any


class BaseAPIException(APIException):
    """Base exception for all custom API exceptions"""
    status_code = status.HTTP_400_BAD_REQUEST
    default_detail = 'An error occurred'
    default_code = 'error'


class ValidationError(BaseAPIException):
    """Custom validation error"""
    status_code = status.HTTP_400_BAD_REQUEST
    default_detail = 'Validation failed'
    default_code = 'validation_error'


class ResourceNotFound(BaseAPIException):
    """Resource not found"""
    status_code = status.HTTP_404_NOT_FOUND
    default_detail = 'Resource not found'
    default_code = 'not_found'


class PermissionDenied(BaseAPIException):
    """Permission denied"""
    status_code = status.HTTP_403_FORBIDDEN
    default_detail = 'Permission denied'
    default_code = 'permission_denied'


class Unauthorized(BaseAPIException):
    """Unauthorized access"""
    status_code = status.HTTP_401_UNAUTHORIZED
    default_detail = 'Authentication required'
    default_code = 'unauthorized'


class ConflictError(BaseAPIException):
    """Resource conflict"""
    status_code = status.HTTP_409_CONFLICT
    default_detail = 'Resource conflict'
    default_code = 'conflict'


class RateLimitExceeded(BaseAPIException):
    """Rate limit exceeded"""
    status_code = status.HTTP_429_TOO_MANY_REQUESTS
    default_detail = 'Rate limit exceeded'
    default_code = 'rate_limit_exceeded'


class ServiceUnavailable(BaseAPIException):
    """Service unavailable"""
    status_code = status.HTTP_503_SERVICE_UNAVAILABLE
    default_detail = 'Service temporarily unavailable'
    default_code = 'service_unavailable'


def custom_exception_handler(exc, context):
    """
    Custom exception handler for consistent error responses

    Returns error responses in format:
    {
        "error": {
            "code": "error_code",
            "message": "Human readable message",
            "details": {...},  # Optional field-specific errors
            "timestamp": "2025-11-24T12:00:00Z"
        }
    }
    """
    # Call REST framework's default exception handler first
    response = exception_handler(exc, context)

    if response is not None:
        from datetime import datetime

        error_response: Dict[str, Any] = {
            'error': {
                'code': getattr(exc, 'default_code', 'error'),
                'message': str(exc.detail) if hasattr(exc, 'detail') else str(exc),
                'timestamp': datetime.utcnow().isoformat() + 'Z'
            }
        }

        # Add field-specific errors if available (validation errors)
        if isinstance(response.data, dict) and not isinstance(exc, BaseAPIException):
            error_response['error']['details'] = response.data

        response.data = error_response

    return response
