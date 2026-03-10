output "vm_id" {
  description = "Proxmox VM ID"
  value       = proxmox_virtual_environment_vm.this.vm_id
}

output "vm_name" {
  description = "VM name (hostname)"
  value       = proxmox_virtual_environment_vm.this.name
}

output "ip_address" {
  description = "Primary IPv4 address (from cloud-init)"
  value       = var.ip_address
}

output "node_name" {
  description = "Proxmox node where the VM runs"
  value       = proxmox_virtual_environment_vm.this.node_name
}
