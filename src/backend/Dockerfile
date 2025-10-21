# Use Python 3.13 slim image
FROM python:3.13-slim

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    POETRY_VERSION=2.2.0 \
    POETRY_HOME="/opt/poetry" \
    POETRY_NO_INTERACTION=1 \
    POETRY_VIRTUALENVS_CREATE=false \
    APP_HOME=/app

# Set work directory
WORKDIR $APP_HOME

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    postgresql-client \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Poetry
RUN pip install "poetry==$POETRY_VERSION"

# Copy poetry files
COPY pyproject.toml poetry.lock* ./

# Install dependencies (without dev dependencies)
RUN poetry install

# Copy startup scripts
COPY ./*.sh "$APP_HOME/"

# Copy project files
COPY . .

# Create staticfiles directory
RUN mkdir -p staticfiles

# Make scripts executable
RUN chmod +x "$APP_HOME/docker-entrypoint.sh" "$APP_HOME/start-api.sh"

# Expose port
EXPOSE 8000

# Set entrypoint
# ENTRYPOINT ["/app/docker-entrypoint.sh"]
