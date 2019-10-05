<#
VMTools will not install correctly if rollback is disabled, see: https://kb.vmware.com/s/article/1032916
This script will look at the current configuration and update if needed.
At completion it reverts to discovered settings.  This entire script is PSv4 so that it can run under 2012R2 as needed.
#>

$currentRollbackState = (Get-ItemProperty -Path HKLM:\Software\Policies\Microsoft\Windows\Installer -ErrorAction SilentlyContinue).DisableRollback
if (($null -ne $currentRollbackState) -and ($currentRollbackState -ne 0)) {
  Write-Output "DisableRollback has been enabled, temporarily reverting to allow VMTools to complete ..."
  Set-ItemProperty -Path HKLM:\Software\Policies\Microsoft\Windows\Installer -Name DisableRollback -Value 0
  $revertRollbackState = $true
}

# The actual Install
Write-Output "Installing VMTools ..."
Start-Process -Filepath e:\setup64.exe -ArgumentList '/S /v "/qb REBOOT=ReallySuppress"' -NoNewWindow -Wait

<#
Occasionally services will not compeltely install for various reasons that the internet has not yet revealed to me.
Simply manually install them as needed using PowerShell
#>

# Define known VMTool services
$vmServices = @(
  [Hashtable]@{ 
    Name = "VGAuthService" 
    DisplayName = "VMware Alias Manager and Ticket Service"
    Description = "Alias Manager and Ticket Service"
    BinaryPathName = '"C:\Program Files\VMware\VMware Tools\VMware VGAuth\VGAuthService.exe"'
    StartupType = "Automatic"
  }
  [Hashtable]@{ 
    Name = "VMwareCAFCommAmqpListener" 
    DisplayName = "VMware CAF AMQP Communication Service"
    Description = "VMware Common Agent AMQP Communication Service"
    BinaryPathName = '"C:\Program Files\VMware\VMware Tools\VMware CAF\pme\bin\CommAmqpListener.exe"'
    StartupType = "Manual"
  }
  [Hashtable]@{ 
    Name = "VMwareCAFManagementAgentHost"
    DisplayName = "VMware CAF Management Agent Service"
    Description = "VMware Common Agent Management Agent Service"
    BinaryPathName = '"C:\Program Files\VMware\VMware Tools\VMware CAF\pme\bin\ManagementAgentHost.exe"'
    StartupType = "Manual"
  }
  [Hashtable]@{ 
    Name = "vmvss"
    DisplayName = "VMware Snapshot Provider"
    Description = "VMware Snapshot Provider"
    BinaryPathName = 'C:\Windows\system32\dllhost.exe /Processid:{8EDC99B4-1313-4F68-AECF-A4C45F322ECD}'
    DependsOn = "rpcss"
    StartupType = "Manual"
  }
  [Hashtable]@{ 
    Name = "VMTools"
    DisplayName = "VMware Tools"
    Description = "Provides support for synchronizing objects between the host and guest operating systems."
    BinaryPathName = '"C:\Program Files\VMware\VMware Tools\vmtoolsd.exe"'
    StartupType = "Automatic"
  }
)

# Check each service and recreate if missing
ForEach ($service in $vmServices) {
  Write-Output "Checking Service: $($service.DisplayName) ..."
  if (!(get-service $service.Name -ErrorAction SilentlyContinue)) {
    Write-Output "Service not found. Creating..."
    New-Service @service
  }
}

# Revert the regkey setting if it was changed
if ($revertRollbackState) {
  Write-Output "Re-applying original Rollback Settings ..."
  Set-ItemProperty -Path HKLM:\Software\Policies\Microsoft\Windows\Installer -Name DisableRollback -Value $currentRollbackState
}

#trim this to save 3 seconds, but I leave this in because VMTools is the devil and sometimes I need to screen cap an error.
Write-Output "Complete!"
Start-Sleep -Seconds 3 
