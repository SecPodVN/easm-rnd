#!/bin/bash
# EASM CLI Installation Script (Bash)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

function print_success_msg() {
    echo -e "${GREEN}✓${NC} $1"
}

function print_info_msg() {
    echo -e "${CYAN}ℹ${NC} $1"
}

function print_warning_msg() {
    echo -e "${YELLOW}⚠${NC} $1"
}

function print_error_msg() {
    echo -e "${RED}✗${NC} $1"
}

echo -e "\n${CYAN}═══════════════════════════════════════${NC}"
echo -e "${CYAN}  EASM CLI Installation${NC}"
echo -e "${CYAN}═══════════════════════════════════════${NC}\n"

# Check Python
print_info_msg "Checking Python installation..."
if command -v python3 &> /dev/null; then
    PYTHON_CMD="python3"
    PYTHON_VERSION=$(python3 --version)
    print_success_msg "Python found: $PYTHON_VERSION"
elif command -v python &> /dev/null; then
    PYTHON_CMD="python"
    PYTHON_VERSION=$(python --version)
    print_success_msg "Python found: $PYTHON_VERSION"
else
    print_error_msg "Python is not installed or not in PATH"
    echo -e "\nPlease install Python 3.8+ from https://www.python.org/"
    exit 1
fi

# Uninstall if requested
if [[ "$1" == "--uninstall" ]]; then
    print_info_msg "Uninstalling EASM CLI..."

    # Remove symlink
    if [[ -L "/usr/local/bin/easm" ]]; then
        sudo rm /usr/local/bin/easm
        print_success_msg "Removed /usr/local/bin/easm"
    fi

    # Remove from shell configs
    for rc in ~/.bashrc ~/.zshrc ~/.bash_profile ~/.profile; do
        if [[ -f "$rc" ]] && grep -q "# EASM CLI" "$rc"; then
            sed -i.bak '/# EASM CLI/,/# End EASM CLI/d' "$rc"
            print_success_msg "Removed from $rc"
        fi
    done

    print_success_msg "EASM CLI uninstalled"
    print_info_msg "Please restart your terminal or run: source ~/.bashrc"
    exit 0
fi

# Detect shell
SHELL_RC=""
if [[ -n "$BASH_VERSION" ]]; then
    SHELL_RC="$HOME/.bashrc"
    [[ ! -f "$SHELL_RC" ]] && SHELL_RC="$HOME/.bash_profile"
elif [[ -n "$ZSH_VERSION" ]]; then
    SHELL_RC="$HOME/.zshrc"
else
    SHELL_RC="$HOME/.profile"
fi

print_info_msg "Detected shell config: $SHELL_RC"

# Option 1: Create symlink (requires sudo)
print_info_msg "Creating symlink in /usr/local/bin..."
if sudo ln -sf "$SCRIPT_DIR/easm" /usr/local/bin/easm 2>/dev/null; then
    sudo chmod +x /usr/local/bin/easm
    print_success_msg "Created symlink: /usr/local/bin/easm"
else
    print_warning_msg "Could not create symlink (sudo required)"
fi

# Option 2: Add alias to shell config
print_info_msg "Adding alias to shell configuration..."
ALIAS_CODE="
# EASM CLI
alias easm='$PYTHON_CMD $SCRIPT_DIR/easm.py'
export PATH=\"\$PATH:$SCRIPT_DIR\"
# End EASM CLI
"

if ! grep -q "# EASM CLI" "$SHELL_RC" 2>/dev/null; then
    echo "$ALIAS_CODE" >> "$SHELL_RC"
    print_success_msg "Added alias to $SHELL_RC"
else
    print_info_msg "Alias already exists in $SHELL_RC"
fi

# Make easm script executable
chmod +x "$SCRIPT_DIR/easm"
print_success_msg "Made easm script executable"

echo -e "\n${GREEN}═══════════════════════════════════════${NC}"
echo -e "${GREEN}  Installation Complete!${NC}"
echo -e "${GREEN}═══════════════════════════════════════${NC}\n"

echo "You can now use the CLI in the following ways:"
echo ""
echo -e "  1. Direct:      ${YELLOW}python3 cli/easm.py <command>${NC}"
echo -e "  2. Via script:  ${YELLOW}./cli/easm <command>${NC}"
echo -e "  3. After reload:${YELLOW}easm <command>${NC} (requires new terminal)"

echo -e "\nExamples:"
echo -e "  ${CYAN}easm dev start${NC}"
echo -e "  ${CYAN}easm --help${NC}"
echo -e "  ${CYAN}easm dev logs -f${NC}"

echo ""
print_info_msg "Restart your terminal or run: source $SHELL_RC"
echo ""
