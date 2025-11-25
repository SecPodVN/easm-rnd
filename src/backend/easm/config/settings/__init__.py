"""
Settings package initialization.
Loads appropriate settings based on DJANGO_ENV environment variable.
"""

import os
from decouple import config

# Determine which settings module to use
DJANGO_ENV = config('DJANGO_ENV', default='development')

if DJANGO_ENV == 'production':
    from .production import *
elif DJANGO_ENV == 'testing':
    from .testing import *
else:
    from .development import *
