variable "environment" {
  type        = string
  description = "Environment name (e.g. homelab)"
  default     = "homelab"
}

variable "cidr" {
  type        = string
  description = "Primary network CIDR (e.g. 192.168.1.0/24)"
  default     = "192.168.1.0/24"
}
