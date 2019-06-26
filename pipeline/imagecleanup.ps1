param (
  [string]$nameprefix = "packer-win2012",
  [int]$retention = 5,
  [bool]$lookuponly = $false,
  [string]$VCENTER_SERVER = $env:VCENTER_SERVER,
  [string]$VCENTER_CLUSTER = $env:VCENTER_CLUSTER,
  [string]$VCENTER_DATACENTER = $env:VCENTER_DATACENTER,
  [string]$VCENTER_DATASTORE = $env:VCENTER_DATASTORE,
  [string]$VCENTER_HOST = $env:VCENTER_HOST,
  [string]$VCENTER_NETWORK = $env:VCENTER_NETWORK,
  [System.Management.Automation.PSCredential]$credential = (New-Object System.Management.Automation.PSCredential ($env:VCENTER_USER, (ConvertTo-SecureString $env:VCENTER_PASSWORD -AsPlainText -Force)))
)

# Global Settings
$ErrorActionPreference = "Stop"

# If VMware.PowerCLI is missing, install/import it
If (!(get-module -ListAvailable -Name VMware.PowerCLI)) {
  Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
  Install-Module -Name VMware.PowerCLI -AllowClobber -Force
} 
ElseIf (!(get-module -Name VMware.PowerCLI)) {
  Import-Module -Name VMware.PowerCLI
}

# Attempt to loginto VCenter
Try {
  Write-Output "logging into $VCENTER_SERVER"
  Set-PowerCLIConfiguration -Scope User -ParticipateInCEIP:$false -InvalidCertificateAction Ignore -Confirm:$false
  Connect-VIServer -Server $VCENTER_SERVER -Credential $credential
}
catch {
  Write-Error "unable to authenticate to $VCENTER_SERVER, please verify server and credentials" -ErrorAction Stop
}

#find servers, count and sort
[System.Collections.ArrayList]$discoveredTemplates = @()
$discoveredTemplates += get-template | Where-Object { $_.Name -like "$($nameprefix)*"}
Write-Output "Searching for: $nameprefix"
Write-Output "Templates found: $($discoveredTemplates.count)"
  While (($discoveredTemplates.count -gt $retention) -and !($lookuponly)) {
    try {
      $targetTemplate = ($discoveredTemplates | Sort-Object)[0]
      Write-Output "Removing Template: $($targetTemplate.Name)"
      Remove-Template -Template $targetTemplate -DeletePermanently:$true -Confirm:$false
      $discoveredTemplates.Remove($targetTemplate)
    }
    catch {
      Disconnect-VIServer -Confirm:$false
      Write-Error "Error removing template, please verify permissions" -ErrorAction Stop
    }
  }
# work complete, disconnect from VCenter
Disconnect-VIServer -Confirm:$false

# Report back if there were any matches
If ($discoveredTemplates.count -gt 0) {
  Write-Output "##vso[task.setvariable variable=buildExists;]$true"
} Else {
  Write-Output "##vso[task.setvariable variable=buildExists;]$false"
}