# EASM CLI

Global command-line tool to manage the entire EASM project - backend, frontend, CI/CD, deployment, and infrastructure.

## Installation

### Using Poetry (Recommended for Development)

Poetry manages dependencies and creates an isolated virtual environment for the CLI.

```bash
# Navigate to the CLI directory
cd src/cli/easm-cli

# Install dependencies and the CLI
poetry install

# Use 'poetry run' to execute commands (recommended)
poetry run easm --version
poetry run easm --help
poetry run easm dev start
```

**Alternative: Activate the virtual environment manually**

```bash
cd src/cli/easm-cli

# Get the activation script path (Poetry 2.0+)
poetry env info --path

# On Windows PowerShell:
& "$(poetry env info --path)\Scripts\Activate.ps1"

# On Windows CMD:
"$(poetry env info --path)\Scripts\activate.bat"

# On Linux/Mac:
source $(poetry env info --path)/bin/activate

# Now you can use 'easm' directly
easm --version

# To deactivate
deactivate
```

> **Note**: Poetry 2.0+ removed the `poetry shell` command. Use `poetry run` (recommended) or manually activate the virtual environment as shown above.

### Using pipx (Global Installation)

For system-wide installation without managing virtual environments:

```bash
# Install pipx if you don't have it
pip install pipx

# Install easm-cli globally
pipx install ./src/cli/easm-cli

# Use from anywhere
easm --version
```

### Migration from Old Install Script

**⚠️ If you used the old install script:**

```powershell
# Windows: Remove the old function from PowerShell profile
notepad $PROFILE
# Delete these lines:
# # EASM CLI
# function easm {
#     python "D:\Personal\EASM\easm-rnd\src\cli\easm-cli\easm.py" $args
# }
# # End EASM CLI

# Linux/Mac: Remove from ~/.bashrc or ~/.zshrc
# Delete the alias/function for 'easm'

# Then restart your terminal
```

## Usage

### Basic Commands

```bash
# Get help
easm --help
easm dev --help      # Help for specific command group

# Show version
easm --version

# Verbose output
easm --verbose dev start
easm -v dev start

# Quiet mode
easm --quiet dev stop
easm -q dev stop
```

### Development Environment

```bash
# Start development environment (auto-detects k8s or docker-compose)
easm dev start

# Start with specific mode
easm dev start --mode compose    # Force Docker Compose
easm dev start --mode k8s        # Force Kubernetes/Skaffold
easm dev start --watch           # Enable watch mode

# Stop services
easm dev stop

# Restart services
easm dev restart

# View logs
easm dev logs                    # All services
easm dev logs api               # Specific service
easm dev logs -f                # Follow logs

# Open shell in container
easm dev shell                  # Default service (api)
easm dev shell frontend         # Specific service

# Clean temporary files
easm dev clean

# Reset to clean state
easm dev reset --confirm
```

### Database Management (Planned)

```bash
easm db migrate                 # Run migrations
easm db seed                    # Seed data
easm db shell                   # Open database shell
```

### Deployment (Planned)

```bash
easm deploy start               # Deploy to staging
easm deploy start --mode prod   # Deploy to production
easm deploy rollback            # Rollback deployment
```

### Kubernetes Operations (Planned)

```bash
easm k8s status                 # Check cluster status
easm k8s logs api              # View pod logs
easm k8s shell api             # Open shell in pod
```

### Docker Operations (Planned)

```bash
easm docker build              # Build containers
easm docker push               # Push to registry
```

### Security Scanning (Planned)

```bash
easm scan start                # Start security scan
easm scan report               # View scan results
```

### Configuration (Planned)

```bash
easm config validate           # Validate configuration
easm config set KEY=VALUE      # Set configuration value
```

## Commands Status

