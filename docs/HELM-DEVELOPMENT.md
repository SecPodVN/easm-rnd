# Helm Chart Development Guide

This guide provides quick references for developing and testing Helm charts in VS Code.

## 🔧 VS Code Features

### File Associations

- **Helm Templates**: `.yaml` and `.tpl` files in `**/charts/**/templates/` are associated with Helm language server
- **Values Files**: `values*.yaml` files get Helm values schema validation
- **Chart.yaml**: Gets JSON schema validation

### IntelliSense & Autocompletion

- **Helm Functions**: Autocomplete for Helm template functions (`.Values`, `.Release`, etc.)
- **Kubernetes Resources**: Autocomplete for K8s resource types and fields
- **Values**: Autocomplete from `values.yaml` when typing `.Values.`

### Syntax Highlighting

- Helm template delimiters: `{{ }}`, `{{- }}`, `{{ -}}`
- Go template functions and pipelines
- YAML syntax within templates

## 🎯 Quick Tasks

Access tasks via: `Ctrl+Shift+P` → "Tasks: Run Task"

### Helm-Specific Tasks

1. **Validate Helm Chart**
   - Runs: `helm lint <chart-directory>`
   - Use: Validate chart structure and templates

2. **Render Helm Template**
   - Runs: `helm template test-release <chart> --debug`
   - Use: Preview rendered manifests without installation

3. **Helm: Template with Values**
   - Runs: `helm template <release> <chart> --values <values-file>`
   - Use: Test different value configurations

4. **Helm: Dry-Run Install**
   - Runs: `helm install <release> <chart> --dry-run --debug`
   - Use: Simulate installation and see what would be created

5. **Helm: Show Computed Values**
   - Runs: `helm show values <chart>`
   - Use: View default values from Chart

6. **Helm: Get Manifest**
   - Runs: `helm get manifest <release>`
   - Use: View deployed manifests from active release

7. **Helm: Get Values**
   - Runs: `helm get values <release>`
   - Use: View values used in deployed release

8. **Helm: Lint All Charts**
   - Runs: Lints all charts in `src/charts/`
   - Use: Validate all project charts at once

### Kubernetes Tasks

9. **Validate Kubernetes YAML**
   - Runs: `kubectl apply --dry-run=client -f <file>`
   - Use: Validate K8s manifests

10. **Get Kubernetes Resources**
    - Runs: `kubectl get all -n <namespace>`
    - Use: List all resources in namespace

11. **Describe Kubernetes Resource**
    - Runs: `kubectl describe <type> <name> -n <namespace>`
    - Use: Get detailed resource information

## 📝 Helm Template Syntax

### Common Template Functions

```yaml
# Access values from values.yaml
{{ .Values.image.repository }}

# Include helper templates
{{ include "chart.fullname" . }}

# Quote strings
{{ .Values.service.port | quote }}

# Default values
{{ .Values.optional | default "default-value" }}

# Conditionals
{{- if .Values.ingress.enabled }}
apiVersion: networking.k8s.io/v1
kind: Ingress
{{- end }}

# Loops
{{- range .Values.env }}
- name: {{ .name }}
  value: {{ .value }}
{{- end }}

# String manipulation
{{ .Values.name | upper }}
{{ .Values.name | lower }}
{{ .Values.name | title }}
{{ .Values.name | trim }}

# Release info
{{ .Release.Name }}
{{ .Release.Namespace }}
{{ .Release.Service }}

# Chart info
{{ .Chart.Name }}
{{ .Chart.Version }}
{{ .Chart.AppVersion }}
```

### Whitespace Control

```yaml
# Remove preceding whitespace
{{- if .condition }}

# Remove following whitespace
{{ .value -}}

# Remove both
{{- .value -}}
```

## 🧪 Testing Workflow

### Local Development

```bash
# 1. Edit template or values
code src/charts/easm-api/templates/deployment.yaml

# 2. Lint the chart
helm lint src/charts/easm-api

# 3. Render templates locally
helm template easm-api src/charts/easm-api \
  --values src/charts/easm-api/values.yaml \
  --debug

# 4. Dry-run install
helm install easm-api src/charts/easm-api \
  --dry-run --debug \
  --namespace easm-rnd

# 5. Deploy with Skaffold
skaffold dev
```

### Preview Values

```bash
# Show default values
helm show values src/charts/easm-api

# Template with specific values file
helm template easm-api src/charts/easm-api \
  --values src/charts/easm-api/values-dev.yaml

# Override specific values
helm template easm-api src/charts/easm-api \
  --set image.tag=v1.2.3 \
  --set replicaCount=3
```

## 🔍 Debugging

### Check Rendered Output

```bash
# Full debug output
helm install easm-api src/charts/easm-api \
  --dry-run --debug

# Show specific template
helm template easm-api src/charts/easm-api \
  --show-only templates/deployment.yaml
```

### Common Issues

1. **YAML Syntax Errors**
   - Check for proper indentation (2 spaces)
   - Ensure no tabs are used
   - Validate quotes and special characters

2. **Template Syntax Errors**
   - Ensure `{{` and `}}` have no spaces: `{{ }}` not `{ { } }`
   - Check matching `{{- if }}` and `{{- end }}`
   - Verify helper template names match `_helpers.tpl`

3. **Missing Values**
   - Use `| default "value"` for optional fields
   - Check values.yaml has all required fields
   - Use `required` function for mandatory values:
     ```yaml
     {{ required "A valid .Values.image.repository is required!" .Values.image.repository }}
     ```

## 📚 Best Practices

### Chart Structure

```
src/charts/easm-api/
├── Chart.yaml              # Chart metadata
├── values.yaml             # Default values
├── values-dev.yaml         # Development overrides
├── values-staging.yaml     # Staging overrides
├── values-prod.yaml        # Production overrides
├── templates/
│   ├── _helpers.tpl        # Helper templates
│   ├── deployment.yaml     # Deployment resource
│   ├── service.yaml        # Service resource
│   ├── ingress.yaml        # Ingress resource
│   ├── configmap.yaml      # ConfigMap resource
│   ├── secret.yaml         # Secret resource
│   └── serviceaccount.yaml # ServiceAccount resource
└── README.md               # Chart documentation
```

### Template Guidelines

1. **Use Helpers**: Define common labels in `_helpers.tpl`
2. **Validate Input**: Use `required` for mandatory values
3. **Provide Defaults**: Use `default` for optional values
4. **Quote Strings**: Always quote string values
5. **Comment Templates**: Add comments for complex logic
6. **Test Thoroughly**: Test with different values files

### Values File Structure

```yaml
# Good: Organized and documented
image:
  repository: easm-api
  tag: latest
  pullPolicy: IfNotPresent

# Bad: Flat and unclear
imageRepository: easm-api
imageTag: latest
imagePullPolicy: IfNotPresent
```

## 🚀 Keyboard Shortcuts

- **Format Document**: `Shift+Alt+F`
- **Quick Open File**: `Ctrl+P`
- **Go to Symbol**: `Ctrl+Shift+O`
- **Find References**: `Shift+F12`
- **Command Palette**: `Ctrl+Shift+P`
- **Run Task**: `Ctrl+Shift+B`

## 📖 Resources

- [Helm Documentation](https://helm.sh/docs/)
- [Helm Chart Best Practices](https://helm.sh/docs/chart_best_practices/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Go Template Documentation](https://pkg.go.dev/text/template)

---

**Need Help?** Press `Ctrl+Shift+P` and type "Helm" to see all available Helm commands.
