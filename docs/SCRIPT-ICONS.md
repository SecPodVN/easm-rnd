# Script Icon Legend

All scripts use ASCII-based icons for cross-platform compatibility (Windows, Linux, macOS).

## Icon Reference

| Icon      | Meaning              | Usage                          |
|-----------|----------------------|--------------------------------|
| `[*]`     | Information/Progress | Loading, updating, processing  |
| `[+]`     | Success/Addition     | Item added, setting applied    |
| `[!]`     | Warning             | Non-critical issues            |
| `[OK]`    | Success/Ready       | Operation completed, ready     |
| `[ERROR]` | Error               | Critical failure               |
| `[>>]`    | Action Starting     | Beginning an operation         |

## Example Output

```
=== EASM Skaffold Deployment Script ===

[*] Loading environment variables from .env file...
  [+] Set K8S_NAMESPACE
  [+] Set API_IMAGE
  [+] Set API_IMAGE_TAG
[OK] Kubernetes cluster is running

[*] Updating Helm repositories...

Choose deployment mode:
  1) Development (skaffold dev - with hot reload)
  2) One-time deployment (skaffold run)

[>>] Starting Skaffold in development mode...
[*] Press Ctrl+C to stop
```

## Why ASCII Icons?

- **Cross-platform**: Works on Windows, Linux, macOS, WSL
- **Universal**: No font or encoding dependencies
- **Terminal-friendly**: Works in all terminal emulators
- **Clear**: Easy to parse and understand
- **Grep-able**: Easy to search logs with patterns like `grep "\[ERROR\]"`

## Color Coding

Scripts also use color coding when available:

- **Cyan**: Headers and section titles
- **Yellow**: Information and warnings `[*]`, `[!]`
- **Green**: Success messages `[OK]`, `[>>]`
- **Red**: Errors `[ERROR]`
- **Gray**: Details and sub-items `[+]`

## Searching Logs

```bash
# Find all errors
grep "\[ERROR\]" deployment.log

# Find all warnings
grep "\[!]" deployment.log

# Find success messages
grep "\[OK\]" deployment.log

# Find actions
grep "\[>>\]" deployment.log
```
