#!/usr/bin/env bash
# Run Terraform using the project's local binary.
# Use in the same terminal where you exported TF_VAR_* (proxmox_token_id, proxmox_token_secret, etc.).
#
# Usage: ./scripts/run_terraform.sh [init|plan|apply|destroy]
# Example:
#   export TF_VAR_proxmox_api_url="https://192.168.1.85:8006/"
#   export TF_VAR_proxmox_node="pve"
#   export TF_VAR_proxmox_token_id="user@pam!terraform"
#   export TF_VAR_proxmox_token_secret="your-secret"
#   ./scripts/run_terraform.sh plan
#   ./scripts/run_terraform.sh apply

set -euo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TERRAFORM="${REPO_ROOT}/.bin/terraform"
HOMELAB="${REPO_ROOT}/terraform/environments/homelab"

if [[ ! -x "$TERRAFORM" ]]; then
  echo "Terraform not found at $TERRAFORM. Run: curl -fsSL https://releases.hashicorp.com/terraform/1.9.8/terraform_1.9.8_linux_amd64.zip -o /tmp/tf.zip && unzip -o /tmp/tf.zip -d $REPO_ROOT/.bin" >&2
  exit 1
fi

cd "$HOMELAB"
exec "$TERRAFORM" "$@"
