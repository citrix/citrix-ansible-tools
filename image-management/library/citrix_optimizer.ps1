#AnsibleRequires -CSharpUtil Ansible.Basic

Set-StrictMode -Version 2

$spec = @{
    options = @{
        optimizer_zip_url = @{ type = "str"; required = $true }
        template_file_name = @{ type = "str"; required = $true }
        destination_path = @{ type = "str"; default = 'C:\' }
        retain_logs = @{ type = "bool"; default = $false }
        force = @{ type = "bool"; default = $false }
    }
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

$url = $module.Params.optimizer_zip_url
$templateFileName = $module.Params.template_file_name
$destinationPath = $module.Params.destination_path
$retainLogs = $module.Params.retain_logs
$force = $module.Params.force

$optimizerRegistryPath = "HKLM:\SOFTWARE\Citrix\Optimizer\OS Optimizations"
$modeRegistryName = "run_mode"
$runStatusRegistryName = "run_successful"
$logPathRegistryName = "log_path"
$engineVersionRegistryName = "engineversion"
$lastExecutionDateTimeRegistryName = "time_end"

$modeRegistryValue = ""
$runStatusRegistryValue = ""
$logPathRegistryValue = ""
$engineVersionRegistryValue = ""
$lastExecutionDateTimeRegistryValue = ""

$module.Result.run_mode = $null
$module.Result.run_status = $null
$module.Result.optimizer_version = $null
$module.Result.last_execution_time = $null

if (-not $force -and (Test-Path $optimizerRegistryPath))
{
    $modeRegistryValue = (Get-ItemProperty -Path $optimizerRegistryPath -Name $modeRegistryName).$modeRegistryName
    $runStatusRegistryValue = (Get-ItemProperty -Path $optimizerRegistryPath -Name $runStatusRegistryName).$runStatusRegistryName
    $engineVersionRegistryValue = (Get-ItemProperty -Path $optimizerRegistryPath -Name $engineVersionRegistryName).$engineVersionRegistryName
    $lastExecutionDateTimeRegistryValue = (Get-ItemProperty -Path $optimizerRegistryPath -Name $lastExecutionDateTimeRegistryName).$lastExecutionDateTimeRegistryName

    if ($runStatusRegistryValue) {
        $module.Result.changed = $false
        $module.Result.run_mode = $modeRegistryValue
        $module.Result.run_status = $runStatusRegistryValue
        $module.Result.optimizer_version = $engineVersionRegistryValue
        $module.Result.last_execution_time = $lastExecutionDateTimeRegistryValue
        $module.ExitJson()
    }
}

if (-not $destinationPath.EndsWith("\")) {
    $destinationPath += "\"
}

if (-not (Test-Path $destinationPath)) {
    # Create the destination path
    try {
        New-Item -Path $destinationPath -ItemType Directory -Force
    } catch {
        $module.FailJson("Exception occurred when creating folder path: $destinationPath. Exception: $($_.Exception.Message)", $_)
    }
}

# If Citrix Optimizer already exists then delete it
$citrixOptimizerFileZipPath = $destinationPath + 'CitrixOptimizer.zip'
$citrixOptimizerFileUnzipPath = $destinationPath + 'CitrixOptimizer'
if (Test-Path $citrixOptimizerFileZipPath) {
    Remove-Item -Path $citrixOptimizerFileZipPath -Force
}
if (Test-Path $citrixOptimizerFileUnzipPath) {
    Remove-Item -Path $citrixOptimizerFileUnzipPath -Recurse -Force
}

try {
    Invoke-WebRequest -Uri $url -OutFile $citrixOptimizerFileZipPath
} catch {
    $module.FailJson("Exception occurred when downloading citrix optimizer. Exception: $($_.Exception.Message)", $_)
}

# # Unzip the optimizer
try {
    Expand-Archive -LiteralPath $citrixOptimizerFileZipPath -DestinationPath $citrixOptimizerFileUnzipPath
} catch {
    $module.FailJson("Exception occurred when unzipping citrix optimizer. Exception: $($_.Exception.Message)", $_)
}

$citrixOptimizerEnginePath = $citrixOptimizerFileUnzipPath + '\CtxOptimizerEngine.ps1'

# Check if template file exists and ensure it has .xml extension
if (-not $templateFileName.EndsWith(".xml")) {
    $templateFileName += ".xml"
}
$citrixOptimizerTemplatePath = $citrixOptimizerFileUnzipPath + '\Templates\' +  $templateFileName
if (-not (Test-Path $citrixOptimizerTemplatePath)) {
    $module.FailJson("Template file " + $templateFileName + " could not be found. Please check the file name and try again. Exception: $($_.Exception.Message)", $_)
}

$command = "& $citrixOptimizerEnginePath -Source $citrixOptimizerTemplatePath -Mode 'Execute'"

# Start the job
try {
    $job = Start-Job -ScriptBlock {
        param ($cmd)
        Invoke-Expression -Command $cmd
    } -ArgumentList $command

    # Wait for the job to complete and capture the output
    $job | Wait-Job
} catch {
    $module.FailJson("Exception occurred when executing the Citrix Optimizer. Exception: $($_.Exception.Message)", $_)
}

$module.Result.changed = $true

# Cleanup
if (Test-Path $citrixOptimizerFileZipPath) {
    Remove-Item -Path $citrixOptimizerFileZipPath -Force
}

if ($retainLogs) {
    $logDestinationFolderPath = $destinationPath + 'CitrixOptimizerLogs'
    try {
        if (-not (Test-Path $logDestinationFolderPath)) {
            New-Item -Path $logDestinationFolderPath -ItemType Directory
        }
        $optimizerLogFolderPath = $citrixOptimizerFileUnzipPath + '\Logs'
        $optimizerLogPath = Get-ChildItem -Path $optimizerLogFolderPath -Directory | Sort-Object LastWriteTime -Descending | Select-Object -First 1
        Move-Item -Path $optimizerLogPath.FullName -Destination $logDestinationFolderPath -Force
        $module.Result.log_path = $logDestinationFolderPath
    } catch {
        $module.FailJson("Failed to retain logs: $($_.Exception.Message)", $_)
    }
}

if (Test-Path $citrixOptimizerFileUnzipPath) {
    Remove-Item -Path $citrixOptimizerFileUnzipPath -Recurse -Force
}

# Get registry values
if (-not (Test-Path $optimizerRegistryPath))
{
    $module.Result.Warn("Citrix Optimizer status could not be retrieved because you might be running an older version. Please use version 2.9 above for best results")
    $module.ExitJson()
}

$module.Result.run_mode = (Get-ItemProperty -Path $optimizerRegistryPath -Name $modeRegistryName).$modeRegistryName
$module.Result.run_status = (Get-ItemProperty -Path $optimizerRegistryPath -Name $runStatusRegistryName).$runStatusRegistryName
$module.Result.optimizer_version = (Get-ItemProperty -Path $optimizerRegistryPath -Name $engineVersionRegistryName).$engineVersionRegistryName
$module.Result.last_execution_time = (Get-ItemProperty -Path $optimizerRegistryPath -Name $lastExecutionDateTimeRegistryName).$lastExecutionDateTimeRegistryName

$module.ExitJson()