| Category | Command | Status | Description |
|----------|---------|--------|-------------|
| **Development** | `dev start/stop/restart` | ✅ Working | Manage dev environment |
| | `dev logs/shell/clean` | ✅ Working | Dev utilities |
| **Database** | `db migrate/seed/shell` | ⏳ Planned | Database management |
| **Deployment** | `deploy start/rollback` | ⏳ Planned | Deploy to environments |
| **Kubernetes** | `k8s status/logs/shell` | ⏳ Planned | Cluster operations |
| **Docker** | `docker build/push` | ⏳ Planned | Container management |
| **Security** | `scan start/report` | ⏳ Planned | Security scanning |
| **Config** | `config validate/set` | ⏳ Planned | Configuration management |

## Development Guide

### Project Structure

```
src/cli/easm-cli/
├── cli.py              # Main entry point
├── pyproject.toml      # Poetry configuration
├── README.md           # This file
├── commands/           # Command modules
│   ├── __init__.py
│   ├── dev.py         # Development commands
│   ├── deploy.py      # Deployment commands
│   ├── db.py          # Database commands
│   ├── scan.py        # Security scan commands
│   ├── k8s.py         # Kubernetes commands
│   ├── docker.py      # Docker commands
│   └── config.py      # Configuration commands
└── utils/              # Utility modules
    ├── __init__.py
    ├── output.py      # Output formatting (colors, messages)
    └── env.py         # Environment handling
```

### Adding a New Command

Follow these steps to add a new command to the CLI:

#### 1. Create a Command Module

Create a new file in `commands/` directory (e.g., `commands/backup.py`):

```python
"""
Backup commands for EASM CLI
"""
from utils.output import print_info, print_success, print_error, print_header


def register_commands(parser):
    """Register backup subcommands"""
    subparsers = parser.add_subparsers(dest='subcommand', help='Backup subcommands')

    # Create command
    create_parser = subparsers.add_parser('create', help='Create a backup')
    create_parser.add_argument('--name', required=True, help='Backup name')
    create_parser.add_argument('--type', choices=['full', 'incremental'],
                              default='full', help='Backup type')

    # Restore command
    restore_parser = subparsers.add_parser('restore', help='Restore from backup')
    restore_parser.add_argument('backup_name', help='Backup to restore')

    # List command
    subparsers.add_parser('list', help='List all backups')


def execute(args):
    """Execute backup command"""
    if not args.subcommand:
        print_error("No subcommand specified. Use 'easm backup --help'")
        return 1

    if args.subcommand == 'create':
        return create_backup(args)
    elif args.subcommand == 'restore':
        return restore_backup(args)
    elif args.subcommand == 'list':
        return list_backups(args)

    return 1


def create_backup(args):
    """Create a new backup"""
    print_header(f"Creating {args.type} backup: {args.name}")

    try:
        # Your backup logic here
        print_info("Backing up database...")
        print_info("Backing up files...")

        print_success(f"Backup '{args.name}' created successfully")
        return 0
    except Exception as e:
        print_error(f"Backup failed: {e}")
        return 1


def restore_backup(args):
    """Restore from backup"""
    print_header(f"Restoring backup: {args.backup_name}")

    try:
        # Your restore logic here
        print_info("Restoring database...")
        print_info("Restoring files...")

        print_success("Backup restored successfully")
        return 0
    except Exception as e:
        print_error(f"Restore failed: {e}")
        return 1


def list_backups(args):
    """List all backups"""
    print_header("Available Backups")

    # Your list logic here
    backups = [
        ("backup-2024-01-01", "full", "2024-01-01 10:00:00"),
        ("backup-2024-01-02", "incremental", "2024-01-02 10:00:00"),
    ]

    for name, type_, date in backups:
        print_info(f"{name} ({type_}) - {date}")

    return 0
```

#### 2. Register the Command in `cli.py`

Import and register your new command module in `cli.py`:

