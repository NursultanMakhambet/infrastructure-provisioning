# Cloud-init is configured via the `initialization` block in main.tf:
# - Static IP and gateway via ip_config
# - User account and SSH keys via user_account
# For custom cloud-config snippets, upload a snippet to Proxmox and
# reference it via user_data_file_id in the initialization block.
