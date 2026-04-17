Got it — this is now a **Kubernetes VM bootstrap cloud-init ISO generator**, not RHCSA. You already have a solid templating + inventory + mkisofs workflow, so the README should reflect that cleanly and practically.

Here’s your **refactored README** aligned exactly to your script and structure.

---

# 📘 Kubernetes Cloud-Init ISO Generator (VMware / vSphere / KVM Compatible)

This project generates **cloud-init ISO images** for provisioning Kubernetes nodes (masters + workers) using a **template-driven approach**.

It is designed for:

* 🐳 Kubernetes clusters (custom VM-based, not kubeadm dependency here yet)
* ☁️ VMware vSphere / ESXi
* 🖥️ KVM / libvirt / Proxmox
* ⚙️ Fully automated VM bootstrapping via cloud-init ISO

---

# 🧱 Project Overview

You define:

* 🟣 Master nodes → `inventory/masters.txt`
* 🔵 Worker nodes → `inventory/workers.txt`
* 🧩 Templates → `templates/`
* ⚙️ Generator script → `generate-cloud-init.sh`

Then the system produces:

```
cloud-init-output/
├── master-1.iso
├── master-2.iso
├── worker-1.iso
├── worker-2.iso
...
```

Each ISO is a **cloud-init seed disk** ready to attach to a VM.

---

# 📁 Project Structure

```text id="a7kq1p"
.
├── generate-cloud-init.sh
├── inventory/
│   ├── masters.txt
│   └── workers.txt
│
├── templates/
│   ├── user-data.tpl
│   └── meta-data.tpl
│
└── cloud-init-output/
```

---

# ⚙️ How It Works

```id="k2w9zd"
inventory (masters/workers)
        ↓
template rendering (envsubst)
        ↓
cloud-init seed files
        ↓
mkisofs / xorriso
        ↓
ISO per node
        ↓
attach to VM (vSphere / KVM)
```

---

# 🖥️ Inventory Format

## masters.txt

```text id="q9m2xv"
master-1
master-2
master-3
```

## workers.txt

```text id="p8d3ab"
worker-1
worker-2
worker-3
worker-4
worker-5
worker-6
```

---

# 🧩 Templates

## 📄 `templates/user-data.tpl`

```yaml id="l3p9qz"
#cloud-config

users:
  - name: root
    ssh_authorized_keys:
      - ${SSH_PUB_KEY}

write_files:
  - path: /etc/hostname
    content: ${HOSTNAME}

runcmd:
  - hostnamectl set-hostname ${HOSTNAME}
```

---

## 📄 `templates/meta-data.tpl`

```yaml id="z8v1mk"
instance-id: ${HOSTNAME}
local-hostname: ${HOSTNAME}
```

---

# ⚙️ Generator Script

## 📄 `generate-cloud-init.sh`

### Features

* Supports SSH key injection
* Uses `envsubst` for templating
* Generates ISO per node
* Supports both `mkisofs` and `xorriso`
* Reads from inventory files
* Cleans temporary workspace automatically

---

### Usage

```bash id="u3c9xn"
chmod +x generate-cloud-init.sh
./generate-cloud-init.sh ~/.ssh/id_rsa.pub
```

If no key is provided:

```bash
./generate-cloud-init.sh
```

(Default: `~/.ssh/swarm_key.pub`)

---

# 🚀 Output

Generated ISOs:

```text id="r4k8pl"
cloud-init-output/
├── master-1.iso
├── master-2.iso
├── master-3.iso
├── worker-1.iso
├── worker-2.iso
├── worker-3.iso
├── worker-4.iso
├── worker-5.iso
├── worker-6.iso
```

---

# 💿 How to Use in VMware vSphere

## Step 1 — Upload ISO

Upload each ISO to datastore:

```
cloud-init-output/master-1.iso
```

---

## Step 2 — Attach to VM

In vSphere:

* Edit VM settings
* Add CD/DVD Drive
* Select ISO from datastore
* Enable:

  ```
  ✔ Connect at power on
  ```

---

## Step 3 — Boot VM

On first boot:

cloud-init will:

* set hostname
* inject SSH key
* configure system identity
* execute startup commands

---

# 🔐 SSH Access Model

All nodes are provisioned with:

```text id="x1p7vq"
root SSH access via public key injection
```

So after boot:

```bash
ssh root@<node-ip>
```

---

# ⚡ Design Principles

### 1. Template-driven (NOT hardcoded)

* user-data.tpl
* meta-data.tpl

---

### 2. Inventory-based scaling

* Add node → just edit text file
* No script changes required

---

### 3. Fully stateless generation

* No cloud dependency
* No API calls
* Works offline

---

### 4. Portable across platforms

✔ VMware vSphere
✔ KVM / libvirt
✔ Proxmox
✔ Bare-metal ISO boot

---

# 🧪 Example Workflow

## 1. Add nodes

```text
inventory/masters.txt
inventory/workers.txt
```

---

## 2. Generate ISOs

```bash
./generate-cloud-init.sh ~/.ssh/swarm_key.pub
```

---

## 3. Attach ISOs to VMs

* master-1.iso → VM1
* worker-1.iso → VM2
* etc.

---

## 4. Boot cluster

Nodes come up already configured with:

* hostname set
* SSH access enabled
* identity applied

---

# 🧠 Why This Design Works Well for Kubernetes Labs

* Predictable node naming
* Reproducible environments
* Fast cluster rebuilds
* No manual OS configuration
* Works for HA / multi-master setups
* Ideal for kubeadm / k3s / RKE2 bootstrap phases

---

# 🔥 Optional Improvements (if you extend later)

You can evolve this into:

### Kubernetes bootstrap layer

* kubeadm init/join embedded in user-data
* auto discovery of control-plane endpoint

### Parallel ISO generation

* GNU parallel or background jobs

### GitHub Actions integration

* auto-generate ISOs per commit

### Terraform vSphere integration

* ISO attachment automated per VM

---
