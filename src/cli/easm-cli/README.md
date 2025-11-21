# EASM CLI - Complete Guide

A unified command-line interface for managing the EASM (External Attack Surface Management) project. This CLI provides a consistent interface for development, deployment, database operations, and more.

## 🎯 Features

- **Auto-detection**: Automatically detects whether to use Kubernetes or Docker Compose
- **Cross-platform**: Works on Windows, Linux, and macOS
- **Colored output**: Beautiful terminal output with semantic colors
- **Environment management**: Loads and validates `.env` configuration
- **Integrated workflows**: Seamlessly integrates with Skaffold, Minikube, and Docker Compose
- **Auto-start Minikube**: Automatically starts Minikube if Kubernetes is not running

## 📦 Installation

### Quick Start (No Installation Required)

```bash
# From project root
python src/cli/easm-src/cli/easm-cli/easm.py <command>

# Windows
python cli\easm.py <command>

# Example
python cli\easm.py dev start
python cli\easm.py --help
```

### Install Globally (Recommended)

**Windows PowerShell:**
```powershell
# Run the installer
.\cli\install.ps1

# The installer will:
# 1. Add CLI directory to your PATH (permanent)
# 2. Add 'easm' function to your PowerShell profile

# After installation, reload your profile:
. $PROFILE

# Now you can use:
easm dev start
easm --help

# OR open a new terminal window (automatically loads profile)

# Uninstall
.\cli\install.ps1 -Uninstall
```

**Alternative (Manual Setup for Windows):**
```powershell
# Add function to your PowerShell profile
Add-Content $PROFILE @"

# EASM CLI
function easm {
    python "$PWD\cli\easm.py" `$args
}
# End EASM CLI
"@

# Reload profile
. $PROFILE

# Test it
easm --version
```

**Linux/macOS:**
```bash
# Make installer executable and run
chmod +x cli/install.sh
./cli/install.sh

# After installation, restart terminal and use:
easm dev start
easm --help

# Uninstall
./cli/install.sh --uninstall
```

### Manual Installation Options

**Option 1: Use Batch Wrapper (No Installation)**
```powershell
# Windows - works immediately, no setup needed
.\cli\easm.bat dev start
.\cli\easm.bat --help

# Add to PATH for convenience (temporary, current session only)
$env:PATH += ";$PWD\cli"
easm.bat dev start
```

```bash
# Linux/macOS - works immediately
chmod +x cli/easm
./cli/easm dev start

# Add to PATH (temporary, current session only)
export PATH="$PATH:$PWD/cli"
easm dev start
```

**Option 2: Create Permanent Alias**
```powershell
# PowerShell: Add to your profile ($PROFILE)
function easm { python D:\Personal\EASM\easm-rnd\cli\easm.py $args }
```

```bash
# Bash/Zsh: Add to ~/.bashrc or ~/.zshrc
alias easm='python ~/easm-rnd/src/cli/easm-cli/easm.py'
```

## 📚 Command Reference

> **Note:** Replace `python src/cli/easm-src/cli/easm-cli/easm.py` with `easm` if you've installed globally.

### Development Commands (`dev`)

Manage your development environment with auto-detection of deployment mode.
```bash
# Start development environment
easm dev start                    # Auto-detect mode (k8s or compose)
easm dev start --mode k8s         # Force Kubernetes mode
easm dev start --mode compose     # Force Docker Compose mode
easm dev start --watch            # Enable auto-watch mode (restarts on .env changes)

# Stop services
easm dev stop                     # Stops all services AND kills Skaffold processes

# Restart services
easm dev restart                  # Stop then start

# View logs
easm dev logs                     # Show all logs
easm dev logs api                 # Show API logs only
easm dev logs api -f              # Follow API logs in real-time
easm dev logs --tail 100          # Show last 100 lines

# Access container/pod shell
easm dev shell api                # Open shell in API container
easm dev shell postgres           # Open shell in Postgres container

# Cleanup operations
easm dev clean                    # Remove __pycache__, .pyc, .log files
easm dev reset --confirm          # Full reset (stops services, cleans, removes volumes)

