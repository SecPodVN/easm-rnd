#!/bin/bash
# Skaffold Dev Helper - Loads ports from skaffold.env
# Usage: ./skdev.sh [additional skaffold arguments]

set -e

echo "🚀 Starting Skaffold with environment-based port forwarding..."
echo ""

# Load environment variables from skaffold.env
if [ -f "skaffold.env" ]; then
    echo "📝 Loading environment from skaffold.env..."
    set -a
    source skaffold.env
    set +a
else
    echo "⚠️  Warning: skaffold.env not found, using default ports"
fi

# Get port values from environment or use defaults
API_PORT="${API_LOCAL_PORT:-8000}"
POSTGRES_PORT="${POSTGRES_LOCAL_PORT:-5432}"
REDIS_PORT="${REDIS_LOCAL_PORT:-6379}"

echo "🔌 Port Forwarding Configuration:"
echo "   API:        localhost:$API_PORT → container:8000"
echo "   PostgreSQL: localhost:$POSTGRES_PORT → container:5432"
echo "   Redis:      localhost:$REDIS_PORT → container:6379"
echo ""

# Build port forwarding argument
PORT_FORWARD_PORTS="${API_PORT}:8000,${POSTGRES_PORT}:5432,${REDIS_PORT}:6379"

echo "▶️  Running: skaffold dev --port-forward-ports=$PORT_FORWARD_PORTS $@"
echo ""

# Execute Skaffold
exec skaffold dev --port-forward-ports="$PORT_FORWARD_PORTS" "$@"
