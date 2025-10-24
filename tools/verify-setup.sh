#!/usr/bin/env bash
# Setup Verification Script for EASM Django REST API
# This script checks if all required components are properly configured
# Compatible with Linux, macOS, and WSL

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

errors=0
warnings=0

echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}EASM Django REST API - Setup Verification${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

# Check Python
echo -e "${YELLOW}Checking Python...${NC}"
if command -v python3 &> /dev/null; then
  python_version=$(python3 --version 2>&1)
  if [[ $python_version =~ Python\ 3\.1[3-9] ]]; then
    echo -e "${GREEN}✓ Python 3.13+ found: $python_version${NC}"
  else
    echo -e "${RED}✗ Python 3.13+ required, found: $python_version${NC}"
    ((errors++))
  fi
else
  echo -e "${RED}✗ Python not found${NC}"
  ((errors++))
fi

# Check Poetry
echo -e "${YELLOW}Checking Poetry...${NC}"
if command -v poetry &> /dev/null; then
  poetry_version=$(poetry --version 2>&1)
  echo -e "${GREEN}✓ Poetry found: $poetry_version${NC}"
else
  echo -e "${YELLOW}⚠ Poetry not found (optional)${NC}"
  echo -e "${YELLOW}  Install with: curl -sSL https://install.python-poetry.org | python3 -${NC}"
  ((warnings++))
fi

# Check Docker
echo -e "${YELLOW}Checking Docker...${NC}"
if command -v docker &> /dev/null; then
  docker_version=$(docker --version 2>&1)
  echo -e "${GREEN}✓ Docker found: $docker_version${NC}"
else
  echo -e "${RED}✗ Docker not found${NC}"
  ((errors++))
fi

# Check Docker Compose
echo -e "${YELLOW}Checking Docker Compose...${NC}"
if docker compose version &> /dev/null; then
  compose_version=$(docker compose version 2>&1)
  echo -e "${GREEN}✓ Docker Compose found: $compose_version${NC}"
elif command -v docker-compose &> /dev/null; then
  compose_version=$(docker-compose --version 2>&1)
  echo -e "${GREEN}✓ Docker Compose found: $compose_version${NC}"
else
  echo -e "${RED}✗ Docker Compose not found${NC}"
  ((errors++))
fi

# Check kubectl
echo -e "${YELLOW}Checking kubectl...${NC}"
if command -v kubectl &> /dev/null; then
  kubectl_version=$(kubectl version --client --short 2>&1 | head -n1)
  echo -e "${GREEN}✓ kubectl found: $kubectl_version${NC}"
else
  echo -e "${YELLOW}⚠ kubectl not found (optional for Kubernetes deployment)${NC}"
  ((warnings++))
fi

# Check Helm
echo -e "${YELLOW}Checking Helm...${NC}"
if command -v helm &> /dev/null; then
  helm_version=$(helm version --short 2>&1)
  echo -e "${GREEN}✓ Helm found: $helm_version${NC}"
else
  echo -e "${YELLOW}⚠ Helm not found (optional for Kubernetes deployment)${NC}"
  ((warnings++))
fi

# Check Skaffold
echo -e "${YELLOW}Checking Skaffold...${NC}"
if command -v skaffold &> /dev/null; then
  skaffold_version=$(skaffold version 2>&1)
  echo -e "${GREEN}✓ Skaffold found: $skaffold_version${NC}"
else
  echo -e "${YELLOW}⚠ Skaffold not found (optional for Kubernetes deployment)${NC}"
  ((warnings++))
fi

# Check Node.js
echo -e "${YELLOW}Checking Node.js...${NC}"
if command -v node &> /dev/null; then
  node_version=$(node --version 2>&1)
  echo -e "${GREEN}✓ Node.js found: $node_version${NC}"
else
  echo -e "${YELLOW}⚠ Node.js not found (optional for React development)${NC}"
  ((warnings++))
fi

# Check npm
echo -e "${YELLOW}Checking npm...${NC}"
if command -v npm &> /dev/null; then
  npm_version=$(npm --version 2>&1)
  echo -e "${GREEN}✓ npm found: v$npm_version${NC}"
else
  echo -e "${YELLOW}⚠ npm not found (optional for React development)${NC}"
  ((warnings++))
fi

# Check Git
echo -e "${YELLOW}Checking Git...${NC}"
if command -v git &> /dev/null; then
  git_version=$(git --version 2>&1)
  echo -e "${GREEN}✓ Git found: $git_version${NC}"
else
  echo -e "${YELLOW}⚠ Git not found${NC}"
  ((warnings++))
fi

# Check required files
echo ""
echo -e "${YELLOW}Checking required files...${NC}"
required_files=(
  "pyproject.toml"
  "docker-compose.yml"
  "Dockerfile"
  "manage.py"
  ".env.example"
  "skaffold.yaml"
)

for file in "${required_files[@]}"; do
  if [ -f "$file" ]; then
    echo -e "${GREEN}✓ $file exists${NC}"
  else
    echo -e "${RED}✗ $file missing${NC}"
    ((errors++))
  fi
done

# Check .env file
echo ""
echo -e "${YELLOW}Checking environment configuration...${NC}"
if [ -f ".env" ]; then
  echo -e "${GREEN}✓ .env file exists${NC}"
else
  echo -e "${YELLOW}⚠ .env file not found - copy from .env.example${NC}"
  ((warnings++))
fi

# Check Docker daemon
echo ""
echo -e "${YELLOW}Checking Docker daemon...${NC}"
if docker ps &> /dev/null; then
  echo -e "${GREEN}✓ Docker daemon is running${NC}"
else
  echo -e "${YELLOW}⚠ Docker daemon is not running${NC}"
  ((warnings++))
fi

# Check Kubernetes cluster
echo ""
echo -e "${YELLOW}Checking Kubernetes cluster...${NC}"
if command -v kubectl &> /dev/null && kubectl cluster-info &> /dev/null; then
  cluster_info=$(kubectl config current-context 2>&1)
  echo -e "${GREEN}✓ Kubernetes cluster is accessible: $cluster_info${NC}"
else
  echo -e "${YELLOW}⚠ Kubernetes cluster not accessible (optional)${NC}"
  ((warnings++))
fi

# Summary
echo ""
echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}Summary${NC}"
echo -e "${CYAN}========================================${NC}"

