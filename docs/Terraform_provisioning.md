# 📘 RCHSA LAB Infrastructure (Terraform + GitHub Actions)

This repository provisions a **RHCSA-style lab environment** using:

* 🖥️ 3 Master nodes (control/primary systems)
* 🖥️ 6 Worker nodes (student/exam nodes)
* ⚙️ Terraform (libvirt provider over SSH)
* ☁️ S3/MinIO backend for state
* 🚀 GitHub Actions for deploy / check / destroy workflows
* 🔐 SSH jump-host execution model

---

## 🧱 Architecture Overview

```bash
GitHub Actions Runner
        │
        ▼
   Jump Host (SSH)
        │
        ▼
  KVM/libvirt Host (remote)
        │
        ▼
  ┌───────────────────────────────┐
  │     RHCSA LAB ENVIRONMENT     │
  ├──────────────┬───────────────┤
  │ 3 Masters    │ 6 Workers     │
  │ infra node   │ services host │
  └──────────────┴───────────────┘
```

---

## 🗂️ Project Structure

```bash
.
├── main.tf
├── variables.tf
├── terraform.tfvars
├── scripts/
│   ├── deploy.sh
│   ├── check.sh
│   └── delete.sh
│
├── .github/
│   └── workflows/
│       ├── deploy.yml
│       ├── check.yml
│       └── delete.yml
│
└── README.md
```

---

## 🖥️ Infrastructure Layout

### Masters (3 VMs)

| Name     | IP             | Purpose                    |
| -------- | -------------- | -------------------------- |
| master-1 | 172.168.122.10 | Control node               |
| master-2 | 172.168.122.11 | Control node               |
| master-3 | 172.168.122.12 | Control / HA / API testing |

---

### Workers (6 VMs)

| Name     | IP             |
| -------- | -------------- |
| worker-1 | 172.168.122.20 |
| worker-2 | 172.168.122.21 |
| worker-3 | 172.168.122.22 |
| worker-4 | 172.168.122.23 |
| worker-5 | 172.168.122.24 |
| worker-6 | 172.168.122.25 |

---

## ⚙️ Terraform Design

### Key Characteristics

* ❌ No loops (explicit resources only)
* ❌ No modules (single-file clarity)
* ✅ One provider (libvirt over SSH)
* ✅ cloud-init per VM
* ✅ static IP assignment
* ✅ shared base image backing store

---

## 🚀 How It Works

## 1. Terraform Backend

State is stored in S3 / MinIO:

```bash
backend "s3" {}
```

Configured dynamically via GitHub Secrets:

* TF_STATE_BUCKET
* TF_STATE_REGION
* TF_STATE_ENDPOINT
* TF_STATE_ACCESS_KEY
* TF_STATE_SECRET_KEY

---

## 2. Execution Flow

### Deploy Pipeline

```bash
GitHub → SSH Jump Host → Terraform apply → VMs created
```

### Check Pipeline

```bash
GitHub → SSH Jump Host → terraform plan → validation
```

### Destroy Pipeline

```bash
GitHub → SSH Jump Host → terraform destroy → cleanup
```

---

## 🧪 Scripts

## deploy.sh

* Initializes Terraform
* Configures backend (S3 or local)
* Runs `terraform apply -auto-approve`

## check.sh

* Runs `terraform plan`
* Validates environment variables
* Ensures backend connectivity

## delete.sh

* Runs `terraform destroy -auto-approve`
* Cleans up full environment

---

## 🔐 Authentication Model

### SSH Flow

```bash
GitHub Actions
   ↓
Jump Host (SSH key)
   ↓
Libvirt host (SSH URI provider)
```

Terraform provider:

```hcl
provider "libvirt" {
  uri = "qemu+ssh://${var.admin_user}@${var.remote_host}/system?keyfile=${var.ssh_private_key}&no_verify=1"
}
```

---

## 💾 Cloud Image Strategy

Base image:

* Fedora Cloud 43 QCOW2
* Shared backing store volume

Each VM:

* Own disk
* Backed by base image
* cloud-init injected ISO

---

## 🧩 Cloud-Init Responsibilities

Each node configures:

### Masters

* SSH access
* root + student user
* static IP
* exam tooling baseline

### Workers

* minimal system
* student accounts
* networking config

---

## 🧪 GitHub Actions

### deploy.yml

* Trigger: push to `apply`
* Runs: terraform apply
* Sends:

  * Telegram notification
  * MS Teams notification

---

### check.yml

* Trigger: push to `main`
* Runs:

  * terraform plan
  * validation checks

---

### delete.yml

* Trigger: manual
* Runs:

  * terraform destroy
  * full teardown notifications

---

## 🔥 Key Design Decisions

### 1. No Terraform loops

You explicitly define:

* vm1 … vm9 resources
* cloudinit1 … cloudinit9
* disks per VM

✔ Reason: clarity for exam-style environments and debugging

---

### 2. SSH-based remote provider

All provisioning happens on:

```bash
libvirt host via SSH URI
```

Not local execution.

---

### 3. Stateless CI execution

GitHub runner:

* does NOT hold state
* only triggers scripts
* uses S3 backend

---

## 🧠 Operational Notes

### First Run

```bash
./scripts/deploy.sh \
  -b tf-state \
  -r us-east-1 \
  -e http://minio:9000 \
  -a minioadmin \
  -s minioadmin
```

---

### Validate

```bash
./scripts/check.sh
```

---

### Destroy

```bash
./scripts/delete.sh
```

---

### ⚠️ Known Constraints

* No scaling (no loops used by design)
* Long Terraform file (intentional)
* Static IP allocation required
* Requires working libvirt SSH access
* Jump host must resolve libvirt host

---
