from django.apps import AppConfig


class ExampleConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'easm.apps.example'
    verbose_name = 'Example Domain App'
