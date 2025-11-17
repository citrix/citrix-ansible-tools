data "local_file" "key_values" {
  filename   = "../catalog_vars.txt"
  depends_on = [ansible_playbook.playbook]
}
