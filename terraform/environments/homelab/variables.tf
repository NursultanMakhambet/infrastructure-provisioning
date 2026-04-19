# --- Proxmox provider ---
variable "proxmox_api_url" {
  type        = string
  description = "Proxmox API endpoint (e.g. https://192.168.1.85:8006/)"
}

variable "proxmox_token_id" {
  type        = string
  description = "Proxmox API token ID (e.g. user@realm!tokenname)"
  sensitive   = true
}

variable "proxmox_token_secret" {
  type        = string
  description = "Proxmox API token secret"
  sensitive   = true
}

variable "proxmox_node" {
  type        = string
  description = "Proxmox node name"
}

variable "proxmox_insecure" {
  type        = bool
  description = "Skip TLS verification for Proxmox API"
  default     = true
}

# --- Scaling (easy to change for more/fewer nodes) ---
variable "db_nodes" {
  type        = number
  description = "Number of DB cluster nodes"
  default     = 3
}

variable "k8s_masters" {
  type        = number
  description = "Number of Kubernetes master nodes"
  default     = 3
}

variable "k8s_workers" {
  type        = number
  description = "Number of Kubernetes worker nodes"
  default     = 2
}

variable "storage_nodes" {
  type        = number
  description = "Number of storage nodes (SeaweedFS etc.)"
  default     = 3
}

variable "aux_enabled" {
  type        = bool
  description = "Provision aux1 (VMID 501) — set false for k8s+db-only homelab"
  default     = false
}

# --- Shared VM settings ---
variable "template_id" {
  type        = number
  description = "Proxmox template VM ID to clone from"
  default     = 9000
}

variable "network_bridge" {
  type        = string
  description = "Proxmox bridge for VMs"
  default     = "vmbr0"
}

variable "gateway" {
  type        = string
  description = "Default gateway for VMs"
  default     = "192.168.1.1"
}

variable "network_prefix" {
  type        = string
  description = "Network prefix for static IPs (e.g. 192.168.1)"
  default     = "192.168.1"
}

variable "ssh_keys" {
  type        = list(string)
  description = "SSH public keys to inject via cloud-init"
  default     = []
}

variable "cloud_init_user" {
  type        = string
  description = "Cloud-init default user"
  default     = "ubuntu"
}

variable "storage" {
  type        = string
  description = "Proxmox storage for VM disks"
  default     = "local-lvm"
}

# --- Resource defaults (override per-group in locals if needed) ---
variable "master_cpu" {
  type        = number
  default     = 2
  description = "CPU cores for K8s masters"
}
variable "master_memory" {
  type        = number
  default     = 4096
  description = "Memory in MiB for K8s masters"
}
variable "master_disk" {
  type        = number
  default     = 10
  description = "Disk size in GiB for K8s masters"
}
variable "worker_cpu" {
  type        = number
  default     = 2
  description = "CPU cores for K8s workers"
}
variable "worker_memory" {
  type        = number
  default     = 4096
  description = "Memory in MiB for K8s workers"
}
variable "worker_disk" {
  type        = number
  default     = 20
  description = "Disk size in GiB for K8s workers"
}
variable "db_cpu" {
  type        = number
  default     = 2
  description = "CPU cores for DB nodes"
}
variable "db_memory" {
  type        = number
  default     = 4096
  description = "Memory in MiB for DB nodes"
}
variable "db_disk" {
  type        = number
  default     = 20
  description = "Disk size in GiB for DB nodes"
}
variable "aux_cpu" {
  type        = number
  default     = 1
  description = "CPU cores for aux node"
}
variable "aux_memory" {
  type        = number
  default     = 2048
  description = "Memory in MiB for aux node"
}
variable "aux_disk" {
  type        = number
  default     = 10
  description = "Disk size in GiB for aux node"
}
variable "storage_cpu" {
  type        = number
  default     = 2
  description = "CPU cores for storage nodes"
}
variable "storage_memory" {
  type        = number
  default     = 4096
  description = "Memory in MiB for storage nodes"
}
variable "storage_disk" {
  type        = number
  default     = 20
  description = "Disk size in GiB for storage nodes"
}
