# Makefile for EASM Django REST API

.PHONY: help install migrate run test lint format clean docker-build docker-up docker-down k8s-deploy k8s-delete

help:
	@echo "Available commands:"
	@echo "  make install       - Install dependencies with Poetry"
	@echo "  make migrate       - Run database migrations"
	@echo "  make run           - Run development server"
	@echo "  make test          - Run tests"
	@echo "  make lint          - Run linters"
	@echo "  make format        - Format code with Black"
	@echo "  make clean         - Remove Python artifacts"
	@echo "  make docker-build  - Build Docker image"
	@echo "  make docker-up     - Start Docker Compose services"
	@echo "  make docker-down   - Stop Docker Compose services"
	@echo "  make k8s-deploy    - Deploy to Kubernetes"
	@echo "  make k8s-delete    - Delete from Kubernetes"

install:
	poetry install

migrate:
	poetry run python manage.py makemigrations
	poetry run python manage.py migrate

run:
	poetry run python manage.py runserver 0.0.0.0:8000

test:
	poetry run pytest

lint:
	poetry run flake8

format:
	poetry run black .

clean:
	find . -type d -name "__pycache__" -exec rm -rf {} +
	find . -type f -name "*.pyc" -delete
	find . -type f -name "*.pyo" -delete
	rm -rf .pytest_cache
	rm -rf htmlcov
	rm -rf .coverage

docker-build:
	docker build -t easm-api:latest .

docker-up:
	docker-compose up -d

docker-down:
	docker-compose down

docker-logs:
	docker-compose logs -f

k8s-deploy:
	kubectl apply -f k8s/deployment.yaml
	helm install easm-api ./charts/easm-api

k8s-delete:
	helm uninstall easm-api
	kubectl delete -f k8s/deployment.yaml

skaffold-dev:
	skaffold dev

skaffold-run:
	skaffold run

skaffold-delete:
	skaffold delete
