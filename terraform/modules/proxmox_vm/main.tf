# Proxmox cloned VM from template (bpg/proxmox 0.98+).
# Uses argument syntax: clone = {}, cpu = {}, memory = {}, disk = {}, network = {}.
# Cloud-init/IP: configure on template or via Proxmox UI after clone (cloned_vm has no initialization in this provider).

resource "proxmox_virtual_environment_cloned_vm" "this" {
  name        = var.vm_name
  node_name   = var.node_name
  description = "Managed by Terraform - ${var.vm_name}"

  clone = {
    source_vm_id    = var.template_id
    full            = true
    target_datastore = var.storage
  }

  cpu = {
    cores = var.cores
  }

  memory = {
    size    = var.memory
    balloon = 0
  }

  disk = {
    scsi0 = {
      size_gb     = var.disk_size
      datastore_id = var.storage
    }
  }

  network = {
    net0 = {
      bridge = var.network_bridge
      model  = "virtio"
    }
  }

  started = true
}
