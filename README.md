# ACP Installation – Ansible Installation

This project provides an **Ansible-based preflight validation framework** for preparing nodes before installing Alauda Container Platform (ACP).

It is designed for a single cluster with basic setup:

* **3 Master nodes**
* **6 Worker nodes**

The role is built to work with **RPM-based systems**, including:

* SUSE MicroOS *(with caveats)*
* Rocky Linux
* Ubuntu *(partial compatibility)*

**NB** : If you are using Suse MicrOS read [documentation](/docs/Configure_MicroOS_for_Alauda.md) of how to create ISO based on cloud init disk for master and works represent for Alauda.
  
---

## 📁 Project Structure

```bash
acp-installation/
├── inventory.yml
├── site.yml
└── roles/
    └── preflight_checks/
        ├── tasks/
        │   └── main.yml
        ├── defaults/
        │   └── main.yml
        └── README.md
```

---

## 🚀 What This Does

The `preflight_checks` role validates that all nodes meet Kubernetes/ACP prerequisites:

### ✅ Checks Included

* Installed RPM packages (Docker, Podman, Kubernetes components)
* Container runtimes:

  * podman
  * docker
  * containerd
  * crio
* Required system tools:

  * curl, socat, conntrack, iptables, awk
* Kernel modules:

  * `br_netfilter`
* Sysctl parameters:

  * `net.ipv4.ip_forward`
  * `net.bridge.bridge-nf-call-iptables`
* Swap status (must be disabled)
* Cgroup configuration

---

## ⚠️ Important Notes (MicroOS Users)

SUSE MicroOS differs significantly from RHEL-based systems:

* Read-only root filesystem
* Uses `transactional-update` for package installs
* Defaults to **Podman**, not Docker/containerd
* Typically uses **cgroup v2**

👉 ACP installers often expect:

* `containerd` runtime
* Writable filesystem paths
* Traditional package management

**Recommendation:**
For production environments, prefer:

* Rocky Linux
* or Ubuntu

---

## 🖥️ Inventory Configuration

Edit `inventory.ini`:

```ini
[masters]
master1 ansible_host=192.168.1.10
master2 ansible_host=192.168.1.11
master3 ansible_host=192.168.1.12

[workers]
worker1 ansible_host=192.168.1.20
worker2 ansible_host=192.168.1.21
worker3 ansible_host=192.168.1.22
worker4 ansible_host=192.168.1.23
worker5 ansible_host=192.168.1.24
worker6 ansible_host=192.168.1.25

[all:vars]
ansible_user=root
ansible_ssh_private_key_file=~/.ssh/id_rsa
```

---

## ▶️ Running the Playbook

Execute:

```bash
ansible-playbook -i inventory.yml site.yml
```

---

## 🔐 SSH Setup (if required)

Copy your SSH key to all nodes:

```bash
ssh-copy-id root@<node-ip>
```

Or run with password authentication:

```bash
ansible-playbook -i inventory.ini acp-installation.yml -k
```

---

## ⚙️ Customization

Default variables are defined in:

```
roles/preflight_checks/defaults/main.yml
```

Example:

```yaml
rpm_packages:
  - docker
  - podman
  - containerd

required_tools:
  - curl
  - socat
  - conntrack
```

Override these per environment if needed.

---

## 🔥 Recommended Next Steps

This role currently **validates** the environment but does not enforce compliance.

For a production-ready ACP setup, consider adding:

### 1. Auto-remediation role

* Install missing packages
* Configure container runtime (containerd)
* Apply sysctl settings
* Load kernel modules

### 2. Container runtime setup

Create a role:

```
roles/container_runtime/
```

To:

* Install and configure `containerd`
* Align with Kubernetes requirements

### 3. Kubernetes bootstrap

* kubeadm init (masters)
* kubeadm join (workers)
* Networking (Calico / Flannel)

---

## 🧠 Troubleshooting

### Common Issues

| Issue                     | Cause                          |
| ------------------------- | ------------------------------ |
| container runtime missing | MicroOS uses Podman by default |
| sysctl not applied        | Kernel module not loaded       |
| swap still enabled        | `/etc/fstab` not updated       |
| cgroup mismatch           | MicroOS defaults to cgroup v2  |

---

## 📌 Summary

* ✔ Modular Ansible role for preflight validation
* ✔ Works across 9-node cluster
* ✔ Easily extensible for full ACP automation
* ⚠️ MicroOS requires extra care and customization

---

## 🤝 Contributing

Feel free to extend:

* Add remediation tasks
* Add OS-specific handling
* Improve validation logic

---

## Reference

[Download MicroOS ISO](https://en.opensuse.org/Portal:MicroOS/Downloads)