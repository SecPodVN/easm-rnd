"""
Common enumerations
"""
from enum import Enum


class SeverityLevel(str, Enum):
    """Severity levels for vulnerabilities and issues"""
    CRITICAL = "CRITICAL"
    HIGH = "HIGH"
    MEDIUM = "MEDIUM"
    LOW = "LOW"
    INFO = "INFO"


class ScanStatus(str, Enum):
    """Status of scans"""
    PENDING = "PENDING"
    RUNNING = "RUNNING"
    COMPLETED = "COMPLETED"
    FAILED = "FAILED"
    CANCELLED = "CANCELLED"


class ResourceType(str, Enum):
    """Types of resources"""
    DOMAIN = "DOMAIN"
    SUBDOMAIN = "SUBDOMAIN"
    IP_ADDRESS = "IP_ADDRESS"
    URL = "URL"
    PORT = "PORT"
    SERVICE = "SERVICE"


class UserRole(str, Enum):
    """User roles"""
    ADMIN = "ADMIN"
    MANAGER = "MANAGER"
    ANALYST = "ANALYST"
    VIEWER = "VIEWER"


class Priority(str, Enum):
    """Priority levels"""
    LOW = "LOW"
    MEDIUM = "MEDIUM"
    HIGH = "HIGH"
    URGENT = "URGENT"


class TodoStatus(str, Enum):
    """Todo item status"""
    PENDING = "pending"
    IN_PROGRESS = "in_progress"
    COMPLETED = "completed"


class TodoPriority(str, Enum):
    """Todo item priority"""
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"
