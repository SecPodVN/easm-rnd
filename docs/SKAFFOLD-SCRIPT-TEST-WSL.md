# How to up the project with SKAFFOLD script in WSL

As the name suggest.

## Prerequisites

* Windows 10/11 with WSL2 enabled.
* Ubuntu (or another Debian-based distro) installed from Microsoft Store and set as default WSL distro.
* Windows Terminal or another terminal able to launch `wsl`/Ubuntu.

> Confirm WSL version:

```bash
wsl --status
# or inside WSL
cat /etc/os-release
uname -r
```

WSL must be v2. If not, upgrade per Microsoft docs before continuing.

---

## 1 — Enable systemd in WSL (required for `systemctl` / services)

1. Edit `/etc/wsl.conf`:

```bash
sudo nano /etc/wsl.conf
```

Add exactly:

```ini
[boot]
systemd=true
```

2. Exit WSL and apply changes from Windows PowerShell / Command Prompt:

```powershell
wsl --shutdown
# reopen your Ubuntu distro afterwards
```

3. Verify systemd is available inside WSL:

```bash
ps -p 1 -o comm=
# expected output: systemd
```

If systemd is not present, re-check `/etc/wsl.conf` and that you restarted WSL with `wsl --shutdown`.

---

## 2 — Install Docker Engine (correct method)

> Note: `sudo apt install docker` is a placeholder package on Ubuntu and **will not** provide a usable `docker.service`.

Run inside WSL (Ubuntu):

```bash
sudo apt update
sudo apt install -y ca-certificates curl gnupg

sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io
```

Add your user to the `docker` group (so you can run Docker without `sudo`):

```bash
sudo usermod -aG docker $USER
```

Apply the group change by logging out / restarting WSL


Start Docker (systemd must be enabled):

```bash
sudo systemctl start docker
sudo systemctl enable docker
# or
sudo service docker start

# confirm
docker version
docker ps
```

Expected: `docker version` shows Engine and Client, `docker ps` returns an empty list (no error).

---

## 3 — Install kubectl (optional but recommended)

```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
kubectl version --client --short
```

---

## 4 — Install Minikube

Download and install the minikube binary inside WSL:

```bash
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
minikube version
```

---

## 5 — Start Minikube using the Docker driver (skip to step 8 since the script handles this)

Ensure Docker daemon is running. Then:

```bash
minikube start --driver=docker
```

Verify cluster:

```bash
kubectl get nodes
kubectl get pods -A
```

Expected: one `Ready` node and system pods running in `kube-system`.

---

## 6 — Install Helm

```bash
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
helm version

```
---

## 7 — Install Skaffold

```bash
curl -Lo skaffold https://storage.googleapis.com/skaffold/releases/latest/skaffold-linux-amd64
sudo install skaffold /usr/local/bin/skaffold
skaffold version
```

---
## 8 — Running `.sh` scripts and verifying them

* Execute directly inside WSL: `bash ./skaffold.sh` or `./skaffold.sh` (ensure `chmod +x`).
* From Windows PowerShell you can run the script inside WSL:

```powershell
wsl bash ./skaffold.sh
# or
wsl ./skaffold.sh
```
---
