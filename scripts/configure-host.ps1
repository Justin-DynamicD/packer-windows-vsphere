# Gather OS information to help determine what code to run
$oSVersion = ([system.version](Get-WMIObject win32_operatingsystem).Version)

###
#
# Common
#
###

# Installs Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Installs git, and updates path
choco install git -y
$CurrentPath = (Get-Itemproperty -path 'hklm:\system\currentcontrolset\control\session manager\environment' -Name Path).Path
$NewPath = $CurrentPath + ";$($env:ProgramFiles)\Git\cmd"
Set-ItemProperty -path 'hklm:\system\currentcontrolset\control\session manager\environment' -Name Path -Value $NewPath

###
#
# Server 2016 only 
#
###

If ($oSVersion.Major -eq 10) {
    Write-Output "Starting Server 2016 configurations..."
    Write-Output "Removing conflicting Windows features..."
    Remove-WindowsFeature -Name "Windows-Defender" -IncludeManagementTools
}