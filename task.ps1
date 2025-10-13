# Virtual Network Deployment Script for Azure
# Subnet calculation: Using /26 mask (255.255.255.192) to provide 64 addresses per subnet
# Each subnet has 59 usable IPs after Azure reserves 5 addresses (network, gateway, DNS, etc.)

$location = "uksouth"
$resourceGroupName = "mate-azure-task-15"
$virtualNetworkName = "todoapp"
$vnetAddressPrefix = "10.20.30.0/24"

# Subnet configurations with /26 mask (64 addresses each, 59 usable)
$webSubnetName = "webservers"
$webSubnetIpRange = "10.20.30.0/26"    # 10.20.30.1 - 10.20.30.62 (59 usable IPs)
$dbSubnetName = "database"
$dbSubnetIpRange = "10.20.30.64/26"    # 10.20.30.65 - 10.20.30.126 (59 usable IPs)
$mngSubnetName = "management"
$mngSubnetIpRange = "10.20.30.128/26"  # 10.20.30.129 - 10.20.30.190 (59 usable IPs)

try {
    Write-Host "Checking Azure connection..."
    $context = Get-AzContext
    if (-not $context) {
        Write-Host "Please login to Azure..."
        Connect-AzAccount
    }

    Write-Host "Creating resource group $resourceGroupName ..."
    
    # Check if resource group already exists
    $existingRG = Get-AzResourceGroup -Name $resourceGroupName -ErrorAction SilentlyContinue
    if (-not $existingRG) {
        New-AzResourceGroup -Name $resourceGroupName -Location $location -Force
        Write-Host "Resource group created successfully."
    } else {
        Write-Host "Resource group already exists."
    }

    Write-Host "Creating virtual network $virtualNetworkName with subnets..."

    # Check if virtual network already exists
    $existingVNet = Get-AzVirtualNetwork -ResourceGroupName $resourceGroupName -Name $virtualNetworkName -ErrorAction SilentlyContinue
    if ($existingVNet) {
        Write-Host "Virtual network already exists. Removing existing network..."
        Remove-AzVirtualNetwork -ResourceGroupName $resourceGroupName -Name $virtualNetworkName -Force
    }

    # Create subnet configurations
    $webSubnet = New-AzVirtualNetworkSubnetConfig -Name $webSubnetName -AddressPrefix $webSubnetIpRange
    $dbSubnet = New-AzVirtualNetworkSubnetConfig -Name $dbSubnetName -AddressPrefix $dbSubnetIpRange
    $mngSubnet = New-AzVirtualNetworkSubnetConfig -Name $mngSubnetName -AddressPrefix $mngSubnetIpRange

    # Create virtual network with all subnets
    $vnet = New-AzVirtualNetwork `
        -ResourceGroupName $resourceGroupName `
        -Location $location `
        -Name $virtualNetworkName `
        -AddressPrefix $vnetAddressPrefix `
        -Subnet $webSubnet, $dbSubnet, $mngSubnet

    Write-Host "Virtual network creation completed successfully!"
    Write-Host "Network details:"
    Write-Host "  VNet: $virtualNetworkName - $vnetAddressPrefix"
    Write-Host "  Subnets (each with 59 usable IPs):"
    Write-Host "    - $webSubnetName : $webSubnetIpRange"
    Write-Host "    - $dbSubnetName : $dbSubnetIpRange"
    Write-Host "    - $mngSubnetName : $mngSubnetIpRange"
    
    # Verify creation
    $createdVNet = Get-AzVirtualNetwork -ResourceGroupName $resourceGroupName -Name $virtualNetworkName
    Write-Host "Verification: Virtual network created with $($createdVNet.Subnets.Count) subnets"

}
catch {
    Write-Error "An error occurred: $($_.Exception.Message)"
    exit 1
}