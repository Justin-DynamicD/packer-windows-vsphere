# Packer Windows Server VSphere

Working sample code to generate Server Core templates used in Vsphere.  Requires 2 ISOs:

* installation media
* vmtools media

The autounattend file will assume the vmtools iso is the 2nd cdrom mounted in drive `E:` in order to load pvscsi and vmxnet3 drivers.  Also, there is no sysprep run in this build, as VMware automatically runs sysprep when a VM is deployed from template.  Sample datastore paths are in the file.

There are multiple definitions for the various server versions (server 2012,server 2016, etc.) due to differeing requirements between them.  All images currently standardize on WMF 5.1 (PowerShell 5.1)

## Required Modules

The following 3rd party modules are required by this build, and should be placed in the same folder as the packer executable.

| module | URL |
|--------|-----|
| windows-update | <https://github.com/rgl/packer-provisioner-windows-update> |

Note vsphere-iso has been merged into the official packer binary, and thus is no longer required as a seperate module.

## Running the build

The build will check environment variables for VCenter details, as well as login information.  I find it easiest to either add this information into your profile or simply cut-n-paste it in as needed when doing dev work ... keeps pesky passwords out of code and all.

PowerShell:

```PowerShell
$env:VCENTER_SERVER = "vcenter.contoso.com"
$env:VCENTER_USER = "contoso\JoeAdmin"
$env:VCENTER_PASSWORD = "Password!"
$env:VCENTER_DATACENTER = "LAX"
$env:VCENTER_DATASTORE = "SAN01"
$env:VCENTER_CLUSTER = "Prod"
$env:VCENTER_NETWORK = "Data Port Group"
$env:VCENTER_HOST = "server01.contoso.com"
```

Bash:

```Bash
export VCENTER_SERVER="vcenter.contoso.com"
export VCENTER_USER="contoso\JoeAdmin"
export VCENTER_PASSWORD="Password!"
export VCENTER_DATACENTER="LAX"
export VCENTER_DATASTORE="SAN01"
export VCENTER_CLUSTER="Prod"
export VCENTER_NETWORK="Data Port Group"
export VCENTER_HOST="server01.contoso.com"
```
