#!/bin/bash

set -e

echo "Waiting for postgres..."
while ! nc -z $POSTGRES_HOST ${POSTGRES_PORT:-5432}; do
  sleep 0.1
done
echo "PostgreSQL started"

echo "Waiting for redis..."
while ! nc -z $REDIS_HOST ${REDIS_PORT:-6379}; do
  sleep 0.1
done
echo "Redis started"

echo "Starting server..."
exec "$@"
