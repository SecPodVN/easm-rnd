from django.apps import AppConfig


class AuthConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'easm.auth'
    label = 'easm_auth'  # Avoid conflict with django.contrib.auth
    verbose_name = 'Authentication'

    def ready(self):
        """Import signals when app is ready"""
        import easm.auth.signals  # noqa
