"""
Common validators
"""
from django.core.exceptions import ValidationError
import re


def validate_ip_address(value):
    """Validate IPv4 or IPv6 address"""
    ipv4_pattern = r'^(\d{1,3}\.){3}\d{1,3}$'
    ipv6_pattern = r'^([0-9a-fA-F]{0,4}:){7}[0-9a-fA-F]{0,4}$'

    if not (re.match(ipv4_pattern, value) or re.match(ipv6_pattern, value)):
        raise ValidationError(f'{value} is not a valid IP address')

    # Additional IPv4 validation
    if re.match(ipv4_pattern, value):
        parts = [int(part) for part in value.split('.')]
        if any(part > 255 for part in parts):
            raise ValidationError(f'{value} is not a valid IPv4 address')


def validate_domain(value):
    """Validate domain name"""
    domain_pattern = r'^(?:[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}$'
    if not re.match(domain_pattern, value):
        raise ValidationError(f'{value} is not a valid domain name')


def validate_port(value):
    """Validate port number"""
    if not (0 <= value <= 65535):
        raise ValidationError(f'{value} is not a valid port number (0-65535)')


def validate_url(value):
    """Validate URL"""
    url_pattern = r'^https?://(?:www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b(?:[-a-zA-Z0-9()@:%_\+.~#?&/=]*)$'
    if not re.match(url_pattern, value):
        raise ValidationError(f'{value} is not a valid URL')
