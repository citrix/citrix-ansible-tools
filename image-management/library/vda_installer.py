#!/usr/bin/python
# -*- coding: utf-8 -*-

DOCUMENTATION = r'''
---
module: vda_installer
short_description: Helps install the Citrix Virtual Delivery Agent (VDA) on Windows machines
description:
- This module helps install Citrix Virtual Delivery Agents (VDA) which allows machines to deliver applications or desktops
- The VDA enables the machine to register with the Controller, which in turn allows the machine and the resources it is hosting to be made available to users. 
- VDAs establish and manage the connection between the machine and the user device. 
- VDAs also verify that a Citrix license is available for the user or session, and apply policies that are configured for the session.
- VDAs are available for single-session and multi-session Windows operating systems. VDAs for multi-session Windows operating systems allow multiple users to connect to the server at a time. VDAs for single-session Windows operating systems allow only one user to connect to the desktop at a time.
options:
  vda_installer_url:
    description:
    - Download link for the Citrix VDA Installer
    - Can be a link to the VDAServerSetup.exe file to install VDA for a multi-session OS or a link to the VDAWorkstationSetup.exe file to install VDA for a single-session OS
    - Currently supported versions are 2407 and up
    type: str
    required: yes
  max_retries:
    description:
    - Maximum number of times the module can be invoked by the playbook in a single run
    - VDA installation can require system reboots during the installation process. If a system reboot is required, the module will set the reboot_required flag to `true`. The playbook would then have to reboot the windows VM and call the vda_installer module again to resume the installation process
    type: int
  arguments:
    description:
    - Different components of the VDA installer that can be enabled or disabled. Please refer to https://docs.citrix.com/en-us/citrix-daas/install-configure/install-vdas/install-command.html to understand the different options that are available
    - The options currently supported by the module are listed below
    type: dict
    suboptions:
      plugins:
        description:
        - Installs the Citrix Workspace app for Windows
        default: true
        type: bool
      enable_hdx_ports:
        description:
        - Opens ports in the Windows firewall required by the VDA and enabled features (except Windows Remote Assistance), if the Windows Firewall Service is detected, even if the firewall is not enabled. If you are using a different firewall or no firewall, you must configure the firewall manually.
        default: true
        type: bool
      enable_hdx_udp_ports:
        description:
        - Opens UDP ports in the Windows firewall that HDX adaptive transport requires, if the Windows Firewall Service is detected, even if the firewall is not enabled. If you are using a different firewall or no firewall, you must configure the firewall manually.
        default: true
        type: bool
      enable_real_time_transport:
        description:
        - Enables or disables use of UDP for audio packets (RealTime Audio Transport for audio). Enabling this feature can improve audio performance.
        default: true
        type: bool
      enable_ss_ports:
        description:
        - Opens ports in the Windows Firewall that are required for screen sharing, if the Windows Firewall Service is detected, even if the firewall is not enabled. If you are using a different firewall or no firewall, you must configure the firewall manually.
        default: true
        type: bool
      citrix_mcs_io_driver:
        description:
        - MCS I/O or the Machine Creation Services (MCS) storage optimization feature uses file-based write cache technology, providing better performance and stability
        default: true
        type: bool
      citrix_rendezvous_v2:
        description:
        - When using the Citrix Gateway Service, the Rendezvous protocol allows VDAs to bypass the Citrix Cloud Connectors to connect directly and securely with the Citrix Cloud control plane. Rendezvous V2 is supported with standard domain joined machines, Hybrid Azure AD joined machines, Azure AD joined machines, and non-domain joined machines.
        default: true
        type: bool
      master_mcs_image:
        description:
        - Specifies that this machine will be used as an image with Machine Creation Services
        default: true
        type: bool
      send_experience_metrics:
        description:
        - Sends analytics collected during the installation, upgrade, or removal to Citrix
        default: true
        type: bool
      server_vdi:
        description:
        - Installs a single-session OS VDA on a supported Windows server. Set this to `false` when installing a multi-session VDA on a Windows server
        default: true
        type: bool
      virtual_machine:
        description:
        - Valid only when installing a VDA on a VM. Overrides detection by the installer of a physical machine, where BIOS information passed to VMs makes them appear as physical machines.
        default: true
        type: bool
      citrix_vda_upgrade:
        description:
        - Citrix VDA Upgrade Agent enables the installation of the latest VDA version on a machine that has an older version of the VDA installed.
        default: true
        type: bool
requirements:
- VDA versions 2407 and up are supported
- Currently, only supported for Windows environments
'''

EXAMPLES = r'''
  - name: Install VDA
    vda_installer:
      vda_installer_url: "{{ vda_installer_path }}"
      arguments:
        enable_hdx_ports: True
        enable_real_time_transport: True
        enable_hdx_udp_ports: True
        send_experience_metrics: True
        virtual_machine: True
        plugins: False
        server_vdi: False
        master_mcs_image: True
        citrix_mcs_io_driver: True
        citrix_rendezvous_v2: False
        citrix_vda_upgrade: True
    register: vda_installer_output
'''

RETURN = r'''
is_broker_agent_running:
  description: Indicates whether the Citrix Broker Agent service is running. If the Citrix Broker Agent service is running then the VDA installation was successful
  returned: always
  type: bool
  sample: true
reboot_required:
  description: Indicates whether a system reboot is required or not to complete the VDA installation
  returned: always
  type: bool
  sample: true
installer_return_code:
  description: 
  - VDA installer return code
  - Refer the L(citrix documentation, https://docs.citrix.com/en-us/citrix-virtual-apps-desktops/1912-ltsr/install-configure/install-prepare.html#citrix-installation-return-codes) for more information about VDA installer return codes
  returned: always
  type: int
  sample: 3
'''