# Ansible Playbook Variables

variable provider_hostname {
  description = "The hostname of the Citrix Virtual Apps and Desktops Delivery Controller."
  type        = string
  default     = "" # Leave this variable empty for Citrix Cloud customer.
}

variable ansible_tags {
    description = "List of tags to run the Ansible playbook with."
    type        = list(string)
    default     = []
}

variable ansible_playbook_path {
    description = "The path to the Ansible playbook to run."
    type        = string
    default     = ""
}

variable replayable {
  description = "Replayable of the machine catalog"
  type        = bool
}

# Citrix Zone Variables

variable zone_name {
  description = "Name of the zone"
  type        = string
}

variable zone_description {
  description = "Description of the zone"
  type        = string
}

# Citrix Azure Hypervisor Variables

variable "hypervisor_name" {
  description = "Name of the hypervisor"
  type        = string
}

variable "azure_subscription_id" {
  type        = string
  description = "Subscription to place the resources in."
}

variable "azure_client_id" {
  type        = string
  description = "SPN Client ID."
}

variable "azure_client_secret" {
  type        = string
  description = "SPN Client Secret."
  sensitive   = true
}

variable "azure_tenant_id" {
  type        = string
  description = "SPN Tenant ID."
}

# Citrix Azure Hypervisor Resource Pool Variables


variable "hypervisor_resource_pool_name" {
  description = "Name of the hypervisor resource pool"
  type        = string
}

variable region {
  description = "Region of the hypervisor resource pool"
  type        = string
}

variable "azure_vnet_resource_group" {
  description = "Name of the Azure virtual network resource group"
  type        = string
}

variable "azure_vnet" {
  description = "Name of the Azure virtual network"
  type        = string
}

variable "azure_subnets" {
  description = "List of Azure subnets"
  type        = list(string)
}

# Citrix Machine Catalog Variables

variable "machine_catalog_name" {
  description = "Name of the machine catalog"
  type        = string
}

variable machine_catalog_description {
  description = "Description of the machine catalog"
  type        = string
}

variable allocation_type {
  description = "Allocation type of the machine catalog"
  type        = string
}

variable session_support {
  description = "Session support of the machine catalog"
  type        = string
}

variable provisioning_type {
  description = "Provisioning type of the machine catalog"
  type        = string
}

variable number_of_total_machines {
  description = "Number of total machines of the machine catalog"
  type        = number
}

variable identity_type {
  description = "Identity type of the machine catalog"
  type        = string
}

# Machine Domain Identity Variables
variable "domain_fqdn" {
  description = "Domain FQDN"
  type        = string
}

variable "domain_service_account" {
  description = "Domain service account with permissions to create machine accounts"
  type        = string
}

variable "domain_service_account_password" {
  description = "Domain service account password"
  type        = string
  sensitive   = true
}


#Azure Machine Config Variables 
variable use_managed_disks {
  description = "Use managed disks of the machine catalog"
  type        = bool
}

variable storage_type {
  description = "Storage type of the machine catalog"
  type        = string
}

variable service_offering {
  description = "Service offering of the machine catalog"
  type        = string
}

# Machine Creation Rules Variables
variable naming_scheme {
  description = "Naming scheme of the machine catalog"
  type        = string
}

variable naming_scheme_type {
  description = "Naming scheme type of the machine catalog"
  type        = string
}
