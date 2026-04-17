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

# Master nodes get more resources (control plane)
variable "master_memory" {
  description = "Memory in MB for each master node (3 masters total)"
  type        = number
  default     = 4096 # 4GB per master = 12GB total for masters
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
  default     = 2048 # 2GB per worker = 12GB total for workers
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
