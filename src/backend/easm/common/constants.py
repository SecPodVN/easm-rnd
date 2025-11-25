"""
Common constants
"""

# API
API_VERSION = "1.0.0"
API_TITLE = "EASM API"
API_DESCRIPTION = "External Attack Surface Management API"

# Pagination
DEFAULT_PAGE_SIZE = 10
MAX_PAGE_SIZE = 100

# Rate Limiting
DEFAULT_RATE_LIMIT = "100/hour"
ANONYMOUS_RATE_LIMIT = "20/hour"

# Cache
CACHE_TTL_SHORT = 60  # 1 minute
CACHE_TTL_MEDIUM = 300  # 5 minutes
CACHE_TTL_LONG = 3600  # 1 hour
CACHE_TTL_VERY_LONG = 86400  # 24 hours

# Security
PASSWORD_MIN_LENGTH = 8
MAX_LOGIN_ATTEMPTS = 5
LOGIN_LOCKOUT_DURATION = 900  # 15 minutes

# File Upload
MAX_UPLOAD_SIZE = 10 * 1024 * 1024  # 10MB
ALLOWED_UPLOAD_EXTENSIONS = ['.pdf', '.csv', '.xlsx', '.json', '.txt']

# Date/Time
DEFAULT_TIMEZONE = 'UTC'
DATE_FORMAT = '%Y-%m-%d'
DATETIME_FORMAT = '%Y-%m-%d %H:%M:%S'
ISO_DATETIME_FORMAT = '%Y-%m-%dT%H:%M:%SZ'

# Regex Patterns
IP_REGEX = r'^(\d{1,3}\.){3}\d{1,3}$'
DOMAIN_REGEX = r'^(?:[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}$'
URL_REGEX = r'^https?://(?:www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b(?:[-a-zA-Z0-9()@:%_\+.~#?&/=]*)$'

# HTTP Status Messages
HTTP_200_MESSAGE = "Success"
HTTP_201_MESSAGE = "Created successfully"
HTTP_204_MESSAGE = "Deleted successfully"
HTTP_400_MESSAGE = "Bad request"
HTTP_401_MESSAGE = "Unauthorized"
HTTP_403_MESSAGE = "Forbidden"
HTTP_404_MESSAGE = "Not found"
HTTP_500_MESSAGE = "Internal server error"
