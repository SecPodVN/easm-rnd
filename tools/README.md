# EASM Platform - CI/CD Pipeline

## Prerequisites

- Proxmox VE server
- GitHub account with this repo
- SSH client

## Pipeline Setup

sudo apt update
sudo apt install openssh-server -y


### 1. Proxmox Template

SSH to Proxmox:
```bash
cd /var/lib/vz/template/iso
wget https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img
qm create 9000 --name ubuntu-2404-cloudinit --memory 4096 --cores 2 --net0 virtio,bridge=vmbr0
qm importdisk 9000 noble-server-cloudimg-amd64.img local-lvm
qm set 9000 --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-9000-disk-0
qm set 9000 --ide2 local-lvm:cloudinit --boot c --bootdisk scsi0
qm set 9000 --serial0 socket --vga serial0 --agent enabled=1
qm set 9000 --ciuser easm-admin --cipassword changeme --ipconfig0 ip=dhcp
qm template 9000
```

Verify:
```bash
qm list | grep 9000
```

### 2. Proxmox API Token

Proxmox UI → Datacenter → Permissions → API Tokens → Add
- User: `root@pam`
- Token ID: `github-actions`
- Uncheck "Privilege Separation"

Copy the secret.

Set permissions:
```bash
pveum acl modify / -token 'root@pam!github-actions' -role Administrator
```

Test:
```bash
curl -k -H "Authorization: PVEAPIToken=root@pam!github-actions=YOUR_SECRET" \
  https://YOUR_PROXMOX_IP:8006/api2/json/version
```

### 3. SSH Keys

Generate:
```bash
ssh-keygen -t ed25519 -f ~/.ssh/easm-github-actions -N ""
cat ~/.ssh/easm-github-actions.pub
```

Add to template (Proxmox):
```bash
cat > /tmp/gh-key.pub << 'EOF'
[paste public key]
EOF
qm set 9000 --sshkeys /tmp/gh-key.pub
```

### 4. GitHub Secrets

Repo → Settings → Secrets and variables → Actions → New repository secret

| Name | Value |
|------|-------|
| `PROXMOX_HOST` | `192.168.1.100:8006` |
| `PROXMOX_TOKEN_ID` | `root@pam!github-actions` |
| `PROXMOX_TOKEN_SECRET` | (secret from step 2) |
| `SSH_PRIVATE_KEY` | `cat ~/.ssh/easm-github-actions` |
| `MS_TEAMS_WEBHOOK` | (optional) Teams webhook URL |

### 5. Workflow Permissions

Settings → Actions → General → Workflow permissions
- Select "Read and write permissions"
- Check "Allow GitHub Actions to create and approve pull requests"

## Run Pipeline

GitHub → Actions → "EASM Platform - CI/CD DevSecOps Pipeline" → Run workflow
- Branch: `feature/cli-dev`
- Environment: `dev`

Wait ~20 minutes.

## Verify Deployment

### Check VM

Proxmox UI → VM 900 running

SSH:
```bash
ssh -i ~/.ssh/easm-github-actions easm-admin@VM_IP
```

### Check Services

```bash
microk8s status
microk8s kubectl get applications -n argocd
microk8s kubectl get pods -n easm-platform

# Check databases
microk8s kubectl get pods -n easm-platform | grep -E 'postgres|redis|mongodb'
```

### Access UIs

Add to `/etc/hosts`:
```
VM_IP  argocd.local easm-api.local easm-frontend.local
```

Get ArgoCD password:
```bash
microk8s kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

- http://argocd.local (admin / password)
- http://easm-api.local
- http://easm-frontend.local

## Auto-Deploy

Push to `feature/cli-dev` triggers pipeline:
```bash
echo "# Test" >> README.md
git add README.md
git commit -m "test: auto deploy"
git push origin feature/cli-dev
```

## Manual Operations

### Ansible

Install dependencies:
```bash
ansible-galaxy install -r ansible/requirements.yml
```

Create inventory:
```bash
cat > ansible/inventory.yml <<EOF
all:
  hosts:
    easm-vm:
      ansible_host: VM_IP
      ansible_user: easm-admin
      ansible_ssh_private_key_file: ~/.ssh/easm-github-actions
      ansible_python_interpreter: /usr/bin/python3
  vars:
    api_image_tag: latest
    frontend_image_tag: latest
    helm_chart_version: 0.1.0
    registry: ghcr.io
    registry_owner: secpodvn
EOF
```

Run:
```bash
ansible-playbook -i ansible/inventory.yml ansible/playbook.yml
```

Test:
```bash
ansible-playbook ansible/playbook.yml --syntax-check
ansible-playbook -i ansible/inventory.yml ansible/playbook.yml --check
```

### ArgoCD

Deploy apps:
```bash
kubectl apply -k k8s/argocd/
```

Check status:
```bash
kubectl get applications -n argocd
kubectl get pods -n easm-platform
```

Manage:
```bash
argocd app list
argocd app sync easm-api
argocd app rollback easm-api
```

## Troubleshooting

| Issue | Fix |
|-------|-----|
| `provision-vm` fails | Test API token with curl |
| `deploy` fails | Verify SSH key in secret |
| `build-*` fails | Check Dockerfile |
| Can't SSH | Verify public key: `qm cloudinit dump 9000 user` |
| VM exists | Delete: `qm stop 900 && qm destroy 900` |
| ArgoCD not syncing | `kubectl describe application easm-api -n argocd` |
| Image pull fails | `kubectl describe pod -n easm-platform -l app=easm-api` |

## Pipeline Architecture

### Jobs

1. `security-scan` - Trivy vulnerability scan
2. `build-api` - Build API Docker image
3. `build-frontend` - Build frontend Docker image
4. `package-charts` - Package Helm charts (OCI)
5. `provision-vm` - Create Proxmox VM
6. `deploy` - Run Ansible playbook
7. `update-argocd` - Update chart versions
8. `notify` - Teams notification

### Resources

- Template ID: 9000
- VM ID: 900
- VM user: `easm-admin`
- Images: `ghcr.io/secpodvn/easm-rnd/easm-api`, `easm-frontend`
- Charts: `oci://ghcr.io/secpodvn/charts/easm-api`, `easm-frontend`
- Namespaces: `argocd`, `easm-platform`
- Databases: PostgreSQL, Redis, MongoDB (deployed via Bitnami Helm charts)

### Key Files

```
.github/workflows/deploy-proxmox.yml  ← Pipeline
ansible/playbook.yml                  ← VM automation
k8s/argocd/*.yaml                     ← ArgoCD apps
src/charts/                           ← Helm charts
```

### Variables

#### Ansible

| Variable | Default |
|----------|---------|
| `registry` | `ghcr.io` |
| `registry_owner` | `secpodvn` |
| `api_image_tag` | `latest` |
| `frontend_image_tag` | `latest` |
| `helm_chart_version` | `0.1.0` |
| `metallb_ip_range` | `192.168.1.200-192.168.1.210` |

#### ArgoCD

Charts use OCI format from GHCR:
```yaml
source:
  chart: easm-api
  repoURL: oci://ghcr.io/secpodvn/charts
  targetRevision: 0.1.0-abc123
helm:
  values: |
    image:
      repository: ghcr.io/secpodvn/easm-rnd/easm-api
      tag: latest
```
