resource "citrix_zone" "example_zone" {
        name        = var.zone_name                 # Name of the zone
        description = var.zone_description          # Description of the zone
        depends_on  = [ansible_playbook.playbook]   # Depends on the Ansible playbook
}
