param (
  [string]$packerver,
  [string]$packerurl = "https://releases.hashicorp.com/packer",
  [Array]$modules = @(
    [PSCustomObject]@{ 
      Owner = "jetbrains-infra" 
      Repo = "packer-builder-vsphere"
      FileName = "packer-builder-vsphere-iso.exe"
      DownloadName = "packer-builder-vsphere-iso.exe"
      Unzip = $false
      Version = "v2.3"
    }
    [PSCustomObject]@{ 
      Owner = "rgl" 
      Repo = "packer-provisioner-windows-update"
      FileName = "packer-provisioner-windows-update.exe"
      DownloadName = "packer-provisioner-windows-update-windows.zip"
      Unzip = $true
      Version = "v0.7.1"
    }
  )
)

# Global Settings
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$ErrorActionPreference = "Stop"

###
#
# Packer Download
#
###

# Check for packer versions online and compare with requested version if provided
$results = (Invoke-WebRequest $packerurl -UseBasicParsing).links
$packerversions = ($results.href | Where-Object { $_ -like "/packer/*" })
$trimmedVersions = ($packerversions | Sort-object -Descending).TrimStart("/packer/").TrimEnd("/")
[System.Collections.ArrayList]$formattedVersions = @()
$trimmedVersions | ForEach-Object {
  try {
    $formattedVersions.add([version]$_) | Out-Null
  }
  catch{}
}
$packerlatest = [string]($formattedVersions | Sort-Object -Descending)[0]
Write-Verbose "Latest Packer Version: $packerlatest"
if ($packerver) {
  if (!($packerversions -contains "/packer/$($packerver)/")) {
    Write-Error "Desired version $packerver does not exist online!" -ErrorAction stop
  }
  $packerReq = $packerver
}
else {
  $packerReq = $packerlatest
}
Write-Output "Packer desired version: $packerReq"

#Check for the locally installed packer and validate version
if (Test-Path .\packer.exe -PathType Leaf) {
  $PackerCurr = .\packer.exe -version
  Write-Output "Discovered Packer: $packerCurr"
  $PackerInst = $true
}
Else {
  $PackerInst = $false
}

#Download and expand if needed
if (!$PackerInst -or ($packerInst -and ($PackerCurr -ne $packerReq))) {
  Write-Output "Downloading zip: packer_$($packerReq)_windows_amd64.zip"
  Invoke-WebRequest "$($packerurl)/$($packerReq)/packer_$($packerReq)_windows_amd64.zip" -UseBasicParsing -OutFile ".\packer_$($packerReq)_windows_amd64.zip"
  Write-Output "Extracting Packer"
  Expand-Archive ".\packer_$($packerReq)_windows_amd64.zip" -DestinationPath .\ -Force
}

###
#
# Module Download
#
###

# looping all the defined modules
foreach ($module in $modules) {

  #If the version is undefined, set to latest
  if ($module.Version) {
    $versionURL = "tags/$($module.Version)"
  }
  else {
    $versionURL = "latest"
  }

  # there is no version control in packer modules, so the best we can do is see if a file exists
  if (!(Test-Path $module.FileName -PathType Leaf)) {  
    try {
      $results = (invoke-webrequest "https://api.github.com/repos/$($module.Owner)/$($module.Repo)/releases/$($versionURL)" -UseBasicParsing).Content | ConvertFrom-Json
      $asset = $results.assets | Where-Object { $_.name -eq $module.DownloadName }
      Write-Output "Downloading asset: $($asset.name)"
      Invoke-WebRequest $asset.browser_download_url -UseBasicParsing -OutFile $asset.name
      if ($module.Unzip) {
        Write-Output "Extracting Zip"
        Expand-Archive ".\$($asset.name)" -DestinationPath .\ -Force
      }
    }
    catch {
      Write-Error "unable to find $($module.Repo) version $($module.Version)" -ErrorAction Stop
    }
  }
}
