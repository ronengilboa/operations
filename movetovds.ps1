<#
    Migrate vms to be connected to vDS from std switch , and look for for vd port group that
    have the same vlan id as the std port group.
    gets vcenter server and vmhost and looks for its vds and than runs on vms

    created: Ronen Gilboa 07/26/2016
    ronengilboa@gmail.com
#>

function migratetovds {
    param ([parameter(Mandatory = $true)][string]$vcenter,
           [parameter(Mandatory = $true)] [string]$vmhost)

    try { Connect-VIServer $vcenter -ErrorAction stop
    }
    catch { Write-Host -ForegroundColor red ("Bad vcenter name: " + $vcenter)
    break
    }

    try { $esxi = Get-VMHost -Name $vmhost -ErrorAction Stop
    }
    catch { Write-Host -ForegroundColor red  ("Bad esxi name: " + $vmhost)
    break
    }

    
    
    try { $vds = $esxi | Get-VDSwitch -ErrorAction stop
    }
    catch { Write-Host -ForegroundColor red  ("no vds connected to $esxi.name")
    break
    }              

    $pgs = $vds | Get-VDPortgroup | where {$_.IsUplink -match "false"}
    $vms = $esxi | get-vm
    $vss = $esxi | Get-VirtualSwitch -Standard

    foreach ($vm in $vms)
    {
        Write-Host  -ForegroundColor Green ("Starting to work on $vm")
        $nics = $vm | Get-NetworkAdapter
        foreach ($nic in $nics)
        {
            Write-Host  -ForegroundColor Green ("Working on nic $nic")
            try {$spg = $vss | Get-VirtualPortGroup -name $nic.NetworkName -ErrorAction Stop}
            catch {Write-Host -ForegroundColor Red ("Cant find standard port group for this VM's NIC")
            break
            }
            $pg = $pgs | where {$_.vlanconfiguration.vlanid -eq $spg.VLanId} 
            try { $nic | Set-NetworkAdapter -Portgroup $pg -Confirm:$false -ErrorAction Stop | Out-Null}
            catch {Write-Host -ForegroundColor Red ("Cant configure the nic to virtual distributed port group the port group does not exist on the vds")
            break
            }
        }
        Write-Host -ForegroundColor Green ("finished vm $vm")
       
    }


    Write-Host -ForegroundColor Blue ("finished host $esxi.name ")
}
