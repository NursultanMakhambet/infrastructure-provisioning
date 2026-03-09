#!/usr/bin/env bash
# Generate Ansible inventory from Terraform outputs.
# Outputs INI format compatible with k8s-baremetal-platform (environments/localVM/hosts).
#
# Usage:
#   ./scripts/generate_inventory.sh                    # write to inventory/hosts
#   ./scripts/generate_inventory.sh -o path/hosts       # write to path/hosts
#   ./scripts/generate_inventory.sh --k8s-platform     # write to ../k8s-baremetal-platform/environments/localVM/hosts
#
# Run after: cd terraform/environments/homelab && terraform apply

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TERRAFORM_DIR="${TERRAFORM_DIR:-$REPO_ROOT/terraform/environments/homelab}"
OUTPUT_FILE=""
USE_K8S_PLATFORM=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    -o|--output)
      OUTPUT_FILE="$2"
      shift 2
      ;;
    --k8s-platform)
      USE_K8S_PLATFORM=true
      shift
      ;;
    -*)
      echo "Usage: $0 [-o path/hosts] [--k8s-platform] [terraform_workdir]" >&2
      exit 1
      ;;
    *)
      TERRAFORM_DIR="$1"
      shift
      ;;
  esac
done

if [[ -z "$OUTPUT_FILE" ]]; then
  if [[ "$USE_K8S_PLATFORM" == true ]]; then
    OUTPUT_FILE="$REPO_ROOT/../k8s-baremetal-platform/environments/localVM/hosts"
  else
    OUTPUT_FILE="$REPO_ROOT/inventory/hosts"
  fi
fi

cd "$REPO_ROOT"
if [[ ! -d "$TERRAFORM_DIR" ]]; then
  echo "Error: Terraform dir not found: $TERRAFORM_DIR" >&2
  exit 1
fi

OUTPUT_JSON=$(terraform -chdir="$TERRAFORM_DIR" output -json 2>/dev/null) || true
if [[ -z "${OUTPUT_JSON:-}" ]]; then
  echo "Error: Could not get terraform output. Run terraform apply first." >&2
  exit 1
fi

INV=$(echo "$OUTPUT_JSON" | jq -c '.ansible_inventory.value // .ansible_inventory // empty')
if [[ -z "${INV:-}" || "$INV" == "null" ]]; then
  echo "Error: No output 'ansible_inventory'. Run terraform apply first." >&2
  exit 1
fi

# Helper: get host line for a group with optional per-host vars (by index)
# Usage: emit_group "group_name" "var_template"
# var_template uses INDEX (0-based) and IP, e.g. "ansible_host=IP chrony_server=True"
emit_group() {
  local group="$1"
  local count i name ip vars
  count=$(echo "$INV" | jq -r ".${group} | length")
  for i in $(seq 0 $((count - 1)) 2>/dev/null); do
    name=$(echo "$INV" | jq -r ".${group}[$i].name")
    ip=$(echo "$INV" | jq -r ".${group}[$i].ip")
    [[ -z "$name" || "$name" == "null" ]] && continue
    # Per-group host vars (match k8s-baremetal-platform)
    case "$group" in
      aux)     vars="ansible_host=${ip} chrony_server=True" ;;
      db)
        if [[ $i -eq 0 ]]; then
          vars="ansible_host=${ip} consul_server=True cassandra_medusa_cron_enabled=True qdrant_is_primary_host=True"
        else
          vars="ansible_host=${ip} consul_server=False cassandra_medusa_cron_enabled=False qdrant_is_primary_host=False"
        fi
        ;;
      storage)
        if [[ $i -eq 0 ]]; then
          vars="ansible_host=${ip} seaweedfs_master=True"
        else
          vars="ansible_host=${ip} seaweedfs_master=False"
        fi
        ;;
      k8s_master)
        if [[ $i -eq 0 ]]; then
          vars="ansible_host=${ip} instance_name=k8s_master$((i+1)) primary_node=True"
        else
          vars="ansible_host=${ip} instance_name=k8s_master$((i+1)) primary_node=False"
        fi
        ;;
      k8s_worker)
        vars="ansible_host=${ip} instance_name=k8s_worker$((i+1))"
        ;;
      *)       vars="ansible_host=${ip}" ;;
    esac
    echo "${name} ${vars}"
  done
}

mkdir -p "$(dirname "$OUTPUT_FILE")"
{
  echo "# Ansible inventory generated from Terraform (infrastructure-provisioning)."
  echo "# Regenerate: ./scripts/generate_inventory.sh"
  echo "# Compatible with k8s-baremetal-platform environments/localVM/hosts"
  echo ""
  echo "[all:children]"
  echo "k8s"
  echo "aux"
  echo "db"
  echo "storage"
  echo ""
  echo "[controlhost]"
  echo "localhost ansible_connection=local"
  echo ""
  echo "[k8s:children]"
  echo "k8s_master"
  echo "k8s_worker"
  echo ""
  echo "[k8s_cluster:children]"
  echo "k8s_master"
  echo "k8s_worker"
  echo ""
  echo "[etcd:children]"
  echo "k8s_master"
  echo ""
  echo "[kube_control_plane:children]"
  echo "k8s_master"
  echo ""
  echo "[kube_node:children]"
  echo "k8s_master"
  echo "k8s_worker"
  echo ""
  echo "[all:vars]"
  echo "ansible_user=user"
  echo "ansible_ssh_private_key_file=~/.ssh/id_ed25519"
  echo ""

  echo "[aux]"
  emit_group "aux"
  echo ""

  echo "[db]"
  emit_group "db"
  # qdrant_primary_host = first db IP
  first_db_ip=$(echo "$INV" | jq -r '.db[0].ip // empty')
  if [[ -n "$first_db_ip" && "$first_db_ip" != "null" ]]; then
    echo ""
    echo "[db:vars]"
    echo "qdrant_primary_host=${first_db_ip}"
  fi
  echo ""

  echo "[storage]"
  emit_group "storage"
  echo ""

  echo "[k8s_master]"
  emit_group "k8s_master"
  echo ""

  echo "[k8s_worker]"
  emit_group "k8s_worker"
} > "$OUTPUT_FILE"

echo "Wrote $OUTPUT_FILE"
