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
$virtualNetwork = New-AzVirtualNetwork `
    -ResourceGroupName $resourceGroupName `
    -Location $location `
    -Name $virtualNetworkName `
    -AddressPrefix $vnetAddressPrefix

# Create Subnets
Write-Host "Creating webservers subnet ..."
Add-AzVirtualNetworkSubnetConfig `
    -Name $webSubnetName `
    -VirtualNetwork $virtualNetwork `
    -AddressPrefix $webSubnetIpRange

Write-Host "Creating database subnet ..."
Add-AzVirtualNetworkSubnetConfig `
    -Name $dbSubnetName `
    -VirtualNetwork $virtualNetwork `
    -AddressPrefix $dbSubnetIpRange

Write-Host "Creating management subnet ..."
Add-AzVirtualNetworkSubnetConfig `
    -Name $mngSubnetName `
    -VirtualNetwork $virtualNetwork `
    -AddressPrefix $mngSubnetIpRange

# Deploy the virtual network with subnets
Write-Host "Deploying the virtual network with subnets..."
Set-AzVirtualNetwork -VirtualNetwork $virtualNetwork
