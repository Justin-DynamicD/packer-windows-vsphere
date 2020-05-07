###
#
# Common
#
###
$ErrorActionPreference = "Stop"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Installs NuGet Package Manager
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force

# Installs Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Installs git, and updates path
choco install git -y
$CurrentPath = (Get-Itemproperty -path 'hklm:\system\currentcontrolset\control\session manager\environment' -Name Path).Path
$NewPath = $CurrentPath + ";$($env:ProgramFiles)\Git\cmd"
Set-ItemProperty -path 'hklm:\system\currentcontrolset\control\session manager\environment' -Name Path -Value $NewPath

# Disable the DSC LCM so external services cannot interfere with configuration
[DscLocalConfigurationManager()]
Configuration LCMSettings {
  Node localhost
  {
    Settings
    {
      RefreshMode = "Disabled"
    }
  }
}
LCMSettings
Set-DscLocalConfigurationManager -Path .\LCMSettings -Verbose

# Install DSC Resource Modules for customization during deployment
Update-Module -Force -Verbose
Install-Module -Name CertificateDsc -Force -Verbose # certificate installation
Install-Module -Name NetworkingDsc -Force -Verbose # allows setting IP/network settings
Install-Module -Name ComputerManagementDsc -Force -Verbose # Computer renaming, ProductKey Installation