# Watch mode (development)
easm dev watch                    # Start watch mode for .env changes
```

**What `dev start` does:**
1. Checks if `.env` file exists
2. Detects deployment mode:
   - **Auto mode (default)**: Checks if `kubectl` is installed
     - If `kubectl` found → **k8s mode** (runs `skaffold.ps1` which auto-starts Minikube if needed)
     - If `kubectl` not found → **compose mode** (runs `docker-compose`)
   - **Forced mode**: Use `--mode k8s` or `--mode compose` to override
3. **Kubernetes mode (`skaffold.ps1`)**:
   - Automatically starts Minikube if not running
   - Waits for cluster to be ready (up to 60 seconds)
   - Runs Skaffold in development mode
4. **Compose mode**:
   - Runs `docker-compose up -d`

**Important**: If you have `kubectl` installed, it will **always** try to use Kubernetes mode and auto-start Minikube. Use `--mode compose` to force Docker Compose.

### Database Commands (`db`)
```bash
# Run Django migrations
easm db migrate                   # Apply all pending migrations
easm db migrate --app todos       # Migrate specific app

# Create migrations
easm db makemigrations            # Create new migration files

# Seed database with test data
easm db seed                      # Full seed with sample data
easm db seed --quick              # Quick seed (minimal data)

# Clear data
easm db clear                     # Clear seed data only
easm db clear --all               # Clear all data (dangerous!)

# Database shell
easm db shell                     # Open Django DB shell
easm db shell --raw               # Open raw psql/mongo shell

# Database info
easm db info                      # Show database connection info
```

**Status:** ⏳ Stub (not yet implemented)

### Configuration Commands (`config`)
```bash
# Initialize environment file
easm config init                  # Create .env from .env.example
easm config init --force          # Overwrite existing .env

# Validate configuration
easm config validate              # Check for required variables
easm config validate --strict     # Strict validation with warnings

# View configuration
easm config show                  # Show all config (redacts secrets)
easm config show --no-redact      # Show including secrets

# Modify configuration
easm config set DEBUG=True        # Set a single value
easm config set PORT=8080         # Set port
easm config get DEBUG             # Get a specific value

# Configuration templates
easm config templates             # List available templates
easm config use dev               # Use development template
easm config use prod              # Use production template
```

**Status:** ⏳ Stub (not yet implemented)

### Deployment Commands (`deploy`)
```bash
# Deploy application
easm deploy start                 # Deploy to configured environment
easm deploy start --mode prod     # Deploy to production
easm deploy start --mode staging  # Deploy to staging

# Check deployment status
easm deploy status                # Show deployment status
easm deploy health                # Run health checks

# Manage deployments
easm deploy stop                  # Stop deployment
easm deploy rollback              # Rollback to previous version
easm deploy logs                  # View deployment logs

# Build and push images
easm deploy build                 # Build Docker images
easm deploy push                  # Push to registry
```

**Status:** ⏳ Stub (not yet implemented)

### Kubernetes Commands (`k8s`)
```bash
# Minikube management
easm k8s start                    # Start Minikube cluster
easm k8s start --cpus 4           # Start with custom resources
easm k8s start --memory 8192
easm k8s stop                     # Stop Minikube
easm k8s delete                   # Delete Minikube cluster

# Cluster information
easm k8s status                   # Check cluster status
easm k8s info                     # Detailed cluster info
easm k8s dashboard                # Open Kubernetes dashboard

# Resource management
easm k8s pods                     # List all pods
easm k8s pods -n easm-rnd         # List pods in namespace
easm k8s services                 # List all services
easm k8s deployments              # List deployments
easm k8s logs <pod-name>          # View pod logs

# Port forwarding
easm k8s forward api 8000:8000    # Forward port to service
easm k8s tunnel                   # Start Minikube tunnel

# Context and namespaces
easm k8s context                  # Show current context
easm k8s use-context minikube     # Switch context
```

**Status:** ⏳ Stub (not yet implemented)

### Scanner Commands (`scan`)
```bash
# List scans
easm scan list                    # List all scans
easm scan list --active           # Show only active scans
easm scan list --completed        # Show completed scans

# Create new scan
easm scan create subdomain        # Create subdomain scan
easm scan create port             # Create port scan
easm scan create --target example.com

# Manage scans
easm scan run <scan-id>           # Run a specific scan
easm scan stop <scan-id>          # Stop running scan
easm scan delete <scan-id>        # Delete scan

# View scan results
easm scan status <scan-id>        # Check scan status
easm scan results <scan-id>       # View scan results
easm scan export <scan-id>        # Export results to file

