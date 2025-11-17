#AnsibleRequires -CSharpUtil Ansible.Basic

Set-StrictMode -Version 2

$ErrorActionPreference = 'Stop'

$spec = @{
    options = @{
        vda_installer_url = @{ type = "str"; required = $true }
        max_retries = @{ type = "int"; default = 5 }
        arguments = @{
            type = 'dict'
            options = @{
                plugins = @{ type = 'bool'; default = $true }
                enable_hdx_ports = @{ type = 'bool'; default = $true }
                enable_hdx_udp_ports = @{ type = 'bool'; default = $true }
                enable_real_time_transport = @{ type = 'bool'; default = $true }
                enable_ss_ports = @{ type = 'bool'; default = $true }
                citrix_mcs_io_driver = @{ type = 'bool'; default = $true }
                citrix_rendezvous_v2 = @{ type = 'bool'; default = $true }
                master_mcs_image = @{ type = 'bool'; default = $true }
                send_experience_metrics = @{ type = 'bool'; default = $true }
                server_vdi = @{ type = 'bool'; default = $true }
                virtual_machine = @{ type = 'bool'; default = $true }
                citrix_vda_upgrade = @{ type = 'bool'; default = $true }
            }
        }
    }
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

$vda_installer_url = $module.Params.vda_installer_url
$max_retries = $module.Params.max_retries
$plugins = $module.Params.arguments.plugins
$enable_hdx_ports = $module.Params.arguments.enable_hdx_ports
$enable_hdx_udp_ports = $module.Params.arguments.enable_hdx_udp_ports
$enable_real_time_transport = $module.Params.arguments.enable_real_time_transport
$enable_ss_ports = $module.Params.arguments.enable_ss_ports
$citrix_mcs_io_driver = $module.Params.arguments.citrix_mcs_io_driver
$citrix_rendezvous_v2 = $module.Params.arguments.citrix_rendezvous_v2
$master_mcs_image = $module.Params.arguments.master_mcs_image
$send_experience_metrics = $module.Params.arguments.send_experience_metrics
$server_vdi = $module.Params.arguments.server_vdi
$virtual_machine = $module.Params.arguments.virtual_machine
$citrix_vda_upgrade = $module.Params.arguments.citrix_vda_upgrade

$xen_desktop_installer_path = "$($ENV:ProgramData)\Citrix\XenDesktopSetup\XenDesktopVdaSetup.exe"
$vda_installer_path = "C:\VdaInstaller.exe"
$vda_failure_return_codes = @(1, 4, 6, 11, 12, 13)
$broker_agent_service_name = "BrokerAgent"

$retry_count_registry_path = "HKLM:\SOFTWARE\Citrix\VdaInstaller"
$retry_count_registry_name = "RetryCount"

$module.Result.is_broker_agent_running = $false
$module.Result.changed = $false
$module.Result.reboot_required = $false

function Check-BrokerAgentStatus {
    # Check if Broker Agent is running 
    $broker_agent_service = Get-Service -Name $broker_agent_service_name -ErrorAction SilentlyContinue
    if ($broker_agent_service -ne $null) {
        if ($broker_agent_service.Status -eq "Stopped") {
            Start-Service -Name $broker_agent_service_name
            $broker_agent_service.WaitForStatus('Running', '00:01:00')
        }
        if ($broker_agent_service.Status -eq "Running") {
            $module.Result.is_broker_agent_running = $true
            return $true
        }
    }
    return $false
}

function Get-VdaAInstallerArguments {
    $arguments = '/quiet /noreboot /noresume /components vda'
    if ($plugins) {
        $arguments += ',plugins'
    }
    if ($enable_hdx_ports) {
        $arguments += ' /enable_hdx_ports'
    }
    if ($enable_hdx_udp_ports) {
        $arguments += ' /enable_hdx_udp_ports'
    }
    if ($enable_real_time_transport) {
        $arguments += ' /enable_real_time_transport'
    }
    if ($enable_ss_ports) {
        $arguments += ' /enable_ss_ports'
    }
    if ($master_mcs_image) {
        $arguments += ' /mastermcsimage'
    }
    if ($send_experience_metrics) {
        $arguments += ' /sendexperiencemetrics'
    }
    if ($server_vdi) {
        $arguments += ' /servervdi'
    }
    if ($virtual_machine) {
        $arguments += ' /virtualmachine'
    }

    $include_additional_arguments = ''
    if ($citrix_mcs_io_driver) {
        $include_additional_arguments += ' "Citrix MCS IODriver"'
    }
    if ($citrix_rendezvous_v2) {
        $include_additional_arguments += ' "Citrix Rendezvous V2"'
    }
    if ($citrix_vda_upgrade) {
        $include_additional_arguments += ' "Citrix VDA Upgrade Agent"'
    }

    if ($include_additional_arguments -ne '') {
        $arguments += ' /includeadditional' + $include_additional_arguments
    }

    return $arguments
}

function Resume-Installation {
    try {
        $process = Start-Process -FilePath $xen_desktop_installer_path -Wait -PassThru
        $return_code = $process.ExitCode
        
        if ($return_code -in $vda_failure_return_codes) {
            $module.FailJson("Installation failed with return code: $return_code")
        }
        else {
            
            # Check if Broker Agent is running
            Check-BrokerAgentStatus
                
            $module.Result.changed = $true
            $module.Result.reboot_required = $true
            $module.Result.installer_return_code = $return_code
        }
    } catch {
        $module.FailJson("Exception occurred when running the installer. Exception: $($_.Exception.Message)")
    }
}

function Start-Installation {

    # Cleanup Installer if already present
    if (Test-Path $vda_installer_path) {
        Remove-Item -Path $vda_installer_path -Force
    }

    try {
        Invoke-WebRequest -Uri $vda_installer_url -OutFile $vda_installer_path
    } catch {
        $module.FailJson("Exception occurred when downloading Citrix vda installer. Exception: $($_.Exception.Message)", $_)
    }

    $arguments = Get-VdaAInstallerArguments

    try {
        $module.Result.arguments = $arguments
        $module.Result.filepath = $vda_installer_path

        $process = Start-Process -FilePath $vda_installer_path -ArgumentList $arguments -Wait -PassThru
        $return_code = $process.ExitCode
        
        if ($return_code -in $vda_failure_return_codes) {
            $module.FailJson("Installation failed with return code: $return_code")
        }
        else {
            Check-BrokerAgentStatus

            $module.Result.changed = $true
            $module.Result.reboot_required = $true
            $module.Result.installer_return_code = $return_code
        }
    } catch {
        $module.FailJson("Exception occurred when running the installer. Exception: $($_.Exception.Message)")
    }
}

if (Check-BrokerAgentStatus) {
    $module.ExitJson()
}

$retry_count = 0
try
{
    if (Test-Path $retry_count_registry_path) {
        $retry_count = (Get-ItemProperty -Path $retry_count_registry_path -Name $retry_count_registry_name).$retry_count_registry_name
        if ($retry_count -ge $max_retries) {
            $module.FailJson("Maximum retries reached. Retry count: $retry_count")
        }
    } else {
        New-Item -Path $retry_count_registry_path -Force | Out-Null
        New-ItemProperty -Path $retry_count_registry_path -Name $retry_count_registry_name -Value $retry_count -PropertyType DWORD -Force | Out-Null
    }
} catch {
    $module.FailJson("Failed to read retry count registry key. Exception: $($_.Exception.Message)")
}

if (Test-Path $xen_desktop_installer_path) {
    Resume-Installation
} else {
    Start-Installation
}

#Increment value of retry_count registry key
$retry_count++
try{
    Set-ItemProperty -Path $retry_count_registry_path -Name $retry_count_registry_name -Value $retry_count -Force
} catch {
    $module.FailJson("Failed to update retry count registry key. Exception: $($_.Exception.Message)")
}

$module.ExitJson()