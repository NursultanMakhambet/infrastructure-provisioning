# Homelab environment: Proxmox VMs for DevOps / platform engineering.
# VMs are created from template (VMID 9000), use virtio on vmbr0, cloud-init for IP and SSH.

locals {
  gateway = var.gateway
  prefix  = var.network_prefix
  node    = var.proxmox_node
  bridge  = var.network_bridge
  tmpl    = var.template_id

  # Aux node (single)
  aux_vms = {
    "aux1" = {
      hostname = "aux1.node.local"
      vm_id    = 190
      ip       = "${local.prefix}.190"
      role     = "aux"
      cpu      = var.aux_cpu
      memory   = var.aux_memory
      disk     = var.aux_disk
    }
  }

  # DB cluster
  db_vms = {
    for i in range(1, var.db_nodes + 1) :
    "db${i}" => {
      hostname = "db${i}.node.local"
      vm_id    = 110 + (i - 1)
      ip       = "${local.prefix}.${110 + (i - 1)}"
      role     = "db"
      cpu      = var.db_cpu
      memory   = var.db_memory
      disk     = var.db_disk
    }
  }

  # Kubernetes masters
  master_vms = {
    for i in range(1, var.k8s_masters + 1) :
    "master${i}" => {
      hostname = "master${i}.k8s.local"
      vm_id    = 101 + (i - 1)
      ip       = "${local.prefix}.${101 + (i - 1)}"
      role     = "master"
      cpu      = var.master_cpu
      memory   = var.master_memory
      disk     = var.master_disk
    }
  }

  # Kubernetes workers
  worker_vms = {
    for i in range(1, var.k8s_workers + 1) :
    "worker${i}" => {
      hostname = "worker${i}.k8s.local"
      vm_id    = 201 + (i - 1)
      ip       = "${local.prefix}.${201 + (i - 1)}"
      role     = "worker"
      cpu      = var.worker_cpu
      memory   = var.worker_memory
      disk     = var.worker_disk
    }
  }

  # Storage nodes (SeaweedFS etc.; align with k8s-baremetal-platform inventory)
  storage_vms = {
    for i in range(1, var.storage_nodes + 1) :
    "stor${i}" => {
      hostname = "stor${i}.node.local"
      vm_id    = 151 + (i - 1)
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

  vm_name        = each.value.hostname
  vm_id          = each.value.vm_id
  node_name      = local.node
  ip_address     = "${each.value.ip}/24"
  gateway        = local.gateway
  cores          = each.value.cpu
  memory         = each.value.memory
  disk_size      = each.value.disk
  template_id    = local.tmpl
  network_bridge = local.bridge
  ssh_keys       = var.ssh_keys
  cloud_init_user = var.cloud_init_user
  storage        = var.storage
}
