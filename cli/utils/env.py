"""
Environment utilities - load and manage .env files
"""
import os
from pathlib import Path
from typing import Dict, Optional


def get_project_root() -> Path:
    """Get project root directory"""
    return Path(__file__).parent.parent.parent


def load_env_file(env_file: Optional[Path] = None) -> Dict[str, str]:
    """Load environment variables from .env file"""
    if env_file is None:
        env_file = get_project_root() / '.env'

    if not env_file.exists():
        raise FileNotFoundError(f".env file not found: {env_file}")

    env_vars = {}

    with open(env_file, 'r') as f:
        for line in f:
            line = line.strip()

            # Skip comments and empty lines
            if not line or line.startswith('#'):
                continue

            # Parse key=value
            if '=' in line:
                key, value = line.split('=', 1)
                key = key.strip()
                value = value.strip()

                # Remove quotes if present
                if value.startswith('"') and value.endswith('"'):
                    value = value[1:-1]
                elif value.startswith("'") and value.endswith("'"):
                    value = value[1:-1]

                env_vars[key] = value
                # Also set in current process
                os.environ[key] = value

    return env_vars


def get_env(key: str, default: Optional[str] = None) -> Optional[str]:
    """Get environment variable with fallback"""
    return os.environ.get(key, default)


def set_env(key: str, value: str):
    """Set environment variable"""
    os.environ[key] = value


def validate_env(required_vars: list) -> bool:
    """Validate that required environment variables are set"""
    missing = []

    for var in required_vars:
        if var not in os.environ or not os.environ[var]:
            missing.append(var)

    if missing:
        from cli.utils.output import print_error
        print_error(f"Missing required environment variables: {', '.join(missing)}")
        return False

    return True
