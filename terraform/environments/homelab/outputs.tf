# Outputs for Ansible inventory generation and reference.

output "vms" {
  description = "All VMs: name, ip, role, vm_id"
  value = {
    for k, v in module.proxmox_vm : k => {
      name   = v.vm_name
      ip     = trimsuffix(v.ip_address, "/24")
      role   = local.all_vms[k].role
      vm_id  = v.vm_id
      node   = v.node_name
    }
  }
}

output "vms_list" {
  description = "Flat list of VM objects for scripts"
  value = [
    for k, v in module.proxmox_vm : {
      key   = k
      name  = v.vm_name
      ip    = trimsuffix(v.ip_address, "/24")
      role  = local.all_vms[k].role
      vm_id = v.vm_id
    }
  ]
}

output "ansible_inventory" {
  description = "Structure for Ansible inventory (matches k8s-baremetal-platform groups: aux, db, storage, k8s_master, k8s_worker)"
  value = {
    all = [
      for k, v in module.proxmox_vm : {
        name = v.vm_name
        ip   = trimsuffix(v.ip_address, "/24")
      }
    ]
    aux = [
      for k, v in module.proxmox_vm : { name = v.vm_name, ip = trimsuffix(v.ip_address, "/24") }
      if local.all_vms[k].role == "aux"
    ]
    db = [
      for k, v in module.proxmox_vm : { name = v.vm_name, ip = trimsuffix(v.ip_address, "/24") }
      if local.all_vms[k].role == "db"
    ]
    storage = [
      for k, v in module.proxmox_vm : { name = v.vm_name, ip = trimsuffix(v.ip_address, "/24") }
      if local.all_vms[k].role == "storage"
    ]
    k8s_master = [
      for k, v in module.proxmox_vm : { name = v.vm_name, ip = trimsuffix(v.ip_address, "/24") }
      if local.all_vms[k].role == "master"
    ]
    k8s_worker = [
      for k, v in module.proxmox_vm : { name = v.vm_name, ip = trimsuffix(v.ip_address, "/24") }
      if local.all_vms[k].role == "worker"
    ]
  }
}

output "proxmox_node" {
  description = "Proxmox node name"
  value       = var.proxmox_node
}
