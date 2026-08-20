$location = "denmarkeast"
$resourceGroupName = "mate-azure-task-15"

$virtualNetworkName = "todoapp"
$vnetAddressPrefix = "10.20.30.0/24"

$webSubnetName = "webservers"
$webSubnetIpRange = "10.20.30.0/26"

$dbSubnetName = "database"
$dbSubnetIpRange = "10.20.30.64/26"

$mngSubnetName = "management"
$mngSubnetIpRange = "10.20.30.128/26"

Write-Host "Creating a resource group $resourceGroupName ..."
New-AzResourceGroup -Name $resourceGroupName -Location $location

Write-Host "Creating a virtual network ..."
$vnet = New-AzVirtualNetwork `
    -Name $virtualNetworkName `
    -ResourceGroupName $resourceGroupName `
    -Location $location `
    -AddressPrefix $vnetAddressPrefix

Write-Host "Creating webservers subnet ..."
Add-AzVirtualNetworkSubnetConfig `
    -Name $webSubnetName `
    -VirtualNetwork $vnet `
    -AddressPrefix $webSubnetIpRange

Write-Host "Creating database subnet ..."
Add-AzVirtualNetworkSubnetConfig `
    -Name $dbSubnetName `
    -VirtualNetwork $vnet `
    -AddressPrefix $dbSubnetIpRange

Write-Host "Creating management subnet ..."
Add-AzVirtualNetworkSubnetConfig `
    -Name $mngSubnetName `
    -VirtualNetwork $vnet `
    -AddressPrefix $mngSubnetIpRange

Write-Host "Saving virtual network configuration ..."
$vnet | Set-AzVirtualNetwork