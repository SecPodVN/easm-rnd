# Cross-Platform Development Guide

This project supports development on **Linux**, **macOS**, and **Windows** (via WSL or PowerShell).

## Shell Scripts

All shell scripts use `#!/usr/bin/env bash` shebang for maximum compatibility.

### Linux/macOS

Run shell scripts directly:
```bash
chmod +x start-skaffold.sh
./start-skaffold.sh
```

### Windows (WSL)

1. Install WSL2: https://docs.microsoft.com/en-us/windows/wsl/install
2. Run scripts in WSL terminal:
```bash
./start-skaffold.sh
```

### Windows (PowerShell)

Use PowerShell scripts (`.ps1`) instead:
```powershell
.\start-skaffold.ps1
```

## Line Endings

This project uses **LF** (Unix-style) line endings for all files. Git is configured to handle this automatically:

```bash
# Already configured in .editorconfig and .gitattributes
```

If you encounter line ending issues on Windows:
```bash
# Configure Git to use LF endings
git config --global core.autocrlf input

# Re-checkout files
git rm --cached -r .
git reset --hard
```

## Script Compatibility Features

### Bash Scripts
- Use `#!/usr/bin/env bash` for portability
- Quote variables: `"${VAR:-default}"`
- Use `[ $count -eq $timeout ]` instead of `[[ ]]` when possible
- Timeout handling with fallback for missing services
- Proper error handling with `set -e`

### PowerShell Scripts
- Equivalent functionality to bash scripts
- Use for Windows-only environments
- Cross-platform PowerShell (pwsh) supported

## Development Environment Setup

### VS Code Extensions

Install recommended extensions:
```bash
# Open VS Code
code .

# VS Code will prompt to install recommended extensions
```

### Python Environment

```bash
# Linux/macOS
python3 -m venv .venv
source .venv/bin/activate
pip install poetry
poetry install

# Windows (PowerShell)
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install poetry
poetry install
```

### Node.js/React (if applicable)

```bash
# All platforms
npm install
# or
yarn install
```

## Platform-Specific Notes

### Linux
- Ensure `netcat` is installed: `sudo apt-get install netcat`
- Shell scripts work natively

### macOS
- Install Homebrew: https://brew.sh/
- Install tools: `brew install netcat`
- Shell scripts work natively

### Windows
- **Recommended**: Use WSL2 for best compatibility
- **Alternative**: Use PowerShell scripts (`.ps1`)
- Git Bash also works but WSL2 preferred
- Ensure line endings are LF (configured in `.editorconfig`)

## Docker & Kubernetes

All Docker and Kubernetes configurations are platform-independent:

```bash
# All platforms
docker-compose up
# or
skaffold dev
```

## Troubleshooting

### Permission Denied (Linux/macOS)
```bash
chmod +x *.sh
chmod +x src/backend/*.sh
```

### Script Not Found (Windows)
- Use PowerShell scripts: `.\script.ps1`
- Or use WSL: `wsl ./script.sh`

### Line Ending Issues
```bash
# Convert CRLF to LF
dos2unix file.sh
# or
sed -i 's/\r$//' file.sh
```

### Python Path Issues
```bash
# Set PYTHONPATH
export PYTHONPATH="${PYTHONPATH}:$(pwd)"  # Linux/macOS
$env:PYTHONPATH = "$env:PYTHONPATH;$(pwd)"  # PowerShell
```

## CI/CD

All CI/CD pipelines run on Linux containers, ensuring consistency regardless of development platform.
