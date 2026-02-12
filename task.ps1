$location = "francecentral"
$resourceGroupName = "mate-azure-task-15"
$virtualNetworkName = "todoapp"
$vnetAddressPrefix = "10.20.30.0/24"
$webSubnetName = "webservers"
$webSubnetIpRange = "10.20.30.0/26"
$dbSubnetName = "database"
$dbSubnetIpRange = "10.20.30.64/26"
$mngSubnetName = "management"
$mngSubnetIpRange = "10.20.30.128/26"

Write-Host "Creating resource group..."
New-AzResourceGroup -Name $resourceGroupName -Location $location

Write-Host "Creating virtual network..."
$vnet = New-AzVirtualNetwork `
    -Name $virtualNetworkName `
    -ResourceGroupName $resourceGroupName `
    -AddressPrefix $vnetAddressPrefix `
    -Location $location

Write-Host "Adding subnets..."

$vnet = Add-AzVirtualNetworkSubnetConfig `
    -Name $webSubnetName `
    -AddressPrefix $webSubnetIpRange `
    -VirtualNetwork $vnet

$vnet = Add-AzVirtualNetworkSubnetConfig `
    -Name $dbSubnetName `
    -AddressPrefix $dbSubnetIpRange `
    -VirtualNetwork $vnet

$vnet = Add-AzVirtualNetworkSubnetConfig `
    -Name $mngSubnetName `
    -AddressPrefix $mngSubnetIpRange `
    -VirtualNetwork $vnet

Set-AzVirtualNetwork -VirtualNetwork $vnet
