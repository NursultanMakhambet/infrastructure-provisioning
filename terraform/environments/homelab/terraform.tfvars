# Homelab environment - Proxmox at 192.168.1.85
# Copy to terraform.tfvars.local and set proxmox_token_* or use env:
#   export TF_VAR_proxmox_token_id="user@pam!terraform"
#   export TF_VAR_proxmox_token_secret="..."

proxmox_api_url   = "https://192.168.1.85:8006/"
proxmox_node      = "pve"   # Change to your Proxmox node name (e.g. pve, proxmox)
proxmox_insecure  = true

# Token: set via env or terraform.tfvars.local (do not commit secrets)
# proxmox_token_id     = "user@pam!terraform"
# proxmox_token_secret = "your-secret"

# Scaling
db_nodes      = 3
k8s_masters   = 3
k8s_workers   = 2
storage_nodes = 3

# Network
gateway         = "192.168.1.1"
network_prefix  = "192.168.1"

# SSH keys for cloud-init (add your public keys)
ssh_keys = [
  # "ssh-ed25519 AAAAC3... user@host",
  # "ssh-rsa AAAAB3... user@host",
]

# Optional: override resource defaults
# master_cpu = 2
# master_memory = 4096
# master_disk = 40
# worker_cpu = 2
# worker_memory = 4096
# worker_disk = 40
# db_cpu = 2
# db_memory = 4096
# db_disk = 50
# aux_cpu = 1
# aux_memory = 2048
# aux_disk = 20
