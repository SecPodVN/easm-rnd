#!/bin/bash

# # Wait for postgres
# echo "Waiting for PostgreSQL..."
# while ! nc -z $POSTGRES_HOST ${POSTGRES_PORT:-5432}; do
#   sleep 0.1
# done
# echo "PostgreSQL started"

# # Wait for redis
# echo "Waiting for Redis..."
# while ! nc -z $REDIS_HOST ${REDIS_PORT:-6379}; do
#   sleep 0.1
# done
# echo "Redis started"

# Run migrations
echo "Running database migrations..."
python manage.py migrate --noinput

# Collect static files
echo "Collecting static files..."
python manage.py collectstatic --noinput

# Create superuser if it doesn't exist
echo "Creating superuser..."
python manage.py shell << END
from django.contrib.auth import get_user_model
User = get_user_model()
if not User.objects.filter(username='admin').exists():
    User.objects.create_superuser('admin', 'admin@example.com', 'admin123')
    print('Superuser created')
else:
    print('Superuser already exists')
END

# Start Gunicorn
echo "Starting Gunicorn..."
exec gunicorn config.wsgi:application \
    --bind 0.0.0.0:8000 \
    --workers ${GUNICORN_WORKERS:-4} \
    --reload \
    --access-logfile - \
    --error-logfile - \
    --log-level info
