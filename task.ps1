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

# Create the virtual network with the address space
$virtualNetwork = New-AzVirtualNetwork -ResourceGroupName $resourceGroupName `
    -Location $location `
    -Name $virtualNetworkName `
    -AddressPrefix $vnetAddressPrefix

Write-Host "Adding the webservers subnet ..."
# Add the 'webservers' subnet
$virtualNetwork | Add-AzVirtualNetworkSubnetConfig -Name $webSubnetName `
    -AddressPrefix $webSubnetIpRange

Write-Host "Adding the database subnet ..."
# Add the 'database' subnet
$virtualNetwork | Add-AzVirtualNetworkSubnetConfig -Name $dbSubnetName `
    -AddressPrefix $dbSubnetIpRange

Write-Host "Adding the management subnet ..."
# Add the 'management' subnet
$virtualNetwork | Add-AzVirtualNetworkSubnetConfig -Name $mngSubnetName `
    -AddressPrefix $mngSubnetIpRange

Write-Host "Creating the virtual network and subnets ..."
# Apply the configuration to create the network and subnets
$virtualNetwork | Set-AzVirtualNetwork
