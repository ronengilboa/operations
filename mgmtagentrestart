############################################################
### this script will restart the management services on all
### esxi servers in the get command (can be filtered)
### must be run within a folder with the executables:
### plink, pscp 
### 
### outputs alot of messages that can be ignored or stored
### in a variable.
### It starts the ssh before and stops it after it finishes.
### Ronen Gilboa 05/26/2016
############################################################

Add-PSSnapin vm*

Disconnect-VIServer * -Confirm:$false

Connect-VIServer vcenter-server-name

$esxis = get-vmhost | sort

$esxis | Get-VMHostService | where {$_.label -eq "ssh"} | Start-VMHostService -Confirm:$false

foreach ($esxi in $esxis)
{
     $name = $esxi.name + ":/"
     echo y | .\pscp.exe "F:\putty\a.txt" -unsafe -l root -pw password -ls $name
    .\plink.exe -l root -pw password -batch $esxi.name "services.sh restart"
}

$esxis | Get-VMHostService | where {$_.label -eq "ssh"} | Stop-VMHostService -Confirm:$false
