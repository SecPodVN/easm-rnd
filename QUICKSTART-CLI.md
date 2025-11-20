# EASM CLI - Quick Reference Card

## 🚀 5-Minute Quick Start

```bash
# 1. Setup (one-time)
git clone <repo-url>
cd easm-rnd
cp .env.example .env

# 2. Start everything
python cli/easm.py dev start

# 3. Done! Services running:
# - API:      http://localhost:8000
# - Frontend: http://localhost:3000
# - Postgres: localhost:5432
# - Redis:    localhost:6379
```

## 📋 Essential Commands

| Command | Description |
|---------|-------------|
| `python cli/easm.py dev start` | Start development environment |
| `python cli/easm.py dev stop` | Stop all services |
| `python cli/easm.py dev logs -f` | Follow logs |
| `python cli/easm.py --help` | Show all commands |

## 🔧 Installation (Optional)

Makes `easm` available globally instead of `python cli/easm.py`:

**Windows:**
```powershell
.\cli\install.ps1
# Then restart terminal and use:
easm dev start
```

**Linux/macOS:**
```bash
./cli/install.sh
# Then restart terminal and use:
easm dev start
```

## 🎯 Common Tasks

### Development Workflow
```bash
# Start with auto-reload
easm dev start --watch

# View logs
easm dev logs api -f

# Open shell in container
easm dev shell api

# Restart services
easm dev restart
```

### Database Operations
```bash
# Run migrations
easm db migrate

# Seed test data
easm db seed --quick

# Database shell
easm db shell
```

### Configuration
```bash
# Validate .env file
easm config validate

# Show current config
easm config show

# Set a value
easm config set DEBUG=True
```

### Cleanup
```bash
# Clean temp files
easm dev clean

# Full reset (keeps .env)
easm dev reset --confirm
```

## 🐛 Troubleshooting

### Services won't start
```bash
# Check status
easm k8s status
easm docker ps

# View detailed logs
easm dev logs -f --verbose
```

### Reset everything
```bash
# Nuclear option - reset to clean state
easm dev stop
easm dev clean
easm dev reset --confirm
easm dev start
```

### CLI not working
```bash
# Check Python version (need 3.8+)
python --version

# Reinstall (if installed globally)
.\cli\install.ps1 --uninstall  # Windows
./cli/install.sh --uninstall   # Linux/macOS
```

## 📦 Deployment Modes

The CLI auto-detects which mode to use:

| Mode | When Used |
|------|-----------|
| **Kubernetes** | If `kubectl` is available |
| **Docker Compose** | If no Kubernetes found |

**Force specific mode:**
```bash
easm dev start --mode k8s       # Use Kubernetes
easm dev start --mode compose   # Use Docker Compose
```

## 🔍 Get Help

```bash
# General help
easm --help

# Command-specific help
easm dev --help
easm dev start --help
easm db --help

# Verbose mode for debugging
easm dev start --verbose
```

## 📚 Full Documentation

- **CLI Reference**: [cli/README.md](cli/README.md)
- **Main README**: [README.md](README.md)
- **Scanner API**: [docs/SCANNER-QUICKSTART.md](docs/SCANNER-QUICKSTART.md)
- **Deployment Guide**: [docs/DEPLOYMENT.md](docs/DEPLOYMENT.md)

## 💡 Pro Tips

1. **Use watch mode** during development: `easm dev start --watch`
2. **Tail logs** in separate terminal: `easm dev logs -f`
3. **Install globally** for convenience (see Installation above)
4. **Check status** with: `easm k8s status` or `easm docker ps`
5. **Reset cleanly** before major changes: `easm dev reset --confirm`

---

**Need more help?** Run `easm --help` or check [cli/README.md](cli/README.md)
