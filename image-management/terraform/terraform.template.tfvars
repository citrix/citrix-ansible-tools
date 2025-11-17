# Ansible Playbook Variables

provider_hostname     = "<DDC IP/Hostname>"
ansible_tags          = ["win10_desktop", "v2407", "single_session_vda"]
ansible_playbook_path = "../citrix_image_management.yml"
replayable            = false

# Citrix Zone Variables

zone_name             = "example-zone"
zone_description      = "Example zone description"

# Citrix Azure Hypervisor Variables

hypervisor_name       = "example-hypervisor"
azure_subscription_id = "<subscription_id>"
azure_client_id       = "<SPN Client Id>"
azure_client_secret   = "<SPN Client Secret>"
azure_tenant_id       = "<SPN Tenant ID>"

# Citrix Azure Hypervisor Resource Pool Variables

hypervisor_resource_pool_name = "example-resource-pool"
region                        = "East US"
azure_vnet_resource_group     = "example-vnet-resource-group"
azure_vnet                    = "example-vnet"
azure_subnets                 = "[example-subnet-1, example-subnet-2]"

# Citrix Azure Hypervisor Machine Catalog Variables

machine_catalog_name            = "example-machine-catalog"
machine_catalog_description     = "Example machine catalog description"
allocation_type                 = "Random"
session_support                 = "MultiSession"
provisioning_type               = "MCS"
number_of_total_machines        = 1
identity_type                   = "ActiveDirectory"
domain_fqdn                     = "example.com"
domain_service_account          = "<example-service-account>"
domain_service_account_password = "<service-account-password>"
use_managed_disks               = true
storage_type                    = "Standard_LRS"
service_offering                = "Standard_D2s_v2"
naming_scheme                   = "example-machine-###"
naming_scheme_type              = "Numeric"