$location =                   "uksouth"
$resourceGroupName =          "mate-azure-task-15"

$virtualNetworkName =         "todoapp"
$vnetAddressPrefix =          "10.20.30.0/24"

$webSubnetName =              "webservers"
$webSubnetIpRange =           "10.20.30.0/26"

$dbSubnetName =               "database"
$dbSubnetIpRange =            "10.20.30.64/26"

$mngSubnetName =              "management"
$mngSubnetIpRange =           "10.20.30.128/26"

Write-Host "Creating a resource group $resourceGroupName ..."
New-AzResourceGroup `
  -Name                       $resourceGroupName `
  -Location                   $location

Write-Host "Creating a virtual network $virtualNetworkName ..."
$webSubnetConfig =  New-AzVirtualNetworkSubnetConfig `
  -Name                       $webSubnetName `
  -AddressPrefix              $webSubnetIpRange `

$dbSubnetConfig =   New-AzVirtualNetworkSubnetConfig `
  -Name                       $dbSubnetName `
  -AddressPrefix              $dbSubnetIpRange `

$mngSubnetConfig =  New-AzVirtualNetworkSubnetConfig `
  -Name                       $mngSubnetName `
  -AddressPrefix              $mngSubnetIpRange `

New-AzVirtualNetwork `
  -Name                       $virtualNetworkName `
  -ResourceGroupName          $resourceGroupName `
  -Location                   $location `
  -AddressPrefix              $vnetAddressPrefix `
  -Subnet                     $webSubnetConfig,`
                              $dbSubnetConfig,`
                              $mngSubnetConfig
