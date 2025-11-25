"""
Standardized API Response Utilities
"""
from rest_framework.response import Response
from rest_framework import status
from typing import Any, Dict, Optional
from datetime import datetime


class APIResponse:
    """Helper class for standardized API responses"""

    @staticmethod
    def success(
        data: Any = None,
        message: str = "Success",
        status_code: int = status.HTTP_200_OK,
        meta: Optional[Dict] = None
    ) -> Response:
        """
        Standardized success response

        Format:
        {
            "success": true,
            "message": "...",
            "data": {...},
            "meta": {...}  # Optional metadata like pagination
        }
        """
        response_data = {
            "success": True,
            "message": message,
            "data": data
        }

        if meta:
            response_data["meta"] = meta

        return Response(response_data, status=status_code)

    @staticmethod
    def error(
        message: str = "An error occurred",
        code: str = "error",
        details: Optional[Dict] = None,
        status_code: int = status.HTTP_400_BAD_REQUEST
    ) -> Response:
        """
        Standardized error response

        Format:
        {
            "success": false,
            "error": {
                "code": "...",
                "message": "...",
                "details": {...},
                "timestamp": "..."
            }
        }
        """
        response_data = {
            "success": False,
            "error": {
                "code": code,
                "message": message,
                "timestamp": datetime.utcnow().isoformat() + 'Z'
            }
        }

        if details:
            response_data["error"]["details"] = details

        return Response(response_data, status=status_code)

    @staticmethod
    def paginated(
        data: list,
        count: int,
        page: int,
        page_size: int,
        message: str = "Success"
    ) -> Response:
        """
        Standardized paginated response

        Format:
        {
            "success": true,
            "message": "...",
            "data": [...],
            "meta": {
                "pagination": {
                    "count": 100,
                    "page": 1,
                    "page_size": 10,
                    "total_pages": 10
                }
            }
        }
        """
        total_pages = (count + page_size - 1) // page_size  # Ceiling division

        return APIResponse.success(
            data=data,
            message=message,
            meta={
                "pagination": {
                    "count": count,
                    "page": page,
                    "page_size": page_size,
                    "total_pages": total_pages
                }
            }
        )
