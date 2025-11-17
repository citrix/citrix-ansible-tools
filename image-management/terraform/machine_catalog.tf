resource "citrix_machine_catalog" "example-non-domain-joined-azure-mcs" {
    name                        = var.machine_catalog_name                          # Name of the machine catalog
    description                 = var.machine_catalog_description                   # Description of the machine catalog
    zone                        = citrix_zone.example_zone.id                       # Zone ID
    allocation_type             = var.allocation_type                               # Allocation type
    session_support             = var.session_support                               # Session support
    provisioning_type           = var.provisioning_type                             # Provisioning type
  provisioning_scheme           =   {
      hypervisor                = citrix_azure_hypervisor.example-azure-hypervisor.id                                # Hypervisor ID
      hypervisor_resource_pool  = citrix_azure_hypervisor_resource_pool.example-azure-hypervisor-resource-pool.id    # Hypervisor resource pool ID
      identity_type             = var.identity_type                                                                  # Workgroup specifies that the machines are not domain-joined
      # Example using Azure, other hypervisors can be used as well
      machine_domain_identity   = {
          domain                   = var.domain_fqdn                                # Domain FQDN
          service_account          = var.domain_service_account                     # Domain service account
          service_account_password = var.domain_service_account_password            # Domain service account password
      }
      azure_machine_config      = {
          storage_type          = var.storage_type                                  # Storage type
          use_managed_disks     = var.use_managed_disks                             # Use managed disks
          service_offering      = var.service_offering                              # Service offering
          azure_master_image    = {
              # For Azure master image from managed disk or snapshot
              resource_group    = local.key_value_map.ResourceGroup                 # Resource group
              master_image      = local.key_value_map.Snapshot                      # Snapshot
          }
      }
      number_of_total_machines  = var.number_of_total_machines                      # Number of total machines
      machine_account_creation_rules ={
          naming_scheme         = var.naming_scheme                                 # Naming scheme
          naming_scheme_type    = var.naming_scheme_type                            # Naming scheme type
      }
  }

}