# Environment Configuration

This project now uses environment variables loaded from a `.env` file for both Docker Compose and Kubernetes/Skaffold deployments.

## Quick Setup

1. **Copy the example environment file:**
   ```bash
   cp .env.example .env
   ```

2. **Edit `.env` file with your values:**
   - Update `SECRET_KEY` for production
   - Set secure `POSTGRES_PASSWORD`
   - Adjust other settings as needed

## Usage

### Docker Compose
```bash
docker compose up
```
Set environment variables for Docker Compose:
- `POSTGRES_HOST=postgres`
- `REDIS_HOST=redis`

### Kubernetes/Skaffold
```bash
# Windows PowerShell
.\start-skaffold.ps1

# Linux/Mac bash
./start-skaffold.sh
```
Set environment variables for Kubernetes:
- `POSTGRES_HOST=postgresql`
- `REDIS_HOST=redis-master`
- `K8S_NAMESPACE=easm-rnd`

## Environment Variables

### Core Django Settings
- `DEBUG`: Enable/disable debug mode
- `SECRET_KEY`: Django secret key (change for production)
- `ALLOWED_HOSTS`: Comma-separated list of allowed hosts

### Database Configuration
- `POSTGRES_DB`: Database name
- `POSTGRES_USER`: Database username
- `POSTGRES_PASSWORD`: Database password
- `POSTGRES_HOST`: Database host
  - For Docker Compose: `postgres`
  - For Kubernetes: `postgresql`
  - For local development: `localhost`
- `POSTGRES_PORT`: Database port (default: `5432`)

### Redis Configuration
- `REDIS_HOST`: Redis host
  - For Docker Compose: `redis`
  - For Kubernetes: `redis-master`
  - For local development: `localhost`
- `REDIS_PORT`: Redis port (default: `6379`)
- `REDIS_DB`: Redis database number (default: `0`)

### Application Version
- `API_APP_VERSION`: Application version for tracking deployments (e.g., `0.1.0`, `1.2.3`)

### Docker Image Configuration
- `API_IMAGE`: Docker image name/repository (`easm-api`)
- `API_IMAGE_TAG`: Docker image tag (`latest`, `v1.0.0`, commit SHA, etc.)

### Kubernetes Settings
- `K8S_NAMESPACE`: Kubernetes namespace (`easm-rnd`)
- `K8S_REPLICA_COUNT`: Number of API pod replicas

## Scripts

- `skaffold-dev.ps1`: PowerShell script that loads `.env` and runs skaffold
- `skaffold-dev.sh`: Bash script that loads `.env` and runs skaffold

These scripts automatically load environment variables from `.env` file before running skaffold commands.
