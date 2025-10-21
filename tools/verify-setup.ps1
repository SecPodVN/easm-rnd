# Setup Verification Script for EASM Django REST API
# This script checks if all required components are properly configured

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "EASM Django REST API - Setup Verification" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$errors = @()
$warnings = @()

# Check Python
Write-Host "Checking Python..." -ForegroundColor Yellow
try {
    $pythonVersion = python --version 2>&1
    if ($pythonVersion -match "Python 3\.1[3-9]") {
        Write-Host "✓ Python 3.13+ found: $pythonVersion" -ForegroundColor Green
    } else {
        $errors += "Python 3.13+ required, found: $pythonVersion"
        Write-Host "✗ Python 3.13+ required, found: $pythonVersion" -ForegroundColor Red
    }
} catch {
    $errors += "Python not found in PATH"
    Write-Host "✗ Python not found" -ForegroundColor Red
}

# Check Poetry
Write-Host "Checking Poetry..." -ForegroundColor Yellow
try {
    $poetryVersion = poetry --version 2>&1
    Write-Host "✓ Poetry found: $poetryVersion" -ForegroundColor Green
} catch {
    $warnings += "Poetry not found - install with: (Invoke-WebRequest -Uri https://install.python-poetry.org -UseBasicParsing).Content | python -"
    Write-Host "⚠ Poetry not found (optional)" -ForegroundColor Yellow
}

# Check Docker
Write-Host "Checking Docker..." -ForegroundColor Yellow
try {
    $dockerVersion = docker --version 2>&1
    Write-Host "✓ Docker found: $dockerVersion" -ForegroundColor Green
} catch {
    $errors += "Docker not found"
    Write-Host "✗ Docker not found" -ForegroundColor Red
}

# Check Docker Compose
Write-Host "Checking Docker Compose..." -ForegroundColor Yellow
try {
    $composeVersion = docker-compose --version 2>&1
    Write-Host "✓ Docker Compose found: $composeVersion" -ForegroundColor Green
} catch {
    $errors += "Docker Compose not found"
    Write-Host "✗ Docker Compose not found" -ForegroundColor Red
}

# Check kubectl (optional)
Write-Host "Checking kubectl..." -ForegroundColor Yellow
try {
    $kubectlVersion = kubectl version --client --short 2>&1
    Write-Host "✓ kubectl found: $kubectlVersion" -ForegroundColor Green
} catch {
    $warnings += "kubectl not found (optional for Kubernetes deployment)"
    Write-Host "⚠ kubectl not found (optional)" -ForegroundColor Yellow
}

# Check Minikube (optional)
Write-Host "Checking Minikube..." -ForegroundColor Yellow
try {
    $minikubeVersion = minikube version --short 2>&1
    Write-Host "✓ Minikube found: $minikubeVersion" -ForegroundColor Green
} catch {
    $warnings += "Minikube not found (optional for local Kubernetes)"
    Write-Host "⚠ Minikube not found (optional)" -ForegroundColor Yellow
}

# Check Helm (optional)
Write-Host "Checking Helm..." -ForegroundColor Yellow
try {
    $helmVersion = helm version --short 2>&1
    Write-Host "✓ Helm found: $helmVersion" -ForegroundColor Green
} catch {
    $warnings += "Helm not found (optional for Kubernetes deployment)"
    Write-Host "⚠ Helm not found (optional)" -ForegroundColor Yellow
}

# Check Skaffold (optional)
Write-Host "Checking Skaffold..." -ForegroundColor Yellow
try {
    $skaffoldVersion = skaffold version 2>&1
    Write-Host "✓ Skaffold found: $skaffoldVersion" -ForegroundColor Green
} catch {
    $warnings += "Skaffold not found (optional for development workflow)"
    Write-Host "⚠ Skaffold not found (optional)" -ForegroundColor Yellow
}

# Check project files
Write-Host ""
Write-Host "Checking project files..." -ForegroundColor Yellow

$requiredFiles = @(
    "pyproject.toml",
    "docker-compose.yml",
    "Dockerfile",
    "manage.py",
    ".env.example",
    "src/backend/easm/settings.py",
    "todos/models.py",
    "charts/easm-api/Chart.yaml"
)

foreach ($file in $requiredFiles) {
    if (Test-Path $file) {
        Write-Host "✓ $file exists" -ForegroundColor Green
    } else {
        $errors += "Required file missing: $file"
        Write-Host "✗ $file missing" -ForegroundColor Red
    }
}

# Check .env file
Write-Host ""
Write-Host "Checking environment configuration..." -ForegroundColor Yellow
if (Test-Path ".env") {
    Write-Host "✓ .env file exists" -ForegroundColor Green
} else {
    $warnings += ".env file not found - copy from .env.example"
    Write-Host "⚠ .env file not found - copy from .env.example" -ForegroundColor Yellow
}

# Check Docker daemon
Write-Host ""
Write-Host "Checking Docker daemon..." -ForegroundColor Yellow
try {
    docker ps > $null 2>&1
    Write-Host "✓ Docker daemon is running" -ForegroundColor Green
} catch {
    $warnings += "Docker daemon is not running - start Docker Desktop"
    Write-Host "⚠ Docker daemon is not running" -ForegroundColor Yellow
}

# Summary
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

if ($errors.Count -eq 0) {
    Write-Host "✓ All required components are installed!" -ForegroundColor Green
} else {
    Write-Host "✗ Found $($errors.Count) error(s):" -ForegroundColor Red
    foreach ($error in $errors) {
        Write-Host "  - $error" -ForegroundColor Red
    }
}

if ($warnings.Count -gt 0) {
    Write-Host ""
    Write-Host "⚠ Found $($warnings.Count) warning(s):" -ForegroundColor Yellow
    foreach ($warning in $warnings) {
        Write-Host "  - $warning" -ForegroundColor Yellow
    }
}

Write-Host ""
if ($errors.Count -eq 0) {
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "✓ Setup verification passed!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "1. Copy .env.example to .env: Copy-Item .env.example .env" -ForegroundColor White
    Write-Host "2. Start services: docker-compose up --build -d" -ForegroundColor White
    Write-Host "3. Run migrations: docker-compose exec web python manage.py migrate" -ForegroundColor White
    Write-Host "4. Create superuser: docker-compose exec web python manage.py createsuperuser" -ForegroundColor White
    Write-Host "5. Access API: http://localhost:8000/api/docs/" -ForegroundColor White
    Write-Host ""
    Write-Host "For detailed instructions, see QUICKSTART.md" -ForegroundColor Cyan
} else {
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "✗ Setup verification failed!" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please install missing components and try again." -ForegroundColor Red
}
