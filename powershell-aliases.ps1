<#
.SYNOPSIS
    .
.DESCRIPTION
    .
.PARAMETER VagrantFile 
    The path to the Vagrantfile to use .
.PARAMETER Name 
    Name of the resulting VM .
.PARAMETER DataDir
		Path of the directory to sync with the VM .
.PARAMETER Provision
		Whether or not to call vagrant up - ommission of this flag simply copies the Vagrantfile to the current dir .
.PARAMETER Gui
		Whether or not to start the VM with a GUI .
.EXAMPLE
		V-Init -Vagrantfile "C:\Vagrantfiles\kali\Vagrantfile" -Name "mykali" -DataDir ".\data" -Provision .

.NOTES
    Author: Cory Sabol 
#>
function V-Init {
  param (
    [String]$VagrantFile = 'D:\Vagrantfiles\kali\Vagrantfile',
    [String]$Name = '',
    [String]$DataDir = '.\data',
    [switch]$Provision,
    [switch]$Gui
  )
  if ($Name -eq '') {
    $p = Split-Path -leaf -path (Get-Location)
    $d = Get-Date -UFormat "%m%d%Y"
    $Name = "$p-$d"
  }
  Copy-Item "$VagrantFile" -Destination . 
  if ($Provision) {
    $env:VMNAME=$Name
    $env:DATADIR=$DataDir
    if ($env) {
      $env:GUI=$Gui
    }
    vagrant up
  }
}

function V-Halt { 
  vagrant halt
}

function V-Destroy {
  V-Halt; if ($?) { vagrant destroy --force }
}

# Todo: emit a env file into .Vagrant that can be loaded into the vagrant script for reprovisioning.
function V-Rebuild {
  V-Destroy; if ($?) {}
}
