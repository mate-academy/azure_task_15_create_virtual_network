$scriptContent = Get-Content ./task.ps1

if ($scriptContent | Where-Object {$_.ToLower().Contains("new-azresourcegroup")}) {
    Write-Host "Checking if script creates a resource group - ok"
} else {
    throw "Script is not creating a resource group, please review it. "
}

if ($scriptContent | Where-Object {$_.ToLower().Contains("new-azvirtualnetworksubnetconfig") -or $_.ToLower().Contains("add-azvirtualnetworksubnetconfig")}) {
    Write-Host "Checking if script creates subnets - ok"
} else {
    throw "Script is not creating subnets, please review it. "
}

if ($scriptContent | Where-Object {$_.ToLower().Contains("new-azvirtualnetwork")}) {
    Write-Host "Checking if script creates a virtual network - ok"
} else {
    throw "Script is not creating a virtual network, please review it. "
}


$vnet = @{
    Name = 'todoapp'
    ResourceGroupName = 'mate-azure-task-15'
    Location = 'uksouth'
    AddressPrefix = '10.20.30.0/24'
}
$virtualNetwork = New-AzVirtualNetwork @vnet

$subnet = @{
    Name = 'webservers'
    VirtualNetwork = $virtualNetwork
    AddressPrefix = '10.20.30.0/26'
}
Add-AzVirtualNetworkSubnetConfig @subnet

$subnet = @{
    Name = 'database'
    VirtualNetwork = $virtualNetwork
    AddressPrefix = '10.20.30.64/26'
}
Add-AzVirtualNetworkSubnetConfig @subnet

$subnet = @{
    Name = 'management'
    VirtualNetwork = $virtualNetwork
    AddressPrefix = '10.20.30.128/26'
}
Add-AzVirtualNetworkSubnetConfig @subnet

$virtualNetwork | Set-AzVirtualNetwork