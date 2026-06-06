$location = "polandcentral"
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




$subnetDBParams = @{
    Name = $dbSubnetName
    AddressPrefix = $dbSubnetIpRange
}

$subnetDbConfig = New-AzVirtualNetworkSubnetConfig @subnetDBParams

$subnetWebParams = @{
    Name = $webSubnetName
    AddressPrefix = $webSubnetIpRange
}

$subnetWebConfig = New-AzVirtualNetworkSubnetConfig @subnetWebParams

$subnetMngParams = @{
    Name = $mngSubnetName
    AddressPrefix = $mngSubnetIpRange
}

$subnetMngConfig = New-AzVirtualNetworkSubnetConfig @subnetMngParams

$vnetParams = @{
    Name = $virtualNetworkName
    ResourceGroupName = $resourceGroupName
    Location = $location
    AddressPrefix  = $vnetAddressPrefix
    Subnet = $subnetWebConfig, $subnetDbConfig, $subnetMngConfig
}

$virtualNetwork = New-AzVirtualNetwork @vnetParams