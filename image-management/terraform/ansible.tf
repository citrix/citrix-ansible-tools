resource "ansible_host" "host" {
  name       = var.provider_hostname                    # Name of the host
}

resource "ansible_playbook" "playbook" {
  playbook   = var.ansible_playbook_path            # Path to the Ansible playbook
  name       = var.provider_hostname                # Name of the playbook
  tags       = var.ansible_tags                     # Tags to run the playbook with
  replayable = var.replayable                       # If set to false, the playbook will not be replayed
}