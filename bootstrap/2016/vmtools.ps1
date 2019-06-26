# This install is a bit flakey, as services do not always install correctly in 2016
# Uses PowerSHell to rectify
Write-Output "Installing VMTools ..."
Start-Process -Filepath e:\setup64.exe -ArgumentList '/S /l C:\Windows\Temp\vmware_tools.log /v "/qb REBOOT=ReallySuppress"' -NoNewWindow -Wait

# This defines all servies created by VMTools so we can verify the installation was actually sucessfull
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
  Write-Output "Checking Service: $($service.DisplayName)"
  if (!(get-service $service.Name -ErrorAction SilentlyContinue)) {
    Write-Output "Service not found. Creating..."
    New-Service @service
  }
}