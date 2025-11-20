"""
Development commands
"""
import subprocess
import sys
from pathlib import Path
from cli.utils.output import (
    print_info, print_success, print_error,
    print_header, print_warning
)
from cli.utils.env import load_env_file, get_project_root


def register_commands(parser):
    """Register dev subcommands"""
    subparsers = parser.add_subparsers(dest='subcommand', help='Dev subcommands')

    # Start command
    start_parser = subparsers.add_parser('start', help='Start development environment')
    start_parser.add_argument('--mode', choices=['compose', 'k8s', 'auto'], default='auto',
                             help='Deployment mode (auto-detect by default)')
    start_parser.add_argument('--watch', action='store_true', help='Enable watch mode')

    # Stop command
    subparsers.add_parser('stop', help='Stop development environment')

    # Restart command
    subparsers.add_parser('restart', help='Restart development environment')

    # Logs command
    logs_parser = subparsers.add_parser('logs', help='View service logs')
    logs_parser.add_argument('service', nargs='?', help='Service name (optional)')
    logs_parser.add_argument('-f', '--follow', action='store_true', help='Follow log output')

    # Shell command
    shell_parser = subparsers.add_parser('shell', help='Open shell in container/pod')
    shell_parser.add_argument('service', nargs='?', default='api', help='Service name')

    # Clean command
    subparsers.add_parser('clean', help='Clean temporary files and caches')

    # Reset command
    reset_parser = subparsers.add_parser('reset', help='Reset to clean state')
    reset_parser.add_argument('--confirm', action='store_true', help='Skip confirmation')

    # Watch command
    subparsers.add_parser('watch', help='Start auto-watch mode')


def execute(args):
    """Execute dev command"""
    if not args.subcommand:
        print_error("No subcommand specified. Use 'easm dev --help' for available commands")
        return 1

    if args.subcommand == 'start':
        return start(args)
    elif args.subcommand == 'stop':
        return stop(args)
    elif args.subcommand == 'restart':
        return restart(args)
    elif args.subcommand == 'logs':
        return logs(args)
    elif args.subcommand == 'shell':
        return shell(args)
    elif args.subcommand == 'clean':
        return clean(args)
    elif args.subcommand == 'reset':
        return reset(args)
    elif args.subcommand == 'watch':
        return watch(args)

    return 1


def start(args):
    """Start development environment"""
    print_header("Starting Development Environment")

    try:
        # Load environment
        load_env_file()
        print_success("Environment variables loaded")

        # Detect mode
        mode = detect_mode(args.mode)
        print_info(f"Using mode: {mode}")

        if mode == 'k8s':
            return start_k8s(args.watch)
        else:
            return start_compose()

    except Exception as e:
        print_error(f"Failed to start: {e}")
        return 1


def detect_mode(mode: str) -> str:
    """Detect deployment mode"""
    if mode != 'auto':
        return mode

    # Check if minikube is running
    try:
        result = subprocess.run(['kubectl', 'cluster-info'],
                              capture_output=True, text=True)
        if result.returncode == 0:
            return 'k8s'
    except FileNotFoundError:
        pass

    # Default to docker compose
    return 'compose'


def start_k8s(watch: bool = False):
    """Start with Kubernetes/Skaffold"""
    root = get_project_root()

    if watch:
        # Run auto-watch mode (option 6)
        print_info("Starting Skaffold in auto-watch mode...")
        if sys.platform == 'win32':
            script = root / 'skaffold.ps1'
            subprocess.run(['powershell', '-File', str(script)], input=b'6\n')
        else:
            script = root / 'skaffold.sh'
            subprocess.run([str(script)], input=b'6\n')
    else:
        # Run development mode (option 1)
        print_info("Starting Skaffold in development mode...")
        if sys.platform == 'win32':
            script = root / 'skaffold.ps1'
            subprocess.run(['powershell', '-File', str(script)], input=b'1\n')
        else:
            script = root / 'skaffold.sh'
            subprocess.run([str(script)], input=b'1\n')

    return 0


def start_compose():
    """Start with Docker Compose"""
    root = get_project_root()
    print_info("Starting Docker Compose...")

    try:
        subprocess.run(['docker-compose', 'up', '-d'], cwd=root, check=True)
        print_success("Services started successfully")
        return 0
    except subprocess.CalledProcessError as e:
        print_error(f"Failed to start services: {e}")
        return 1


def stop(args):
    """Stop development environment"""
    print_header("Stopping Development Environment")

    # Try both k8s and compose
    stopped = False

    # Try stopping k8s
    try:
        result = subprocess.run(['kubectl', 'delete', 'all', '--all', '-n', 'easm-rnd'],
                              capture_output=True)
        if result.returncode == 0:
            print_success("Kubernetes resources deleted")
            stopped = True
    except FileNotFoundError:
        pass

    # Try stopping compose
    try:
        result = subprocess.run(['docker-compose', 'down'],
                              capture_output=True,
                              cwd=get_project_root())
        if result.returncode == 0:
            print_success("Docker Compose services stopped")
            stopped = True
    except FileNotFoundError:
        pass

    if not stopped:
        print_warning("No running services found")

    return 0


def restart(args):
    """Restart development environment"""
    print_header("Restarting Development Environment")
    stop(args)
    return start(args)


def logs(args):
    """View service logs"""
    # Implementation depends on detected mode
    print_info("Viewing logs...")
    return 0


def shell(args):
    """Open shell in container"""
    print_info(f"Opening shell in {args.service}...")
    return 0


def clean(args):
    """Clean temporary files"""
    print_header("Cleaning Temporary Files")

    root = get_project_root()
    patterns = [
        '**/__pycache__',
        '**/*.pyc',
        '**/*.pyo',
        'skaffold.temp.yaml',
        'skaffold-values.yaml',
        '.pytest_cache',
        'htmlcov',
        '.coverage'
    ]

    for pattern in patterns:
        for path in root.rglob(pattern):
            if path.is_dir():
                import shutil
                shutil.rmtree(path)
                print_info(f"Removed: {path}")
            else:
                path.unlink()
                print_info(f"Removed: {path}")

    print_success("Cleanup complete")
    return 0


def reset(args):
    """Reset to clean state"""
    print_header("Resetting to Clean State")

    if not args.confirm:
        from cli.utils.output import confirm
        if not confirm("This will stop all services and clean data. Continue?"):
            print_info("Cancelled")
            return 0

    # Stop services
    stop(args)

    # Clean files
    clean(args)

    print_success("Reset complete")
    return 0


def watch(args):
    """Start auto-watch mode"""
    print_header("Starting Auto-Watch Mode")
    args.watch = True
    return start_k8s(watch=True)