if [ $errors -eq 0 ]; then
  echo -e "${GREEN}✓ All required components are installed!${NC}"
else
  echo -e "${RED}✗ Found $errors error(s)${NC}"
fi

if [ $warnings -gt 0 ]; then
  echo ""
  echo -e "${YELLOW}⚠ Found $warnings warning(s)${NC}"
fi

echo ""
if [ $errors -eq 0 ]; then
  echo -e "${GREEN}========================================${NC}"
  echo -e "${GREEN}✓ Setup verification passed!${NC}"
  echo -e "${GREEN}========================================${NC}"
  echo ""
  echo -e "${CYAN}Next steps:${NC}"
  echo "1. Copy .env.example to .env: cp .env.example .env"
  echo "2. Edit .env file with your configuration"
  echo "3. Start services: docker-compose up --build -d"
  echo "4. Run migrations: docker-compose exec web python manage.py migrate"
  echo "5. Create superuser: docker-compose exec web python manage.py createsuperuser"
  echo "6. Access API: http://localhost:8000/api/docs/"
  echo ""
  echo -e "${CYAN}For Kubernetes/Skaffold deployment:${NC}"
  echo "1. Run: ./skaffold.sh"
  echo ""
  echo -e "${CYAN}For detailed instructions, see QUICKSTART.md${NC}"
else
  echo -e "${RED}========================================${NC}"
  echo -e "${RED}✗ Setup verification failed!${NC}"
  echo -e "${RED}========================================${NC}"
  echo ""
  echo -e "${CYAN}Please install missing components and try again.${NC}"
  exit 1
fi
