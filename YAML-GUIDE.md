# YAML Development & Review Guide

This guide provides best practices and tools for developing and reviewing YAML files in this project, particularly for Kubernetes, Helm, Docker Compose, and CI/CD configurations.

## 📋 Table of Contents

- [Editor Setup](#editor-setup)
- [YAML Validation Tools](#yaml-validation-tools)
- [Best Practices](#best-practices)
- [Common Tasks](#common-tasks)
- [Troubleshooting](#troubleshooting)

## 🛠️ Editor Setup

### VS Code Extensions

The following extensions are recommended (see `.vscode/extensions.json`):

1. **redhat.vscode-yaml** - YAML language support with JSON schema validation
2. **ms-kubernetes-tools.vscode-kubernetes-tools** - Kubernetes support
3. **Tim-Koehler.helm-intellisense** - Helm chart IntelliSense
4. **technosophos.vscode-helm** - Helm chart snippets

### VS Code Settings

Our `.vscode/settings.json` includes:
- Auto-formatting on save
- 2-space indentation for YAML
- JSON schema validation for Kubernetes, Helm, Docker Compose
- Syntax highlighting for Helm templates
- Auto-completion for Kubernetes resources

## 🔍 YAML Validation Tools

### 1. yamllint

**Installation:**
```bash
# Linux/macOS
pip install yamllint

# Windows
pip install yamllint
```

**Usage:**
```bash
# Lint single file
yamllint path/to/file.yaml

# Lint directory
yamllint .

# Auto-fix (with prettier)
prettier --write "**/*.{yml,yaml}"
```

**VS Code Task:** Press `Ctrl+Shift+P` → `Tasks: Run Task` → `yamllint: Lint YAML File`

### 2. Kubernetes YAML Validation

**kubectl dry-run:**
```bash
# Validate without applying
kubectl apply --dry-run=client --validate=true -f file.yaml

# Validate with server-side validation
kubectl apply --dry-run=server --validate=true -f file.yaml
```

**VS Code Task:** Press `Ctrl+Shift+P` → `Tasks: Run Task` → `Validate Kubernetes YAML`

### 3. Kubeval

**Installation:**
```bash
# Linux
wget https://github.com/instrumenta/kubeval/releases/latest/download/kubeval-linux-amd64.tar.gz
tar xf kubeval-linux-amd64.tar.gz
sudo mv kubeval /usr/local/bin

# macOS
brew install kubeval

# Windows
choco install kubeval
```

**Usage:**
```bash
# Validate single file
kubeval --strict file.yaml

# Validate multiple files
kubeval k8s/**/*.yaml

# Validate with specific Kubernetes version
kubeval --kubernetes-version 1.29.0 file.yaml
```

**VS Code Task:** Press `Ctrl+Shift+P` → `Tasks: Run Task` → `Kubeval: Validate Kubernetes YAML`

### 4. Helm Chart Validation

**Lint chart:**
```bash
# Lint entire chart
helm lint src/charts/easm-api

# Lint with custom values
helm lint src/charts/easm-api -f values-dev.yaml
```

**VS Code Task:** Press `Ctrl+Shift+P` → `Tasks: Run Task` → `Validate Helm Chart`

**Render templates:**
```bash
# Render templates to see final output
helm template test-release src/charts/easm-api --debug

# Render with custom values
helm template test-release src/charts/easm-api -f values-dev.yaml --debug
```

**VS Code Task:** Press `Ctrl+Shift+P` → `Tasks: Run Task` → `Render Helm Template`

### 5. Docker Compose Validation

```bash
# Validate docker-compose.yml
docker compose -f docker-compose.yml config

# Validate with specific file
docker compose -f docker-compose.prod.yml config
```

**VS Code Task:** Press `Ctrl+Shift+P` → `Tasks: Run Task` → `Validate Docker Compose`

### 6. Skaffold Validation

```bash
# Diagnose skaffold.yaml
skaffold diagnose --yaml-only

# Render manifests
skaffold render
```

**VS Code Task:** Press `Ctrl+Shift+P` → `Tasks: Run Task` → `Validate Skaffold`

## 📝 Best Practices

### 1. Indentation

```yaml
# ✅ Good: 2 spaces
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  containers:
  - name: nginx
    image: nginx:latest

# ❌ Bad: tabs or 4 spaces
apiVersion: v1
kind: Pod
metadata:
    name: my-pod
```

### 2. Quoting

```yaml
# ✅ Good: Quote values that might be interpreted incorrectly
version: "3.8"
port: "8080"
value: "yes"
name: "my-app"

# ❌ Bad: Unquoted values
version: 3.8  # Interpreted as float
port: 8080    # Interpreted as int (okay for some fields)
value: yes    # Interpreted as boolean
```

### 3. Helm Templates

```yaml
# ✅ Good: Proper template spacing
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "chart.fullname" . }}
data:
  key: {{ .Values.config.key | quote }}

# ❌ Bad: Spaces in template delimiters (breaks YAML parsing)
apiVersion: v1
kind: ConfigMap
metadata:
  name: { { include "chart.fullname" . } }
data:
  key: { { .Values.config.key | quote } }
```

### 4. Multi-line Strings

```yaml
# ✅ Good: Use | for preserving newlines
script: |
  #!/bin/bash
  echo "Hello"
  echo "World"

# ✅ Good: Use > for folding newlines
description: >
  This is a long description
  that spans multiple lines
  but will be folded into one.

# ❌ Bad: Long single line
description: "This is a very long description that should span multiple lines for readability but is kept on one line making it hard to read and maintain"
```

### 5. Comments

```yaml
# ✅ Good: Descriptive comments
# Database configuration for production environment
database:
  host: postgres.example.com
  port: 5432
  # Maximum number of connections in the pool
  maxConnections: 100

# ❌ Bad: Obvious or redundant comments
# Database host
host: postgres.example.com  # The host
```

### 6. Resource Organization

```yaml
# ✅ Good: Logical grouping
---
# Namespace
apiVersion: v1
kind: Namespace
metadata:
  name: my-app

---
# ConfigMap
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-config
  namespace: my-app

---
# Deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
  namespace: my-app
```

### 7. Environment-Specific Values

```yaml
# ✅ Good: Use separate values files
# values-dev.yaml
replicaCount: 1
resources:
  requests:
    memory: "256Mi"

# values-prod.yaml
replicaCount: 3
resources:
  requests:
    memory: "1Gi"

# ❌ Bad: Commented-out values
# replicaCount: 1  # dev
replicaCount: 3    # prod
```

## 🚀 Common Tasks

### Review Checklist

When reviewing YAML files, check:

- [ ] Valid YAML syntax (no tabs, proper indentation)
- [ ] Correct Kubernetes API version and kind
- [ ] Required fields present (name, namespace, labels)
- [ ] Resource limits and requests defined
- [ ] Secrets not hardcoded (use external secret management)
- [ ] Proper label selectors
- [ ] Health checks defined (liveness, readiness probes)
- [ ] Security context configured
- [ ] Image tags specified (avoid `latest` in production)
- [ ] Helm template syntax correct (no spaces in braces)
- [ ] Comments are helpful and up-to-date

### Quick Validation Script

```bash
#!/bin/bash
# validate-yaml.sh - Validate all YAML files in project

echo "🔍 Validating YAML files..."

# yamllint
echo "Running yamllint..."
yamllint .

# Kubernetes manifests
echo "Validating Kubernetes manifests..."
find . -name "*.yaml" -path "*/k8s/*" -exec kubectl apply --dry-run=client -f {} \;

# Helm charts
echo "Linting Helm charts..."
find . -name "Chart.yaml" -execdir helm lint . \;

# Docker Compose
echo "Validating Docker Compose files..."
find . -name "docker-compose*.yml" -exec docker compose -f {} config \;

echo "✅ Validation complete!"
```

### Format All YAML Files

```bash
# Using prettier
prettier --write "**/*.{yml,yaml}"

# Using yamlfmt (if installed)
find . -name "*.yaml" -o -name "*.yml" | xargs yamlfmt
```

## 🐛 Troubleshooting

### Common Issues

#### 1. "did not find expected key"

**Cause:** Incorrect indentation or missing colon

```yaml
# ❌ Wrong
metadata
  name: my-pod

# ✅ Correct
metadata:
  name: my-pod
```

#### 2. "mapping values are not allowed here"

**Cause:** Improper quoting or special characters

```yaml
# ❌ Wrong
description: This is: a problem

# ✅ Correct
description: "This is: a problem"
```

#### 3. Helm template parsing errors

**Cause:** Spaces in template delimiters

```yaml
# ❌ Wrong
name: { { .Values.name } }

# ✅ Correct
name: {{ .Values.name }}
```

#### 4. "field is immutable"

**Cause:** Trying to update immutable field in Kubernetes

**Solution:** Delete and recreate the resource:
```bash
kubectl delete -f resource.yaml
kubectl apply -f resource.yaml
```

### Debug Techniques

#### 1. Render Helm Templates Locally

```bash
# See exactly what Kubernetes will receive
helm template my-release ./chart --debug > output.yaml
cat output.yaml
```

#### 2. Check YAML Syntax Online

- [YAML Lint](http://www.yamllint.com/)
- [YAML Validator](https://codebeautify.org/yaml-validator)

#### 3. Compare Rendered Templates

```bash
# Before changes
helm template my-release ./chart > before.yaml

# After changes
helm template my-release ./chart > after.yaml

# Diff
diff before.yaml after.yaml
```

## 📚 Additional Resources

- [Kubernetes YAML Reference](https://kubernetes.io/docs/reference/)
- [Helm Chart Best Practices](https://helm.sh/docs/chart_best_practices/)
- [Docker Compose File Reference](https://docs.docker.com/compose/compose-file/)
- [YAML Specification](https://yaml.org/spec/)
- [yamllint Documentation](https://yamllint.readthedocs.io/)

---

**Pro Tip:** Enable "Format on Save" in VS Code to automatically format YAML files as you work!
