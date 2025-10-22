# Use Python 3.13 slim image
FROM python:3.13-slim

# Security: Add labels for metadata
LABEL maintainer="thinh.huynh@secpod.com" \
      version="1.0.0" \
      description="EASM Django REST API - Poetry Build" \
      security.scan="enabled"

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    POETRY_VERSION=2.2.0 \
    POETRY_HOME="/opt/poetry" \
    POETRY_NO_INTERACTION=1 \
    POETRY_VIRTUALENVS_CREATE=false \
    APP_HOME=/app \
    DJANGO_USER=django \
    DJANGO_UID=1000 \
    DJANGO_GID=1000 \
    PYTHONPATH=/app

# Set work directory
WORKDIR $APP_HOME

# Security: Create non-root user first with specific UID/GID
RUN groupadd -r -g "$DJANGO_GID" "$DJANGO_USER" && \
    useradd -r -u "$DJANGO_UID" -g "$DJANGO_USER" -s /sbin/nologin -d "$APP_HOME" "$DJANGO_USER"

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    gcc \
    libpq5 \
    libpq-dev \
    netcat-openbsd \
    postgresql-client \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/cache/apt/archives/*

# Install Poetry
RUN pip install "poetry==$POETRY_VERSION"

# Copy poetry files
COPY pyproject.toml poetry.lock* ./

# Install dependencies (without dev dependencies)
# POETRY_VIRTUALENVS_CREATE=false installs packages globally
RUN poetry install --no-root --without dev

# Copy startup scripts
COPY ./*.sh $APP_HOME/

# Copy project files
COPY . .

# Create necessary directories with proper permissions
RUN mkdir -p staticfiles media logs && \
    chmod +x "$APP_HOME/docker-entrypoint.sh" "$APP_HOME/start-api.sh" && \
    chmod 750 "$APP_HOME" && \
    chmod 755 staticfiles media && \
    chmod 750 logs && \
    find "$APP_HOME" -type f -name "*.py" -exec chmod 644 {} \; && \
    find "$APP_HOME" -type d -exec chmod 755 {} \; && \
    chown -R "$DJANGO_USER:$DJANGO_USER" "$APP_HOME"

# Security: Switch to non-root user
USER $DJANGO_USER

# Health check (disabled for now - requires requests in runtime)
# HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
#     CMD python -c "import requests; requests.get('http://localhost:8000/health/', timeout=5)" || exit 1

# Expose port
EXPOSE 8000

# Set entrypoint
# ENTRYPOINT ["/app/docker-entrypoint.sh"]