# Scan templates
easm scan templates               # List available templates
easm scan create --template quick # Use template
```

**Status:** ⏳ Stub (not yet implemented)

### Docker Commands (`docker`)
```bash
# Build Docker images
easm docker build                 # Build all images
easm docker build api             # Build specific service
easm docker build --no-cache      # Build without cache

# Container management
easm docker ps                    # List running containers
easm docker ps -a                 # List all containers
easm docker stop <service>        # Stop container
easm docker restart <service>     # Restart container

# View logs
easm docker logs api              # View API logs
easm docker logs api -f           # Follow logs
easm docker logs api --tail 100   # Last 100 lines

# Execute commands
easm docker exec api bash         # Open bash in container
easm docker exec api "ls -la"     # Run command

# Cleanup operations
easm docker clean                 # Remove stopped containers
easm docker clean --images        # Remove unused images
easm docker clean --volumes       # Remove unused volumes
easm docker clean --all           # Full cleanup (dangerous!)

# Docker Compose operations
easm docker up                    # Start services with compose
easm docker down                  # Stop and remove containers
easm docker down --volumes        # Also remove volumes
```

**Status:** ⏳ Stub (not yet implemented)

## 📊 Implementation Status

✅ **Implemented Commands:**
- `dev start` - Fully functional with auto-detection and watch mode
- `dev stop` - Stops both k8s and compose services
- `dev clean` - Cleans temporary files
- `dev reset` - Full reset with confirmation

⏳ **Stub Commands (show "not yet implemented"):**
- All other commands are defined but need implementation

## 🚀 Common Workflows

### First Time Setup

```bash
# 1. Clone and setup
git clone <repo-url>
cd easm-rnd
cp .env.example .env

# 2. Install CLI (optional)
.\cli\install.ps1        # Windows
./cli/install.sh         # Linux/macOS

# 3. Start development
easm dev start

# 4. Access services
# API:      http://localhost:8000
# Frontend: http://localhost:3000
# Admin:    http://localhost:8000/admin
```

### Daily Development

```bash
# Terminal 1: Start services (runs Skaffold in foreground)
easm dev start

# The Skaffold process will keep running and watching for changes
# You can either:
# - Press Ctrl+C in this terminal to stop Skaffold manually, OR
# - Run 'easm dev stop' from another terminal (will kill all processes)

# Terminal 2: Watch logs
easm dev logs api -f

# Terminal 3: Development work
easm dev shell api
# or
easm db migrate
easm db seed --quick

# To stop everything from any terminal:
easm dev stop
# This will delete Kubernetes resources AND kill all Skaffold processes
```

### Debugging

```bash
# View all logs
easm dev logs -f

# Check specific service
easm dev logs postgres
easm dev logs redis

# Shell into container
easm dev shell api
> python manage.py shell

# Check Kubernetes
easm k8s status
easm k8s pods
easm k8s services
```

### Cleanup and Reset

```bash
# Clean temporary files only
easm dev clean

# Stop services (keeps data)
easm dev stop

# Full reset (removes everything)
easm dev reset --confirm
```

## 🔍 Getting Help

```bash
# General help
easm --help
easm -h

# Command category help
easm dev --help
easm db --help
easm deploy --help
easm k8s --help

# Specific command help
easm dev start --help
easm db migrate --help
easm scan create --help

# Show version
easm --version
easm -v
```

## ⚙️ Configuration

### Global Flags

Available for all commands:

```bash
--verbose, -v    # Verbose output (detailed logs)
--quiet, -q      # Quiet mode (minimal output)
--help, -h       # Show help message
--version        # Show version
```

### Environment Variables

The CLI respects these environment variables from `.env`:

```bash
# API Configuration
API_LOCAL_PORT=8000              # API port
DEBUG=True                       # Django debug mode

# Database
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_DB=easm_db
POSTGRES_USER=easm_user
POSTGRES_PASSWORD=secure_password

# Redis
REDIS_HOST=localhost
REDIS_PORT=6379

# MongoDB
MONGODB_HOST=localhost
MONGODB_PORT=27017

