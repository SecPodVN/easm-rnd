# EASM CLI

Unified CLI for EASM project development and deployment.

## Install

```bash
# pipx (recommended)
pipx install src/cli/easm-cli

# Poetry (dev)
cd src/cli/easm-cli && poetry install && poetry shell

# pip
pip install -e src/cli/easm-cli
```

**Requires:** Python 3.8+, Poetry

## Usage

```bash
# Development commands (✅ implemented)
easm dev start              # Auto-detect k8s/compose
easm dev start --mode k8s   # Force Kubernetes
easm dev stop               # Stop services
easm dev logs -f            # Follow logs
easm dev shell api          # Shell into container
easm dev clean              # Clean temp files
easm dev reset --confirm    # Full reset

# Other commands (⏳ not yet implemented)
easm db migrate             # Database operations
easm deploy start           # Deployment
easm k8s status             # Kubernetes management
easm scan list              # Scanner operations
easm docker build           # Docker operations
easm config validate        # Configuration management

# General
easm --help                 # Show all commands
easm <command> --help       # Command-specific help
```

## Implementation Status

| Command | Status | Description |
|---------|--------|-------------|
| `dev` | ✅ Implemented | Development environment management |
| `db` | ⏳ Stub | Database operations (migrate, seed, shell) |
| `deploy` | ⏳ Stub | Deployment commands |
| `k8s` | ⏳ Stub | Kubernetes cluster management |
| `scan` | ⏳ Stub | Scanner operations |
| `docker` | ⏳ Stub | Docker operations |
| `config` | ⏳ Stub | Configuration management |

## How It Works

- Checks `kubectl` → k8s (runs `skaffold.ps1`) or docker-compose
- Auto-starts Minikube if needed
- Loads `.env` from project root
- Cross-platform: Windows/Linux/macOS

## Adding New Commands

To implement a stub command:

1. **Edit command module** (`commands/<category>.py`):
```python
from utils.output import print_success, print_error

def execute(args):
    if args.subcommand == 'migrate':
        # Your implementation here
        print_success("Migration completed!")
        return 0
    return 1
```

2. **Test your changes**:
```bash
cd src/cli/easm-cli
poetry install
poetry run easm db migrate
```

3. **Available utilities**:
```python
from utils.output import (
    print_info,      # Blue info message
    print_success,   # Green success message
    print_error,     # Red error message
    print_warning,   # Yellow warning
    print_header     # Bold header
)
from utils.env import (
    load_env_file,   # Load .env file
    get_project_root # Get project root path
)
```

## Update

```bash
pipx reinstall src/cli/easm-cli                   # pipx
cd src/cli/easm-cli && poetry install             # Poetry
pip install -e src/cli/easm-cli --force-reinstall # pip
```

## Structure

```
src/cli/easm-cli/
├── pyproject.toml  # Poetry config
├── cli.py          # Main entry point
├── commands/       # Command modules
│   ├── dev.py     # ✅ Implemented
│   ├── db.py      # ⏳ Stub
│   ├── deploy.py  # ⏳ Stub
│   ├── k8s.py     # ⏳ Stub
│   ├── scan.py    # ⏳ Stub
│   ├── docker.py  # ⏳ Stub
│   └── config.py  # ⏳ Stub
└── utils/          # Utilities
    ├── output.py   # Colored terminal output
    └── env.py      # Environment management
```

## Migrate from Old Scripts

```bash
.\src\cli\easm-cli\install.ps1 -Uninstall  # Remove old
pipx install src/cli/easm-cli              # Install new
```
