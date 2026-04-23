resource "terraform_data" "firmware_profile" {
  input = {
    machine         = var.machine
    bios            = var.bios
    enable_efi_disk = var.enable_efi_disk
    efi_disk_type   = var.efi_disk_type
  }
}

resource "proxmox_virtual_environment_vm" "this" {
  name        = var.vm_name
  vm_id       = var.vm_id
  node_name   = var.node_name
  description = "Managed by Terraform - ${var.vm_name}"
  on_boot     = var.on_boot
  started     = true
  machine     = var.machine
  bios        = var.bios

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

  dynamic "efi_disk" {
    for_each = var.enable_efi_disk ? [1] : []
    content {
      datastore_id = coalesce(var.efi_disk_datastore_id, var.storage)
      type         = var.efi_disk_type
    }
  }

  network_device {
    bridge = var.network_bridge
    model  = "virtio"
  }

  dynamic "vga" {
    for_each = var.vga_type == null ? [] : [1]
    content {
      type = var.vga_type
    }
  }

  dynamic "serial_device" {
    for_each = var.serial_devices
    content {
      device = serial_device.value
    }
  }

  dynamic "hostpci" {
    for_each = var.hostpci_devices
    content {
      device = hostpci.value.device
      id     = hostpci.value.id
      pcie   = try(hostpci.value.pcie, null)
      xvga   = try(hostpci.value.xvga, null)
    }
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

  lifecycle {
    replace_triggered_by = [
      terraform_data.firmware_profile,
    ]
    ignore_changes = [
      hostpci,
    ]
  }
}
