<#
    create std switch on a host using vmnic2,3 using the same names / vlan id's 
    from the vds that is attahced to that host.



    created: Ronen Gilboa 06/21/2016
    ronengilboa@gmail.com
#>

function createstdsw {
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

    try { $vss = $esxi | new-VirtualSwitch -Name vswitch0 -nic vmnic2,vmnic3 -Confirm:$false -ErrorAction Stop
    }
    catch { Write-Host  -ForegroundColor red ("cant create std switch on $esxi.name")
    break
    }

    try { $vss | Get-SecurityPolicy | Set-SecurityPolicy -AllowPromiscuous $false -ForgedTransmits $false -MacChanges $false -Confirm:$false -ErrorAction Stop | Out-Null
    }
    catch { Write-Host  -ForegroundColor red ("cant update security policy on std switch on $esxi.name")
    break
    }

    foreach ($pg in $pgs)
    {
        try {  
                if ($pg.VlanConfiguration.VlanId -gt 0) {
                    $newpg = $vss | New-VirtualPortGroup -Name $pg.Name -VLanId $pg.VlanConfiguration.VlanId -Confirm:$false }
                    else
                    {$newpg = $vss | New-VirtualPortGroup -Name $pg.Name -Confirm:$false }
                Write-Host -ForegroundColor green ("created $pg.name ")
        }
        catch { Write-Host -ForegroundColor red  ("failed to create std porg group $pg.name")
        break
        }
    }
    Write-Host -ForegroundColor Blue ("finished host $esxi.name ")
}
