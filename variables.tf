variable "admin_user" {
  description = "SSH user for the remote libvirt host"
  type        = string
}

variable "remote_host" {
  description = "Remote libvirt host address"
  type        = string
}

variable "ssh_private_key" {
  description = "Path to SSH private key for remote host"
  type        = string
}

variable "root_password" {
  description = "Root password for the VMs"
  type        = string
  default     = "opensuse123"
}

variable "student_password" {
  description = "Student user password for the VMs"
  type        = string
  default     = "student123"
}

variable "ssh_public_key" {
  description = "SSH public key for the remote host"
  type        = string
  default     = "AAAAB3NzaC1yc2EAAAADAQABAAACAQDGyeWvR8NSlP50wX4fs51nEYdokOQ//VMkwT+iDQ/Fj1oVJa8n+2dj4C1aClAgJ6Wx0RSeBpujAwFSpYSsGtr3Xr8R+5p1/0zmkMXtLF+RQRPtA+1rcxJBJ4LXM60NCXut7vt98+hNZx83NGmsHgGVuvNbdcxfscfxZ3S3oblpyVyJ5DFFnDNFgvzq1+qhK37e+TQyydY4CihilXH6fqphFFjKF9LVp2x2eOWlja5OuEbVGLKlO6wTC0Phf4fn+I2+44ocrYg0tHkX73+cNNx/w3zKW0uwf455tqNULc7/5QFd4d/fWpAZaCJTBoL80SVNd9OmnFNIx54chumicRCXbJLeRu5cdfIO6QqYVSt+Fyjr7Tgy1+Q8VNXcENcY9Y/b2qXjiZclg6Ayw8CVkiUi3M9xsa3lrPXtqxmmpSCUogwgpuMhEmcgQjNRYxTRNCw92dlN1uOR9r0ZVCqVanEYqylL0ZVbrqw76470v4HCSp6VdsI77jph6rWiwWWdnKGxC5mTWfvADW8TsytfCBtBgFVCBRZfuQrdlDWaDnXblBz/hZKDU4QdmYXvy2DtrMlilD1/oeU7Ths6Af4HMfL9VHVXp441/HMvgwY55QhCRK4fUo9QDS9xC+kTwKC1aNccR9WtM4JIj7p7TtLtHPp3zKfA8eHB5mOJE5JsltYPKw=="
}

variable "ssh_public_key_email" {
  description = "Email address for the SSH public key"
  type        = string
  default     = "root@initd-cloud"
}
# Master nodes get more resources (control plane)
variable "master_memory" {
  description = "Memory in MB for each master node (3 masters total)"
  type        = number
  default     = 4194304 # 4GB per master = 12GB total for masters
}

variable "master_vcpu" {
  description = "Number of vCPUs for each master node"
  type        = number
  default     = 2 # 2 vCPUs per master = 6 vCPUs total for masters
}

# Worker nodes get balanced resources
variable "worker_memory" {
  description = "Memory in MB for each worker node (6 workers total)"
  type        = number
  default     = 2097152 # 2GB per worker = 12GB total for workers
}

variable "worker_vcpu" {
  description = "Number of vCPUs for each worker node"
  type        = number
  default     = 1 # 1 vCPU per worker = 6 vCPUs total for workers
}

variable "vm_volume_size" {
  description = "Size of VM disk in bytes (20GB default for openSUSE)"
  type        = number
  default     = 21474836480 # 20GB
}