```python
# In cli.py, add to imports
from commands import dev, deploy, db, scan, k8s, docker, config, backup

# In create_parser(), add to command_modules
command_modules = {
    'dev': dev,
    'deploy': deploy,
    'db': db,
    'scan': scan,
    'k8s': k8s,
    'docker': docker,
    'config': config,
    'backup': backup,  # Add your new command
}

# Add parser for the new command
backup_parser = subparsers.add_parser('backup', help='Backup operations')
backup.register_commands(backup_parser)
```

#### 3. Test Your Command

```bash
# Reinstall to pick up changes
poetry install

# Test with poetry run (recommended)
poetry run easm backup --help
poetry run easm backup create --name test-backup --type full
poetry run easm backup list

# Or activate the environment manually and run directly
& "$(poetry env info --path)\Scripts\Activate.ps1"  # Windows PowerShell
easm backup --help
deactivate
```

#### 4. Using Utility Functions

The CLI provides utility functions for consistent output:

```python
from utils.output import (
    print_header,    # Print section header
    print_info,      # Print info message (blue)
    print_success,   # Print success message (green)
    print_error,     # Print error message (red)
    print_warning,   # Print warning message (yellow)
    confirm,         # Ask for user confirmation
)

from utils.env import (
    load_env_file,       # Load .env file
    get_project_root,    # Get project root directory
    get_env,             # Get environment variable
)
```

### Best Practices

1. **Command Structure**: Each command module should have:
   - `register_commands(parser)` - Define subcommands and arguments
   - `execute(args)` - Main execution logic
   - Individual functions for each subcommand

2. **Error Handling**: Always wrap operations in try-except blocks and return proper exit codes (0 for success, 1 for failure)

3. **User Feedback**: Use the output utilities to provide clear feedback:
   ```python
   print_header("Operation Name")  # Start of operation
   print_info("Processing...")      # Progress updates
   print_success("Done!")           # Success message
   ```

4. **Arguments**: Use descriptive help text and appropriate argument types:
   ```python
   parser.add_argument('--force', action='store_true', help='Force operation')
   parser.add_argument('--count', type=int, default=5, help='Number of items')
   parser.add_argument('--mode', choices=['dev', 'prod'], help='Environment mode')
   ```

5. **Testing**: Test commands with both `poetry run` and manual activation methods

### Running Tests

```bash
cd src/cli/easm-cli

# Run tests
poetry run pytest

# Run tests with coverage
poetry run pytest --cov=. --cov-report=html

# Run linting
poetry run black .
poetry run ruff check .
```

## Uninstall

```bash
# If using Poetry (remove virtual environment)
cd src/cli/easm-cli
poetry env remove --all

# If installed with pipx
pipx uninstall easm-cli
```

## Troubleshooting

### Command not found after `poetry install`

Use `poetry run` to execute commands:

```bash
cd src/cli/easm-cli
poetry run easm --version
```

Or activate the virtual environment manually:

```bash
# Windows PowerShell
& "$(poetry env info --path)\Scripts\Activate.ps1"
easm --version
deactivate

# Linux/Mac
source $(poetry env info --path)/bin/activate
easm --version
deactivate
```

### Old installation conflicts

If you have conflicts with old installations:

```bash
# Check what 'easm' points to
Get-Command easm  # Windows PowerShell
which easm        # Linux/Mac

# Remove old pip installation
pip uninstall easm-cli

# Check PowerShell profile for old functions
notepad $PROFILE  # Windows
```

### Poetry not found

Install Poetry first:

```bash
# Windows (PowerShell)
(Invoke-WebRequest -Uri https://install.python-poetry.org -UseBasicParsing).Content | python -

# Linux/Mac
curl -sSL https://install.python-poetry.org | python3 -
```

### Import errors

Reinstall dependencies:

```bash
cd src/cli/easm-cli
poetry install --no-cache
```

## Resources

- [Poetry Documentation](https://python-poetry.org/docs/)
- [EASM Repository](https://github.com/SecPodVN/easm-rnd)
- [Python argparse Documentation](https://docs.python.org/3/library/argparse.html)
