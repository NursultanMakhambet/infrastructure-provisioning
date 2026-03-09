# Proxmox provider configuration.
# Uses variables so values can be passed via tfvars or env (e.g. TF_VAR_proxmox_token_secret).
# Canonical definition; ensure environments/homelab/providers.tf stays in sync when changing.

variable "proxmox_api_url" {
  type        = string
  description = "Proxmox API endpoint URL (e.g. https://192.168.1.85:8006/)"
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
  description = "Proxmox node name where VMs will be created"
}

variable "proxmox_insecure" {
  type        = bool
  description = "Skip TLS verification for Proxmox API"
  default     = true
}

provider "proxmox" {
  endpoint  = var.proxmox_api_url
  api_token = "${var.proxmox_token_id}=${var.proxmox_token_secret}"
  insecure  = var.proxmox_insecure

  ssh {
    agent = true
  }
}
