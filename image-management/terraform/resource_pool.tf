resource "citrix_azure_hypervisor_resource_pool" "example-azure-hypervisor-resource-pool" {
    name                           = var.hypervisor_resource_pool_name                         # Name of the resource pool 
    hypervisor                     = citrix_azure_hypervisor.example-azure-hypervisor.id       # Hypervisor ID
    region                         = var.region                                                # Region
    virtual_network_resource_group = var.azure_vnet_resource_group                             # Azure virtual network resource group
    virtual_network                = var.azure_vnet                                            # Azure virtual network
    subnets                        = var.azure_subnets                                         # Azure subnets
}