#!/usr/bin/env bash
set -e

# Wait for PostgreSQL
echo "Waiting for PostgreSQL at ${POSTGRES_HOST:-localhost}:${POSTGRES_PORT:-5432}..."
timeout=30
count=0
until nc -z "${POSTGRES_HOST:-localhost}" "${POSTGRES_PORT:-5432}" 2>/dev/null || [ $count -eq $timeout ]; do
  count=$((count + 1))
  echo "  Attempt $count/$timeout..."
  sleep 1
done

if [ $count -eq $timeout ]; then
  echo "ERROR: PostgreSQL not available after ${timeout}s"
  exit 1
fi
echo "PostgreSQL is ready!"

# Wait for Redis
echo "Waiting for Redis at ${REDIS_HOST:-localhost}:${REDIS_PORT:-6379}..."
count=0
until nc -z "${REDIS_HOST:-localhost}" "${REDIS_PORT:-6379}" 2>/dev/null || [ $count -eq $timeout ]; do
  count=$((count + 1))
  echo "  Attempt $count/$timeout..."
  sleep 1
done

if [ $count -eq $timeout ]; then
  echo "ERROR: Redis not available after ${timeout}s"
  exit 1
fi
echo "Redis is ready!"

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
