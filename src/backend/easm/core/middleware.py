"""
Custom middleware
"""
import logging
from django.utils.deprecation import MiddlewareMixin
from django.utils import timezone

logger = logging.getLogger(__name__)


class RequestLoggingMiddleware(MiddlewareMixin):
    """Log all incoming requests"""

    def process_request(self, request):
        request.start_time = timezone.now()
        logger.info(f"Request: {request.method} {request.path}")
        return None

    def process_response(self, request, response):
        if hasattr(request, 'start_time'):
            duration = (timezone.now() - request.start_time).total_seconds()
            logger.info(
                f"Response: {request.method} {request.path} "
                f"[{response.status_code}] - {duration:.3f}s"
            )
        return response


class TimezoneMiddleware(MiddlewareMixin):
    """Set timezone based on user preferences"""

    def process_request(self, request):
        # This is a placeholder - implement based on your user model
        # You can get timezone from user profile or request headers
        pass
