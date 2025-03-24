$location = "uksouth"
$resourceGroupName = "mate-azure-task-15"

$virtualNetworkName = "todoapp"
$vnetAddressPrefix = "10.20.30.0/24"
$webSubnetName = "webservers"
$webSubnetIpRange = "10.20.30.0/26" # <- calculate subnet ip address range
$dbSubnetName = "database"
$dbSubnetIpRange = "10.20.30.64/26" # <- calculate subnet ip address range
$mngSubnetName = "management"
$mngSubnetIpRange = "10.20.30.128/26" # <- calculate subnet ip address range

# Creat a resource group
Write-Host "Creating a resource group $resourceGroupName ..."
New-AzResourceGroup -Name $resourceGroupName -Location $location

# Creating a virtual network
Write-Host "Creating a virtual network $virtualNetworkName ..."
$vnet = New-AzVirtualNetwork `
  -ResourceGroupName $resourceGroupName `
  -Location $location `
  -Name $virtualNetworkName `
  -AddressPrefix $vnetAddressPrefix

# Create subnets
Write-Host "Creating subnets ..."
$webSubnet = Add-AzVirtualNetworkSubnetConfig `
  -Name $webSubnetName `
  -AddressPrefix $webSubnetIpRange `
  -VirtualNetwork $vnet

$dbSubnet = Add-AzVirtualNetworkSubnetConfig `
  -Name $dbSubnetName `
  -AddressPrefix $dbSubnetIpRange `
  -VirtualNetwork $vnet

$mngSubnet = Add-AzVirtualNetworkSubnetConfig `
  -Name $mngSubnetName `
  -AddressPrefix $mngSubnetIpRange `
  -VirtualNetwork $vnet

# Update the virtual network with subnets
Set-AzVirtualNetwork -VirtualNetwork $vnet

Write-Host "Virtual Network and subnets created successfully."
