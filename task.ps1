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

Write-Host "Creating a resource group $resourceGroupName ..."
New-AzResourceGroup -Name $resourceGroupName -Location $location

Write-Host "Creating a virtual network ..."
# write your code here -> 
Write-Host "Creating a virtual network $virtualNetworkName with address space $vnetAddressPrefix ..."
$vnet = New-AzVirtualNetwork -ResourceGroupName $resourceGroupName -Location $location -Name $virtualNetworkName -AddressPrefix $vnetAddressPrefix

# Додавання підмереж окремо
$webSubnet = New-AzVirtualNetworkSubnetConfig -Name $webSubnetName -AddressPrefix $webSubnetIpRange
$dbSubnet = New-AzVirtualNetworkSubnetConfig -Name $dbSubnetName -AddressPrefix $dbSubnetIpRange
$mngSubnet = New-AzVirtualNetworkSubnetConfig -Name $mngSubnetName -AddressPrefix $mngSubnetIpRange

$vnet.Subnets.Add($webSubnet)
$vnet.Subnets.Add($dbSubnet)
$vnet.Subnets.Add($mngSubnet)

Write-Host "Applying the configuration..."
$vnet | Set-AzVirtualNetwork

Write-Host "Virtual network and subnets created successfully."
