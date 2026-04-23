# Homelab environment - Proxmox at 192.168.1.2
# Copy to terraform.tfvars.local and set proxmox_token_* or use env:
#   export TF_VAR_proxmox_token_id="user@pam!terraform"
#   export TF_VAR_proxmox_token_secret="..."

proxmox_api_url  = "https://192.168.1.2:8006/"
proxmox_node     = "pve" # Change to your Proxmox node name (e.g. pve, proxmox)
proxmox_insecure = true

# Clone source: rocky9-temp (VM template on Proxmox)
template_id = 10000

# Token: set via env or terraform.tfvars.local (do not commit secrets)
# proxmox_token_id     = "user@pam!terraform"
# proxmox_token_secret = "your-secret"

# Scaling — k8s (3+2) + single DB only
db_nodes      = 1
k8s_masters   = 3
k8s_workers   = 2
storage_nodes = 0
aux_enabled   = false

# Disks on NVMe pool (not local-lvm)
storage = "NVME_STORAGE_FAST1"

# 2-phase worker2 passthrough rollout:
# - false => Phase 1 (q35 + ovmf + efi + serial0 console, no hostpci)
# - true  => Phase 2 (attach GTX 1070 hostpci devices)
worker2_gpu_enabled = true

# Network
gateway        = "192.168.1.1"
network_prefix = "192.168.1"

# SSH keys for cloud-init (add your public keys)
ssh_keys = [
  # "ssh-ed25519 AAAAC3... user@host",
  # "ssh-rsa AAAAB3... user@host",
]

# Disk sizes
master_disk  = 10
worker_disk  = 20
db_disk      = 20
storage_disk = 20
aux_disk     = 10
