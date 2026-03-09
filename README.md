# Infrastructure Provisioning

Production-style Terraform repository for **Proxmox** (and later AWS/other clouds), used for DevOps homelab and platform engineering.

## Repository layout

```
infrastructure-provisioning/
├── terraform/
│   ├── modules/
│   │   ├── proxmox_vm/       # Reusable Proxmox VM from template (clone, cloud-init, virtio)
│   │   └── network/          # Placeholder for shared network (VPC/VLANs later)
│   ├── providers/           # Canonical provider config (proxmox, aws, versions)
│   ├── environments/
│   │   └── homelab/         # Proxmox homelab (aux, db, storage, k8s masters/workers)
│   └── global/              # Shared variable/locals conventions
├── inventory/
│   └── hosts                    # Ansible inventory INI (generated; matches k8s-baremetal-platform)
├── scripts/
│   └── generate_inventory.sh   # Build inventory from terraform output
└── README.md
```

## Requirements

- **Terraform** >= 1.5
- **Proxmox** host (e.g. 192.168.1.85) with:
  - Template VM with **VMID 9000** (cloud-init capable, e.g. Ubuntu cloud image)
  - API access (token or user/password)
- **jq** (for `scripts/generate_inventory.sh`)

## Proxmox setup

1. Create a VM template (VMID 9000) with cloud-init and convert to template.
2. Create an API token for Terraform, e.g.:
   - User: `terraform@pve` (or your user)
   - Token: `pveum user token add <user> terraform-token --privsep 0`
3. Set permissions so the token can create VMs on the target node.

## Quick start (Homelab)

### 1. Configure variables

From the repo root:

```bash
cd terraform/environments/homelab
```

Copy and edit variables (do **not** commit secrets):

```bash
cp terraform.tfvars terraform.tfvars.local
# Edit terraform.tfvars.local: set proxmox_node, proxmox_token_id, proxmox_token_secret, ssh_keys
```

Or use environment variables:

```bash
export TF_VAR_proxmox_token_id="user@pam!terraform"
export TF_VAR_proxmox_token_secret="your-secret"
export TF_VAR_proxmox_api_url="https://192.168.1.85:8006/"
export TF_VAR_proxmox_node="pve"
```

Ensure `ssh_keys` in `terraform.tfvars` (or `terraform.tfvars.local`) contains your public keys for cloud-init.

### 2. Terraform init

```bash
cd terraform/environments/homelab
terraform init
```

This downloads the **bpg/proxmox** provider and initializes the backend.

### 3. Terraform plan

```bash
terraform plan
```

Optionally use a var file for secrets:

```bash
terraform plan -var-file=terraform.tfvars.local
```

Review the plan: VMs (aux, db, k8s masters, k8s workers) will be created by cloning template 9000, with the specified IPs and resources.

### 4. Terraform apply

```bash
terraform apply
```

With var file:

```bash
terraform apply -var-file=terraform.tfvars.local
```

Confirm with `yes` when prompted. VMs will be created on the configured Proxmox node.

### 5. Terraform destroy

To remove all created VMs:

```bash
cd terraform/environments/homelab
terraform destroy
```

Use `-var-file=terraform.tfvars.local` if you use one. Destroy will delete the cloned VMs; the template (9000) is not touched.

## Provisioned nodes (default)

| Role         | Hostnames              | IPs                  | CPU | RAM (MiB) | Disk (GiB) |
|-------------|------------------------|----------------------|-----|-----------|------------|
| aux         | aux1.node.local        | 192.168.1.190        | 1   | 2048      | 20         |
| db          | db1–db3.node.local     | 192.168.1.110–112    | 2   | 4096      | 50         |
| storage     | stor1–3.node.local     | 192.168.1.151–153    | 2   | 4096      | 50         |
| k8s masters | master1–3.k8s.local    | 192.168.1.101–103    | 2   | 4096      | 40         |
| k8s workers | worker1–2.k8s.local    | 192.168.1.201–202    | 2   | 4096      | 40         |

All VMs:

- Clone from template **VMID 9000**
- Use **virtio** NIC on **vmbr0**
- Have **cloud-init** with static IP and SSH key injection

## Scaling

In `terraform/environments/homelab/terraform.tfvars` (or your var file):

```hcl
db_nodes      = 3   # DB cluster size
k8s_masters   = 3   # Control plane nodes
k8s_workers   = 2   # Worker nodes
storage_nodes = 3   # Storage (SeaweedFS) nodes
```

Changing these and re-running `terraform apply` will add or remove VMs; IPs are derived from the same pattern (e.g. workers 201, 202, 203, …).

## Ansible inventory

After `terraform apply`, generate the Ansible inventory from Terraform outputs. The script produces **INI format** compatible with [k8s-baremetal-platform](https://github.com/NursultanMakhambet/k8s-baremetal-platform) `environments/localVM/hosts`:

```bash
./scripts/generate_inventory.sh
```

Output is written to `inventory/hosts` with groups: `all`, `aux`, `db`, `storage`, `k8s_master`, `k8s_worker`, plus `[all:children]`, `[k8s:children]`, `[db:vars]`, and host vars (e.g. `chrony_server`, `consul_server`, `instance_name`, `primary_node`, `seaweedfs_master`, `qdrant_*`).

To write directly into the k8s-baremetal-platform repo (when cloned next to this repo, e.g. `../k8s-baremetal-platform`):

```bash
./scripts/generate_inventory.sh --k8s-platform
```

This writes to `../k8s-baremetal-platform/environments/localVM/hosts`. Custom output path:

```bash
./scripts/generate_inventory.sh -o /path/to/hosts
```

## Module parameters (proxmox_vm)

Reusable in other environments or compositions:

| Parameter         | Description                    | Default   |
|------------------|--------------------------------|-----------|
| `vm_name`        | Hostname / VM name             | —         |
| `vm_id`          | Proxmox VM ID                  | —         |
| `node_name`      | Proxmox node                   | —         |
| `ip_address`     | IPv4/CIDR (e.g. 192.168.1.1/24)| —         |
| `gateway`        | Default gateway                | —         |
| `cores`          | CPU cores                      | 2         |
| `memory`         | Memory (MiB)                   | 4096      |
| `disk_size`      | Boot disk (GiB)                | 40        |
| `template_id`    | Template VMID to clone         | 9000      |
| `network_bridge` | Bridge (e.g. vmbr0)            | vmbr0     |
| `ssh_keys`       | SSH public keys (cloud-init)   | []        |
| `cloud_init_user`| Cloud-init user                | ubuntu    |
| `storage`        | Proxmox storage                | local-lvm |

## Adding AWS or other clouds

- **providers**: Add or enable the provider in `terraform/providers/` (e.g. `aws.tf`) and in the target environment’s `providers.tf`.
- **modules**: Add an `aws_instance` (or similar) module under `terraform/modules/` and call it from the environment’s `main.tf`.
- **Environments**: Add e.g. `terraform/environments/production-aws/` with its own `main.tf`, `variables.tf`, and `terraform.tfvars`, reusing the same module pattern.

## License

See [LICENSE](LICENSE).
