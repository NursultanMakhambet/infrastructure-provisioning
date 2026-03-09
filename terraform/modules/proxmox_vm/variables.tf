variable "vm_name" {
  type        = string
  description = "VM name in Proxmox (and hostname)"
}

variable "vm_id" {
  type        = number
  description = "Proxmox VM ID (unique per node)"
}

variable "node_name" {
  type        = string
  description = "Proxmox node name where the VM will be created"
}

variable "ip_address" {
  type        = string
  description = "Primary IPv4 address with CIDR (e.g. 192.168.1.101/24)"
}

variable "gateway" {
  type        = string
  description = "Default gateway IPv4 address"
}

variable "cores" {
  type        = number
  description = "Number of CPU cores"
  default     = 2
}

variable "memory" {
  type        = number
  description = "Memory in MiB"
  default     = 4096
}

variable "disk_size" {
  type        = number
  description = "Boot disk size in GiB"
  default     = 40
}

variable "template_id" {
  type        = number
  description = "Proxmox template VM ID to clone from"
  default     = 9000
}

variable "network_bridge" {
  type        = string
  description = "Proxmox bridge for the primary NIC (e.g. vmbr0)"
  default     = "vmbr0"
}

variable "ssh_keys" {
  type        = list(string)
  description = "SSH public keys to inject via cloud-init"
  default     = []
}

variable "cloud_init_user" {
  type        = string
  description = "Username for cloud-init user account"
  default     = "ubuntu"
}

variable "storage" {
  type        = string
  description = "Proxmox storage name for VM disks"
  default     = "local-lvm"
}

variable "on_boot" {
  type        = bool
  description = "Start VM on host boot"
  default     = true
}
