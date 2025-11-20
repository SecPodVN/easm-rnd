"""
Output utilities for CLI - colored output and formatting
"""
import sys
from typing import Optional


class Colors:
    """ANSI color codes"""
    RESET = '\033[0m'
    BLACK = '\033[30m'
    RED = '\033[31m'
    GREEN = '\033[32m'
    YELLOW = '\033[33m'
    BLUE = '\033[34m'
    MAGENTA = '\033[35m'
    CYAN = '\033[36m'
    WHITE = '\033[37m'
    BOLD = '\033[1m'
    DIM = '\033[2m'


def supports_color() -> bool:
    """Check if terminal supports color"""
    if sys.platform == 'win32':
        # Enable ANSI on Windows 10+
        try:
            import ctypes
            kernel32 = ctypes.windll.kernel32
            kernel32.SetConsoleMode(kernel32.GetStdHandle(-11), 7)
            return True
        except:
            return False
    return True


def colored(text: str, color: str, bold: bool = False) -> str:
    """Return colored text"""
    if not supports_color():
        return text

    prefix = Colors.BOLD if bold else ''
    return f"{prefix}{color}{text}{Colors.RESET}"


def print_banner():
    """Print CLI banner"""
    banner = f"""
{colored('═══════════════════════════════════════════════════════════', Colors.CYAN, bold=True)}
{colored('    EASM CLI', Colors.CYAN, bold=True)} - External Attack Surface Management
{colored('═══════════════════════════════════════════════════════════', Colors.CYAN, bold=True)}
    """
    print(banner)


def print_success(message: str):
    """Print success message"""
    print(colored(f"[OK] {message}", Colors.GREEN))


def print_error(message: str):
    """Print error message"""
    print(colored(message, Colors.RED), file=sys.stderr)


def print_warning(message: str):
    """Print warning message"""
    print(colored(f"[WARNING] {message}", Colors.YELLOW))


def print_info(message: str):
    """Print info message"""
    print(colored(f"[*] {message}", Colors.CYAN))


def print_debug(message: str):
    """Print debug message"""
    print(colored(f"[DEBUG] {message}", Colors.DIM))


def print_header(message: str):
    """Print section header"""
    print(colored(f"\n{'='*60}", Colors.CYAN))
    print(colored(f"  {message}", Colors.CYAN, bold=True))
    print(colored(f"{'='*60}\n", Colors.CYAN))


def print_step(step: int, total: int, message: str):
    """Print step progress"""
    print(colored(f"[{step}/{total}] {message}", Colors.BLUE))


def confirm(message: str, default: bool = False) -> bool:
    """Ask for user confirmation"""
    default_str = "Y/n" if default else "y/N"
    response = input(colored(f"{message} [{default_str}]: ", Colors.YELLOW))

    if not response:
        return default

    return response.lower() in ['y', 'yes']
