##########################################################################
#### Check if shared folders is installed on windows vm
#### Checks the registry key that is responsible
#### should be run just on windows vms
#### To address vmtools vulnerability , requires powercli.
####
####
#### Author: Ronen Gilboa, ronengilboa@gmail.com
#### 
##########################################################################

connect-viserver vcserver

$vms =  get-vm | where {$_.powerstate -eq "poweredon"}
$vms.count

$creds = Get-Credential

$resultsprod =@()
foreach ($vm in $vms)
{
    #get dns name of the vm and remove the domain, no need for fqdn
    $dnsname = $vm.extensiondata.summary.guest.hostname.trimend(".domain.local")

    try {
        $session = New-PSSession -ComputerName   $dnsname -Credential $creds  -ErrorAction Stop
        }
    catch {
        Write-Host ($dnsname + " is down")
        continue
    }
    $answer = Invoke-Command -Session $session -ScriptBlock {pushd;
    Set-Location HKLM:\SYSTEM\CurrentControlSet\Control\NetworkProvider;
    get-ItemProperty Order;
    popd;
    }
    Write-Host ($dnsname + " is up")
    $resultsprod += $answer 
}
$resultsprod.Count

$resultsprod | select pscomputername,providerorder | Export-Csv -Path hgfsprod.txt -NoTypeInformation

