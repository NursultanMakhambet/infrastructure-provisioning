# Homelab environment: Proxmox VMs for DevOps / platform engineering.
# VMs are created from template (VMID 9000), use virtio on vmbr0, cloud-init for IP and SSH.

locals {
  gateway = var.gateway
  prefix  = var.network_prefix
  node    = var.proxmox_node
  bridge  = var.network_bridge
  tmpl    = var.template_id

  # Aux node (single) — optional
  aux_vms = var.aux_enabled ? {
    "aux1" = {
      hostname = "aux1.node.local"
      vm_id    = 501
      ip       = "${local.prefix}.190"
      role     = "aux"
      cpu      = var.aux_cpu
      memory   = var.aux_memory
      disk     = var.aux_disk
    }
  } : {}

  # DB cluster (VM IDs 301+)
  db_vms = {
    for i in range(1, var.db_nodes + 1) :
    "db${i}" => {
      hostname = "db${i}.node.local"
      vm_id    = 300 + i
      ip       = "${local.prefix}.${110 + (i - 1)}"
      role     = "db"
      cpu      = var.db_cpu
      memory   = var.db_memory
      disk     = var.db_disk
    }
  }

  # Kubernetes masters (VM IDs 101+)
  master_vms = {
    for i in range(1, var.k8s_masters + 1) :
    "master${i}" => {
      hostname = "master${i}.k8s.local"
      vm_id    = 100 + i
      ip       = "${local.prefix}.${101 + (i - 1)}"
      role     = "master"
      cpu      = var.master_cpu
      memory   = var.master_memory
      disk     = var.master_disk
    }
  }

  # Kubernetes workers (VM IDs 201+)
  worker_vms = {
    for i in range(1, var.k8s_workers + 1) :
    "worker${i}" => {
      hostname = "worker${i}.k8s.local"
      vm_id    = 200 + i
      ip       = "${local.prefix}.${201 + (i - 1)}"
      role     = "worker"
      cpu      = var.worker_cpu
      memory   = var.worker_memory
      disk     = var.worker_disk

      machine            = i == 2 ? "q35" : null
      bios               = i == 2 ? "ovmf" : null
      enable_efi_disk    = i == 2
      efi_disk_datastore = i == 2 ? var.storage : null
      efi_disk_type      = "4m"
      vga_type           = i == 2 ? "serial0" : null
      serial_devices     = i == 2 ? ["socket"] : []
      hostpci_devices = i == 2 && var.worker2_gpu_enabled ? [
        {
          device = "hostpci0"
          id     = "0000:02:00.0"
          pcie   = true
          xvga   = false
        },
        {
          device = "hostpci1"
          id     = "0000:02:00.1"
          pcie   = true
        },
      ] : []
    }
  }

  # Storage nodes (VM IDs 401+)
  storage_vms = {
    for i in range(1, var.storage_nodes + 1) :
    "stor${i}" => {
      hostname = "stor${i}.node.local"
      vm_id    = 400 + i
      ip       = "${local.prefix}.${151 + (i - 1)}"
      role     = "storage"
      cpu      = var.storage_cpu
      memory   = var.storage_memory
      disk     = var.storage_disk
    }
  }

  all_vms = merge(local.aux_vms, local.db_vms, local.master_vms, local.worker_vms, local.storage_vms)
}

module "proxmox_vm" {
  source   = "../../modules/proxmox_vm"
  for_each = local.all_vms

  vm_name               = each.value.hostname
  vm_id                 = each.value.vm_id
  node_name             = local.node
  ip_address            = "${each.value.ip}/24"
  gateway               = local.gateway
  cores                 = each.value.cpu
  memory                = each.value.memory
  disk_size             = each.value.disk
  template_id           = local.tmpl
  network_bridge        = local.bridge
  ssh_keys              = var.ssh_keys
  cloud_init_user       = var.cloud_init_user
  storage               = var.storage
  machine               = lookup(each.value, "machine", null)
  bios                  = lookup(each.value, "bios", null)
  vga_type              = lookup(each.value, "vga_type", null)
  serial_devices        = lookup(each.value, "serial_devices", [])
  enable_efi_disk       = lookup(each.value, "enable_efi_disk", false)
  efi_disk_datastore_id = lookup(each.value, "efi_disk_datastore", null)
  efi_disk_type         = lookup(each.value, "efi_disk_type", "4m")
  hostpci_devices       = lookup(each.value, "hostpci_devices", [])
}
