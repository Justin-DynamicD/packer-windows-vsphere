# File Contents

Scripts in this folder run OS customizations with some initial grouping.  Tweak away.

## cleanup.ps1

Final script run, scrubs temp directories and whitespace to ensure final machine is pristine for use as a template.

## configure-host.ps1

General OS configuration. Content currently installs Chocolatey, Git, and then some DSC Modules to aide in deployment. Obviously all of this can be changed.

## winrm.ps1

This was taken from Ansible as its a very complete winrm configuration job.  Will create a self-signed certificate, assign it to winrm, then enable authentication methods while ensuring unencrypted authentication remains disabled.  Bonus points: the resulting server is ready for Ansible, too :)

## wmf51.cmd

Installs WMF51 which includes PowerShell 5.1.  Used during Server 2012 installs to ensure later PowerShell scripts run consistently, not included with 2016.
