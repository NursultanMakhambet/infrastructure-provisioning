#!/usr/bin/env bash
set -euo pipefail

# Audits and optionally removes "unusedN" disk references from Proxmox VMs.
# Default mode is dry-run (audit only). Set APPLY=true to delete references.
#
# Examples:
#   ./scripts/proxmox-unused-disks.sh
#   APPLY=true ./scripts/proxmox-unused-disks.sh
#   VM_IDS="101 102 103 201 202" APPLY=true ./scripts/proxmox-unused-disks.sh

VM_IDS="${VM_IDS:-101 102 103 201 202}"
APPLY="${APPLY:-false}"

if ! command -v qm >/dev/null 2>&1; then
  echo "ERROR: qm CLI not found. Run this script on a Proxmox host."
  exit 1
fi

for vmid in ${VM_IDS}; do
  echo "== VM ${vmid} =="
  mapfile -t unused_lines < <(qm config "${vmid}" | sed -nE 's/^(unused[0-9]+):.*/\1/p')

  if [[ ${#unused_lines[@]} -eq 0 ]]; then
    echo "No unused disks."
    continue
  fi

  printf 'Found: %s\n' "${unused_lines[*]}"

  if [[ "${APPLY}" == "true" ]]; then
    for tag in "${unused_lines[@]}"; do
      echo "Deleting ${tag} on VM ${vmid}"
      qm set "${vmid}" -delete "${tag}"
    done
  else
    echo "Dry-run only. Re-run with APPLY=true to delete these references."
  fi
done
