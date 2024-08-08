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

Write-Host "Adding subnet $webSubnetName with address range $webSubnetIpRange ..."
Add-AzVirtualNetworkSubnetConfig -Name $webSubnetName -AddressPrefix $webSubnetIpRange -VirtualNetwork $vnet

Write-Host "Adding subnet $dbSubnetName with address range $dbSubnetIpRange ..."
Add-AzVirtualNetworkSubnetConfig -Name $dbSubnetName -AddressPrefix $dbSubnetIpRange -VirtualNetwork $vnet

Write-Host "Adding subnet $mngSubnetName with address range $mngSubnetIpRange ..."
Add-AzVirtualNetworkSubnetConfig -Name $mngSubnetName -AddressPrefix $mngSubnetIpRange -VirtualNetwork $vnet

Write-Host "Applying the configuration..."
$vnet | Set-AzVirtualNetwork

Write-Host "Virtual network and subnets created successfully."
