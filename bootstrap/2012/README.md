# File Contents

Bootstrrap files represent the bare minimum configuration in order to get the OS operational.  Basically handles OS installation and core drivers.

## autounattend.xml

answer file to ensure automatic/silent install of base OS.  It sets the default administrator password and initiates the install of both WinRM configuration and Vmtools installation

## vmtools.cmd

Part of early installation, runs vmtool installation so that VMware can detect/report IP information back to Packer.  Without this Packer would timeout waiting to start the provisioner phase.