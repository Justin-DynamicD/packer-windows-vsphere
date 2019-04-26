# Gather OS information to help determine what code to run
$oSVersion = ([system.version](Get-WMIObject win32_operatingsystem).Version)

# Server 2016 only 
If ($oSVersion.Major -eq 8) {
    Write-Output "Starting Server 2016 configurations..."
    Write-Output "Removing conflicting Windows features..."
    Remove-WindowsFeature -Name "Windows-Defender" -IncludeManagementTools
}