# Deployment
DEPLOYMENT_MODE=dev              # dev, staging, prod
SKAFFOLD_MODE=auto               # auto, k8s, compose
```

## 🏗️ Architecture

### Project Structure

```
cli/
├── easm.py              # Main entry point
├── easm.bat             # Windows wrapper
├── easm                 # Unix wrapper
├── install.ps1          # Windows installer
├── install.sh           # Unix installer
├── README.md            # This file
├── commands/            # Command modules
│   ├── __init__.py
│   ├── dev.py          # ✅ Development commands (implemented)
│   ├── deploy.py       # ⏳ Deployment commands (stub)
│   ├── db.py           # ⏳ Database commands (stub)
│   ├── scan.py         # ⏳ Scanner commands (stub)
│   ├── k8s.py          # ⏳ Kubernetes commands (stub)
│   ├── docker.py       # ⏳ Docker commands (stub)
│   └── config.py       # ⏳ Config commands (stub)
└── utils/              # Utility modules
    ├── __init__.py
    ├── output.py       # Colored terminal output
    └── env.py          # Environment management
```

### How It Works

1. **Entry Point**: `easm.py` uses `argparse` to parse commands
2. **Command Routing**: Each command category has its own module in `commands/`
3. **Utilities**: Shared functionality in `utils/` (output, env management)
4. **Integration**: Calls existing scripts (`skaffold.ps1`, `docker-compose`, etc.)
5. **Auto-detection**: Checks for `kubectl` to determine deployment mode

## 📝 Notes

- **Python 3.8+** required
- **Cross-platform**: Works on Windows, Linux, and macOS
- **Colored output**: Automatically detected (Windows 10+ with ANSI support)
- **Auto-detection**: Intelligently chooses between Kubernetes and Docker Compose
- **Safe defaults**: Confirmation required for destructive operations
- **Environment aware**: Loads configuration from `.env` file

## 🤝 Contributing

To implement a stub command:

1. **Edit the command module**: `cli/commands/<category>.py`
2. **Update `register_commands()`**: Define arguments
3. **Implement `execute()`**: Add your logic
4. **Use utilities**: Import from `cli.utils.output` for colored output
5. **Test**: Run `easm <category> <command>` to verify

Example:
```python
# cli/commands/db.py
from cli.utils.output import print_success, print_error

def execute(args):
    if args.subcommand == 'migrate':
        # Implementation here
        print_success("Migrations applied successfully!")
        return 0
    return 1
```

## 📚 Related Documentation

- **Quick Reference**: [../QUICKSTART-CLI.md](../QUICKSTART-CLI.md)
- **Main README**: [../README.md](../README.md)
- **Scanner Guide**: [../docs/SCANNER-QUICKSTART.md](../docs/SCANNER-QUICKSTART.md)
- **Deployment**: [../docs/DEPLOYMENT.md](../docs/DEPLOYMENT.md)
- **Skaffold Guide**: [../docs/SKAFFOLD-GUIDE.md](../docs/SKAFFOLD-GUIDE.md)

## 🐛 Troubleshooting

### Installation Issues

**Installer ran but `easm` command doesn't work:**
```powershell
# The function was added to your profile but current terminal doesn't see it
# Solution 1: Reload your profile
. $PROFILE

# Solution 2: Open a new terminal (automatically loads profile)

# Solution 3: Use the batch wrapper (works without reload)
.\cli\easm.bat dev start

# Verify function exists in profile
Get-Content $PROFILE | Select-String "easm"
```

**Manual installation (if installer fails):**
```powershell
# Add to PowerShell profile manually
notepad $PROFILE

# Add these lines:
# EASM CLI
function easm {
    python "D:\Personal\EASM\easm-rnd\cli\easm.py" $args
}
# End EASM CLI

# Save and reload
. $PROFILE
```

### CLI doesn't run

```bash
# Check Python version (need 3.8+)
python --version

# Try running directly
python src/cli/easm-src/cli/easm-cli/easm.py --version

# Check file exists
ls src/cli/easm-cli/easm.py  # Linux/macOS
dir cli\easm.py # Windows
```

### Import errors

```bash
# Make sure you're in project root
cd /path/to/easm-rnd

# Check __init__.py files exist
ls cli/commands/__init__.py
ls cli/utils/__init__.py
```

### Minikube won't start

```bash
# Check Docker is running
docker ps

# Try manual start
minikube start --driver=docker

# Check status
minikube status
```

### Colors not working (Windows)

```bash
# Enable ANSI colors in Windows
Set-ItemProperty HKCU:\Console VirtualTerminalLevel -Type DWORD 1

# Or use Windows Terminal (recommended)
```

## 📄 License

This CLI is part of the EASM RND project - MIT License
