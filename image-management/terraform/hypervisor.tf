# Azure Hypervisor
resource "citrix_azure_hypervisor" "example-azure-hypervisor" {
    name                = var.hypervisor_name           # Name of the hypervisor    
    zone                = citrix_zone.example_zone.id   # Zone ID
    active_directory_id = var.azure_tenant_id           # Azure Tenant ID from variable
    subscription_id     = var.azure_subscription_id     # Azure Subscription ID from variable
    application_secret  = var.azure_client_secret       # Azure Client Secret from variable
    application_id      = var.azure_client_id           # Azure Client ID from variable
}