"""
Celery configuration for EASM project.
"""

import os
from celery import Celery
from decouple import config

# Set the default Django settings module for the 'celery' program.
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')

app = Celery('easm')

# Using a string here means the worker doesn't have to serialize
# the configuration object to child processes.
# - namespace='CELERY' means all celery-related configuration keys
#   should have a `CELERY_` prefix.
app.config_from_object('django.conf:settings', namespace='CELERY')

# Load task modules from all registered Django apps.
app.autodiscover_tasks()

# Celery Beat Schedule (for periodic tasks)
app.conf.beat_schedule = {
    # Example periodic task
    # 'example-task': {
    #     'task': 'easm.example.tasks.example_periodic_task',
    #     'schedule': crontab(minute=0, hour='*/1'),  # Every hour
    # },
}

# Celery Configuration
app.conf.update(
    broker_url=f"redis://{config('REDIS_HOST', default='localhost')}:{config('REDIS_PORT', default='6379')}/{config('CELERY_BROKER_DB', default='1')}",
    result_backend=f"redis://{config('REDIS_HOST', default='localhost')}:{config('REDIS_PORT', default='6379')}/{config('CELERY_RESULT_DB', default='2')}",
    task_serializer='json',
    accept_content=['json'],
    result_serializer='json',
    timezone='UTC',
    enable_utc=True,
    task_track_started=True,
    task_time_limit=30 * 60,  # 30 minutes
    task_soft_time_limit=25 * 60,  # 25 minutes
)


@app.task(bind=True, ignore_result=True)
def debug_task(self):
    """Debug task for testing Celery configuration."""
    print(f'Request: {self.request!r}')
