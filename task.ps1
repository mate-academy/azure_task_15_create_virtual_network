$location = "uksouth"
$resourceGroupName = "mate-azure-task-15"

$virtualNetworkName = "todoapp"
$vnetAddressPrefix = "10.20.30.0/24"

$webSubnetName = "webservers"
$webSubnetIpRange = "10.20.30.0/26"

$dbSubnetName = "database"
$dbSubnetIpRange = "10.20.30.64/26"

$mngSubnetName = "management"
$mngSubnetIpRange = "10.20.30.128/26"

# Create Resource Group
Write-Host "Creating a resource group $resourceGroupName ..."
New-AzResourceGroup -Name $resourceGroupName -Location $location

# Create Virtual Network
Write-Host "Creating a virtual network $virtualNetworkName ..."
$vnet = New-AzVirtualNetwork -Name $virtualNetworkName `
                             -ResourceGroupName $resourceGroupName `
                             -Location $location `
                             -AddressPrefix $vnetAddressPrefix

# Add subnets
Write-Host "Adding subnets ..."
$vnet = Add-AzVirtualNetworkSubnetConfig -Name $webSubnetName -AddressPrefix $webSubnetIpRange -VirtualNetwork $vnet
$vnet = Add-AzVirtualNetworkSubnetConfig -Name $dbSubnetName -AddressPrefix $dbSubnetIpRange -VirtualNetwork $vnet
$vnet = Add-AzVirtualNetworkSubnetConfig -Name $mngSubnetName -AddressPrefix $mngSubnetIpRange -VirtualNetwork $vnet

# Apply changes
$vnet | Set-AzVirtualNetwork

Write-Host "Virtual Network '$virtualNetworkName' with subnets created successfully."
