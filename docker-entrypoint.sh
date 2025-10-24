#!/usr/bin/env bash
set -e

# Wait for PostgreSQL
echo "Waiting for PostgreSQL at ${POSTGRES_HOST:-localhost}:${POSTGRES_PORT:-5432}..."
timeout=30
count=0
until nc -z "${POSTGRES_HOST:-localhost}" "${POSTGRES_PORT:-5432}" 2>/dev/null || [ $count -eq $timeout ]; do
  count=$((count + 1))
  sleep 1
done

if [ $count -eq $timeout ]; then
  echo "WARNING: PostgreSQL not available after ${timeout}s, continuing anyway..."
else
  echo "PostgreSQL is ready!"
fi

# Wait for Redis
echo "Waiting for Redis at ${REDIS_HOST:-localhost}:${REDIS_PORT:-6379}..."
count=0
until nc -z "${REDIS_HOST:-localhost}" "${REDIS_PORT:-6379}" 2>/dev/null || [ $count -eq $timeout ]; do
  count=$((count + 1))
  sleep 1
done

if [ $count -eq $timeout ]; then
  echo "WARNING: Redis not available after ${timeout}s, continuing anyway..."
else
  echo "Redis is ready!"
fi

echo "Running migrations..."
python manage.py migrate --noinput

echo "Collecting static files..."
python manage.py collectstatic --noinput

echo "Starting server..."
exec "$@"
