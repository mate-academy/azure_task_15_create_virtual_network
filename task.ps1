# Define location and resource group
$location = "eastus"
$resourceGroupName = "mate-azure-task-15"

# Define virtual network and subnet details
$virtualNetworkName = "todoapp"
$vnetAddressPrefix = "10.20.30.0/24"

$webSubnetName = "webservers"
$webSubnetIpRange = "10.20.30.0/26"

$dbSubnetName = "database"
$dbSubnetIpRange = "10.20.30.64/26"

$mngSubnetName = "management"
$mngSubnetIpRange = "10.20.30.128/26"

# Create the Resource Group
Write-Host "Creating resource group: $resourceGroupName ..."
New-AzResourceGroup -Name $resourceGroupName -Location $location -Force

# Define subnets
Write-Host "Defining subnets..."
$webSubnet = New-AzVirtualNetworkSubnetConfig -Name $webSubnetName -AddressPrefix $webSubnetIpRange
$dbSubnet = New-AzVirtualNetworkSubnetConfig -Name $dbSubnetName -AddressPrefix $dbSubnetIpRange
$mngSubnet = New-AzVirtualNetworkSubnetConfig -Name $mngSubnetName -AddressPrefix $mngSubnetIpRange

# Create the Virtual Network with subnets
Write-Host "Creating virtual network: $virtualNetworkName ..."
New-AzVirtualNetwork -Name $virtualNetworkName `
    -ResourceGroupName $resourceGroupName `
    -Location $location `
    -AddressPrefix $vnetAddressPrefix `
    -Subnet $webSubnet, $dbSubnet, $mngSubnet

Write-Host "✅ Virtual Network and Subnets successfully created!"