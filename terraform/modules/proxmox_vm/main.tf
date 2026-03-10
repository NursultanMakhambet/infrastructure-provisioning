resource "proxmox_virtual_environment_vm" "this" {
  name        = var.vm_name
  vm_id       = var.vm_id
  node_name   = var.node_name
  description = "Managed by Terraform - ${var.vm_name}"
  on_boot     = var.on_boot
  started     = true

  clone {
    vm_id = var.template_id
    full  = true
  }

  cpu {
    cores = var.cores
    type  = "host"
  }

  memory {
    dedicated = var.memory
    floating  = 0
  }

  disk {
    interface    = "scsi0"
    size         = var.disk_size
    datastore_id = var.storage
  }

  network_device {
    bridge = var.network_bridge
    model  = "virtio"
  }

  initialization {
    datastore_id = var.storage

    ip_config {
      ipv4 {
        address = var.ip_address
        gateway = var.gateway
      }
    }

    user_account {
      username = var.cloud_init_user
      keys     = var.ssh_keys
    }
  }
}
