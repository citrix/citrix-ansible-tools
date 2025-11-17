Citrix Machine Catalog Pipeline using Ansible along with Terraform
=================

**Description:** This automation pipeline aims to run the Ansible playbook using Terraform, and utilize the Machine Image created from the Ansible Playbook, to create a Machine Catalog, using the Citrix Terraform Provider.

Table of Contents
=================
- [Citrix Machine Catalog Pipeline using Ansible along with Terraform](#citrix-machine-catalog-pipeline-using-ansible-along-with-terraform)
- [Table of Contents](#table-of-contents)
- [Pre-Requisites](#pre-requisites)
- [Setting up your Terraform Environment](#setting-up-your-terraform-environment)
- [Ansible Tags in Terraform](#ansible-tags-in-terraform)
- [Running the Terraform Script](#running-the-terraform-script)
- [Specifying variables](#specifying-variables)

Pre-Requisites
=================

1. Download the [Ansible repository](https://github.com/citrix/citrix-ansible-tools) in the same Linux Virtual Machine that you will run terraform resources in.
   
2. The [Ansible directory](https://github.com/citrix/citrix-ansible-tools/tree/main/image-management) contains the `roles` folder which has the playbooks corresponding to the various roles within the `citrix_image_management.yml` playbook. The `group_vars/all` folder within the [image-management directory](https://github.com/citrix/citrix-ansible-tools/tree/main/image-management) contains `azure_settings.yml` and `root_setting.yml` where you can customize variables required to set up the Ansible playbook. Refer this [README](https://github.com/citrix/citrix-ansible-tools/blob/main/image-management/readme.md) for instructions on setting up the variables required to set up the playbook.
Note: Ansible, and the variables within the Ansible playbooks should be set up prior to running terraform.

3. The `data_source.tf` calls the `catalog_vars.txt` file, which is created at the end of the Ansible playbook's execution, in the `filename` variable. The `catalog_vars.txt` will contain variables that will be used by the `machine_catalog` resource in `machine_catalog.tf` file.
   
4. The `catalog_vars.txt` file is created at the same level as of `citrix_image_management.yml` and the path assigned in `data_source.tf` is a relative path. Depending on where the terraform files are stored, the relative path for `catalog_vars.txt` might need to be changed. 

5. Prior to running terraform, set up the variables required to run the Ansible playbook, and create the Zone, Hypervisor, Resource Pool, and Machine Catalog. Refer this [section](#specifying-variables)  for the same. 
   
6. Also, don't forget to set up the Provider Configuration to run the Terraform. [Link](#running-the-terraform-script)

Setting up your Terraform Environment
=================

1. Create an Azure VM with a Linux Environment (e.g. Ubuntu 22.04). Reference link: https://learn.microsoft.com/en-us/azure/virtual-machines/linux/quick-create-portal?tabs=ubuntu
2. Installing Terraform on Linux: Refer this [documentation](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli) to install Terraform in Ubuntu.

[Ansible Tags](https://github.com/citrix/citrix-ansible-tools/blob/main/image-management/readme.md#ansible-tags) in Terraform
=================

The Ansible Tags can be passed to the `ansible_playbook` resource under the `tags` variable as a list of strings. The tags can be passed to the variable similar to how we set the tags in Ansible. 

Currently, we support the following tag implementations to create an Azure Windows VM:
   1. `win10_desktop`: Creates an Azure Windows VM with a Windows 10 Desktop base.
   2. `win11_desktop`: Creates an Azure Windows VM with a Windows 11 Desktop base.
   3. `win10_server`: Creates an Azure Windows VM with a Windows 10 Server base.
   4. `win11_server`: Creates an Azure Windows VM with a Windows 11 Server base.
   5. `office_10_vm`: Creates an Azure Windows VM with a Windows Office 10 base.
   6. `office_11_vm`: Creates an Azure Windows VM with a Windows Office 11 base.
   7. `win_2019_dc_vm`: Creates an Azure Windows VM with a Windows Server 2019 Datacenter base.
   8. `win_2022_dc_vm`: Creates an Azure Windows VM with a Windows Server 2022 Datacenter base.


   Only one of these tags should be used  at a time to create a VM.


   Note: If one tries to pass multiple tags from this same group, Ansible will throw an error specifying that only one of these tags need to be declared.


In order to install a Virtual Delivery Agent (VDA) using tags, these are the tags supported:
   1. `single_session_vda`: Installs a single session VDA on top of the Windows VM created.
   2. `multi_session_vda`: Installs a multi session VDA on top of the Windows VM created.
   Only one of these tags should be used  at a time to create a VDA.


   Note: If one tries to pass multiple tags from this same group, Ansible will throw an error specifying that only one of these tags need to be declared.


Currently, we support `v2407`, `v2411`, `v2503`, and `v2507` tags, which are associated with the VDA Version you want to install.

Example of tags list: tags = ["win10_desktop","single_session_vda","v2407"]

Running the Terraform Script
=================

Clone the terraform-ansible-provider repository. Once you clone the repo, first, ensure that the `provider.tf` file is present. 
Refer this documentation for the provider configuration: https://registry.terraform.io/providers/citrix/citrix/latest/docs#example-usage

Within the cloned repo, specify the variables, and run terraform within the same directory.

Run the following steps for the same:

cp terraform.template.tfvars terraform.tfvars
vim terraform.tfvars # open the file and specify variables
terraform init
terraform plan
terraform apply

`terraform init` will initialize the working directory containing the Terraform configuration files. Besides, it will install the required plugins.
`terraform plan` will show a preview of the resources whose changes will be applied on your infrastructure.
`terraform apply` will execute all the changes proposed in your terraform configuration. Based on the changes proposed, it will create, update, or delete the resources in your infrastructure.

Specifying variables
=================
The repository contains a `variables.tf` file which needs to be specified. There are also some default values and configuration options in the other `.tf` files in the directory. Review these options and adjust depending on your use case. 

The variables can be specified by copying the [terraform.template.tfvars](./terraform.template.tfvars) file to `terraform.tfvars` and then filling it out with your values.

