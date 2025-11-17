Citrix Image Pipeline using Ansible
=================

**Description:** Citrix VDA Image Pipeline using Ansible

**Owners**: sourav.samanta@cloud.com

- [Citrix Image Pipeline using Ansible](#citrix-image-pipeline-using-ansible)
- [Setting up your Ansible Environment (Ref Link)](#setting-up-your-ansible-environment-ref-link)
- [Copying folders from your local windows environment to the linux machine using SCP](#copying-folders-from-your-local-windows-environment-to-the-linux-machine-using-scp)
- [Running the Ansible Playbooks:](#running-the-ansible-playbooks)
    - [Create a Service Principal on Azure](#create-a-service-principal-on-azure)
    - [Adding download links for the VDA Installer and Citrix Optimizer and verifying variable values](#adding-download-links-for-the-vda-installer-and-citrix-optimizer-and-verifying-variable-values)
    - [VDA Versions supported](#vda-versions-supported)
    - [Running the playbook](#running-the-playbook)
- [Changes required for installing a Citrix VDA](#changes-required-for-installing-a-citrix-vda)
- [Citrix Optimizers](#citrix-optimizers)
- [ANSIBLE TAGS](#ansible-tags)




Setting up your Ansible Environment ([Ref Link](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#installing-and-upgrading-ansible-with-pip))
=================
1. Create an Azure VM with a Linux Environment (e.g. Ubuntu 22.04). Reference link: https://learn.microsoft.com/en-us/azure/virtual-machines/linux/quick-create-portal?tabs=ubuntu
2. Ensure that `python3` and `pip` are installed on the linux machine
   1. To verify if `python3` is already installed, execute the following command:
         ```
         python3 -V
         ```
   2. If `python3` is not installed, you can install it using the following commands:
   
        ```
        sudo apt-get update
        sudo apt-get install python3.9
        ```
   3. To verify whether pip is already installed for your preferred Python, execute the following command:
        ```
        python3 -m pip -V
        ```
        If pip is not present, install it by running the following commands:
        ```
        sudo curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
        python3 get-pip.py --user
        ```
3. Use `pip` to install ansible:

   ```
   python3 -m pip install --user ansible
   ```

4. Add Ansible to PATH by updating the `~/.bashrc` file. To do that, run the following:
   1. Open `~/.bashrc` using vim:
   
         ```
         vim ~/.bashrc
         ```
   2. Navigate to the bottom of the file and press `I`. Add the following line to the bottom of the file:
         ```
         PATH=$PATH:/home/<adminusername>/.local/bin
         ```
      **Note: Please make sure to replace `<adminusername>` with the username of the administrator for your machine. The administrator username is the name you provide in Azure while creating the Linux Virtual Machine.**

      Save and Exit from Vim by pressing the `ESC` key, followed by `:wq`.

5. Now in the terminal, type the following command:

   `source ~/.bashrc`

   This step ensures that the user wouldn't have to exit the Linux terminal in order to install `pywinrm` and Ansible modules using `pip`.

   Installing `pywinrm`:

   Use `pip` to install `pywinrm`:
   ```
   pip3 install "pywinrm>=0.3.0"
   ```


6. Install Ansible az collection to interact with Azure
    ```
    ansible-galaxy collection install azure.azcollection --force
    ```
7. Install Ansible modules for Azure
   ```
   pip3 install -r ~/.ansible/collections/ansible_collections/azure/azcollection/requirements.txt
   ```


Copying folders from your local windows environment to the linux machine using SCP
=================

Ansible playbooks can be copied over to the linux virtual machine you created, from your local windows machine, using the SCP command.

The SCP command to copy over folders has the following syntax

```
scp -i <PEM_FILE_PATH> -r <SOURCE_FOLDER_PATH> <ADMIN USERNAME>@<LINUX_MACHINE_PUBLIC_IP>:<DESTINATION_FOLDER_PATH>
```

For example:
```
scp -i .\ansible-control-node-key.pem -r .\image-management\ansible\ azureuser@51.8.80.164:/home/azureuser
```
where:
* `.\ansible-control-node-key.pem` - Relative windows path to the PEM file used to connect to the linux machine
* `.\ansible\` - Relative windows path to the folder to be copied over
* `azureuser` - Username of the admin for the linux machine
* `51.8.80.164` - Public IP of the linux machine
* `/home/azureuser` - Linux path where the folder will be copied over

Running the Ansible Playbooks:
=================

### Create a Service Principal on Azure

1. Refer to the [microsoft documentation](https://learn.microsoft.com/en-us/azure/developer/ansible/create-ansible-service-principal?tabs=azure-cli#create-an-azure-service-principal) to create an azure service principal and grant it `Contributor` role at the subscription level.
2. Once the service principal has been created, generate a client secret for it. You have a few options on how to provide the service principal credentials to Ansible. One of the ways is to add them to the `~/.azure/credentials` file. To do that, follow the steps below:
   1. Create a directory called `.azure` at the home directory in the Linux Virtual Machine. Once you create the `.azure` directory, create a `credentials` file under it:
   
        ```
        mkdir ~/.azure
        vi ~/.azure/credentials
        ```
   2. Insert the following lines into the file. Replace the placeholders with the service principal values. `Note: Do not surround the values using quotes`

        ```
        [default]
        subscription_id=<subscription_id>
        client_id=<service_principal_app_id>
        secret=<service_principal_password>
        tenant=<service_principal_tenant_id>
        ```
   3. Save and close the file by pressing the `ESC` key, followed by `:wq`.

### Adding download links for the VDA Installer and Citrix Optimizer and verifying variable values

1. All variable values are present in the YAML files under `./ansible/group_vars/all`
2. In `root_settings.yml`, provide values for the following variables:
   1. `vda_installer_path` - EXE file URL of the singlesession/multisession vda installer
   2. `citrix_optimizer_zip_url` - **zip folder** URL of the Citrix Optimizer. Please use `version 3.3` and above.
   3. `ansible_user` - Username for the windows machine to be created
   4. `ansible_password` - Password for the windows machine to be created
3. Update the variable names in `azure_settings.yml` to prevent any resource name clashes for resources like `azure_resource_group_name` and `azure_virtual_machine_name`
4. Update the path for `inventory` variable in the `ansible.cfg` file to the relative path of `inventory.ini` file in the Linux machine. The relative path of `inventory.ini` file is `./ansible/inventory.ini`. 


### VDA Versions supported

Currently, we support the VDA Versions `v2407`, `v2411`, `v2503`, and `v2507`.


### Running the playbook

The image creation pipeline consists of multiple roles where each role performs a specific function. Following is a brief description of each role:
1. `create_azure_windows_vm` - Creates a windows virtual machine on azure with all the necessary dependencies (vnet, subnet, public ip) and installs WinRM on the machine.\
**Note**: RDP access for the machine has been disabled by default. Please refer to the following [documentation](https://learn.microsoft.com/en-us/azure/virtual-machines/windows/connect-rdp) on how to enable it.
2. `azure_add_host_to_inventory` - Adds the public ip address for the newly created windows vm in the inventory file so that ansible can connect to it
3. `install_mcs_vda` - Installs either the single session vda or the multi session vda on the windows VM based on the download link and VDA tag provided. Internally calls `vda_installation_prerequisites` and `monitor_vda_installation` roles.
4. `optimize_image` - Downloads and runs the citrix optimizer
5. `install_default_apps` - Installs Chrome and Firefox browsers. Installation of these browsers is optional and can be controlled by setting the values for `install_chrome` and `install_firefox` variables.
6. `generate_golden_image` - Creates a snapshot and gallery image from the os disk of the windows vm

You can optionally enable/disable any of the above roles depending on what actions you would like to perform when running the image creation pipeline. This can be done by setting `true` or `false` values for each of these roles in the `./ansible/group_vars/all/root_settings.yml` file.

To run the image management pipeline, navigate to the directory containing the `citrix_image_management.yml` playbook and execute the following command::

```
ansible-playbook citrix_image_management.yml --tags "<vm_tag_name>,<vda_version_tag_name>,<vda_type_tag_name>"
```

```
Eg. `ansible-playbook citrix_image_management.yml --tags "win10_desktop,single_session_vda,v2407"`
```

More information about the tags can be found in the `ANSIBLE TAGS` section.


Changes required for installing a Citrix VDA
=================

1. In `root_settings.yml`, set `install_mcs_vda` to `True`.
2. We support creation of `8` types of Azure Windows based Virtual Machines, which include the `Server` OS, which is typically a `Multi Session OS`, and a `Desktop` based OS, which is a `Single Session OS`.
3. Following are the Single Session Windows Operating System we support for creation:
   1. Windows 10 Desktop base.
   2. Windows 11 Desktop base.
4. Following are the Multi Session Windows Operating System we support for creation:
   1. Windows 10 Server base.
   2. Windows 11 Server base.
   3. Windows 10 Office base.
   4. Windows 11 Office base.
   5. Windows Server 2019 Datacenter.
   6. Windows Server 2022 Datacenter.
5. The important point to note is that the `Single Session OS` based VMs support only the installation of `Single Session VDAs`. `Multi Session OS` based VMs, except for the Datacenter based Operating Systems, support the installation of just the `Multi Session VDAs.`
6. The `Windows Server 2019 Datacenter` and `Windows Server 2022 Datacenter` can support the installation of a `Multi Session VDA`, as well as the `Single Session VDA`. These Operating Systems have the ability to act as a Single Session `Desktop` OS, which allows the installation of a `Single Session VDA`.
7. Make sure to use the `single_session_vda` tag while running the Ansible playbook while installing the Single Session VDA, and for installing the Multi Session VDA, make sure to use the `multi_session_vda` tag while running the Ansible playbook. Check out the `ANSIBLE TAGS` section to learn more about these tags.
8.  Currently, we support the VDA Versions `v2407`, `v2411`, `v2503`, and `v2507`, so make sure to specify one of the `v2407`, `v2411`, `v2503`, or `v2507` tag while running the Ansible playbook. Check out the `ANSIBLE TAGS` section to learn more about these tags.


---------------Important Note for the Single Session VDA and Multi Session VDA---------------

Make sure to set the correct download links for the `Single Session VDA` and `Multi Session VDA` in the `vda_installer_path` variable in `root_settings.yml` file.


Citrix Optimizers
=================


Once a `Virtual Delivery Agent (VDA)` has been installed on the Azure Windows Virtual Machine, if the `optimizer_image` role is set to `True`, the `Citrix Optimizer` script shall run, ensuring that the bloatware is removed from the the Windows Virtual Machine. The `Citrix Optimizer` folder comes with `templates`, which correspond to the template files used to run the Optimizer script. It is recommended that the template files should correspond with the type of Operating System VM being created prior. Furthermore, if the `template` files contain multiple `xml` files corresponding to the same OS based Virtual being installed, it's recommended that one uses the latest version of the Optimizer template file.

Eg. `Windows 10 Desktop` based VM should have an optimizer run, with the corresponding `template` file being `Citrix_windows_10_2009.xml`.

Following are the arguments you should set for the `citrix_optimizer_template_file_name` argument in root_settings.yml:

1. For `Windows Server 10` machine: Set the `citrix_optimizer_template_file_name` argument as `Citrix_Windows_10_2009.xml`
2. For `Windows Office 10` machine: Set the `citrix_optimizer_template_file_name` argument as `Citrix_Windows_10_2009.xml`
3. For `Windows 10 Desktop` machine: Set the `citrix_optimizer_template_file_name` argument as `Citrix_Windows_10_2009.xml`
4. For `Windows Server 11` machine: Set the `citrix_optimizer_template_file_name` argument as `Citrix_Windows_11_2009.xml`
5. For `Windows Office 11` machine: Set the `citrix_optimizer_template_file_name` argument as `Citrix_Windows_11_2009.xml`
6. For `Windows 11 Desktop` machine: Set the `citrix_optimizer_template_file_name` argument as `Citrix_Windows_11_2009.xml`
7. For `Windows 2019 Datacenter` machine: Set the `citrix_optimizer_template_file_name` argument as `Citrix_Windows_Server_2019_1809.xml`
8. For `Windows 2022 Datacenter` machine: Set the `citrix_optimizer_template_file_name` argument as `Citrix_Windows_Server_2022_2009.xml`


ANSIBLE TAGS
=================


1. Ansible Tags enable us to run only a particular task, instead of all the tasks in the entire playbook.


2. Syntax to run the playbook using tags: 
   `ansible-playbook citrix_image_management.yml --tags <tag-names>`

   Consider an example where we want to install a single session VDA on a Windows 10 Desktop Machine. 
   The syntax would be as follows:
   `ansible-playbook citrix_image_management.yml --tags "win10_desktop,single_session_vda,v2407"`.

3. Before declaring any tags, note that if any role associated with the tag is set to `False`, all the tasks under that role shall be skipped, even if the tag associated with one of these tasks is declared,

   Eg. If the `install_mcs_vda` role is set to `False`, then no tasks under the `install_mcs_vda` role shall execute, even if the `single_session_vda` is declared.

   To ensure the Virtual Machine with a certain tag is being created, set the `create_azure_wuindows_vm` to `True`. Similarly, to install a VDA, set the `install_mcs_vda` to `True`.


4. Currently, we support the following tag implementations to create an Azure Windows VM:
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


5. In order to install a Virtual Delivery Agent (VDA) using tags, these are the tags supported:
   1. `single_session_vda`: Installs a single session VDA on top of the Windows VM created.
   2. `multi_session_vda`: Installs a multi session VDA on top of the Windows VM created.
   Only one of these tags should be used  at a time to create a VDA.


   Note: If one tries to pass multiple tags from this same group, Ansible will throw an error specifying that only one of these tags need to be declared.


6. Currently, we support `v2407`, `v2411`, `v2503`, and `v2507` tags, which are associated with the VDA Version you want to install.
   `v2411`, `v2503`, and `v2507` support an additional installation of `Citrix VDA Upgrade Agent` in the Citrix VDA Image we create.
   Only one of these tags should be used  at a time to create a VDA.


   Note: If one tries to pass multiple tags from this same group, Ansible will throw an error specifying that only one of these tags need to be declared.


7. Similarly, if the `create_azure_windows_vm` is set to true, and no tag is declared from the `virtual_machine_exclusive_tags` list, Ansible throws an error, specifying that one tag needs to be specified from the list of tags. 


   If the `install_mcs_vda` is set to `True`, and neither of `single_session_vda` or `multi_session_vda` is declared, then Ansible throws an error, specifying that one tag needs to be specified.  



8. If either the `create_azure_windows_vm` or `install_mcs_vda` roles are set to false in `root_settings.yml`, and their tags are declared in the tags list, the respective VM creation or VDA installation would not take place, owing to the roles being set to `False`.