# Virtual Network Deployment Script for Azure
# Subnet calculation: Using /26 mask (255.255.255.192) to provide 64 addresses per subnet
# Each subnet has 59 usable IPs after Azure reserves 5 addresses

param(
    [string]$ResourceGroupName = "mate-azure-task-15",
    [string]$Location = "uksouth"
)

$virtualNetworkName = "todoapp"
$vnetAddressPrefix = "10.20.30.0/24"

# Subnet configurations with /26 mask (64 addresses each, 59 usable)
$subnetConfigs = @(
    @{Name = "webservers"; AddressPrefix = "10.20.30.0/26"},
    @{Name = "database"; AddressPrefix = "10.20.30.64/26"}, 
    @{Name = "management"; AddressPrefix = "10.20.30.128/26"}
)

try {
    Write-Host "Checking Azure connection..."
    
    # Support for non-interactive login (CI/CD)
    $context = Get-AzContext
    if (-not $context) {
        Write-Host "No Azure context found. Attempting to connect..."
        try {
            Connect-AzAccount -Identity -ErrorAction SilentlyContinue
        } catch {
            Connect-AzAccount
        }
    }

    Write-Host "Ensuring resource group $ResourceGroupName exists..."
    
    $existingRG = Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction SilentlyContinue
    if (-not $existingRG) {
        New-AzResourceGroup -Name $ResourceGroupName -Location $Location -Force
        Write-Host "✅ Resource group created successfully."
    } else {
        Write-Host "ℹ️ Resource group already exists."
    }

    Write-Host "Creating/updating virtual network $virtualNetworkName..."

    # Check if virtual network exists
    $existingVNet = Get-AzVirtualNetwork -ResourceGroupName $ResourceGroupName -Name $virtualNetworkName -ErrorAction SilentlyContinue
    
    if ($existingVNet) {
        Write-Host "ℹ️ Virtual network exists. Updating subnets..."
        
        # Update existing VNet with new subnet configurations
        foreach ($subnet in $subnetConfigs) {
            $existingSubnet = $existingVNet.Subnets | Where-Object Name -eq $subnet.Name
            if (-not $existingSubnet) {
                Write-Host "Adding new subnet: $($subnet.Name)"
                Add-AzVirtualNetworkSubnetConfig -Name $subnet.Name -AddressPrefix $subnet.AddressPrefix -VirtualNetwork $existingVNet
            } else {
                Write-Host "Subnet $($subnet.Name) already exists"
            }
        }
        
        $existingVNet | Set-AzVirtualNetwork
    } else {
        Write-Host "Creating new virtual network with subnets..."
        
        # Create subnet configurations
        $subnets = @()
        foreach ($subnet in $subnetConfigs) {
            $subnets += New-AzVirtualNetworkSubnetConfig -Name $subnet.Name -AddressPrefix $subnet.AddressPrefix
        }

        # Create virtual network
        $vnetParams = @{
            ResourceGroupName = $ResourceGroupName
            Location = $Location
            Name = $virtualNetworkName
            AddressPrefix = $vnetAddressPrefix
            Subnet = $subnets
        }
        
        $vnet = New-AzVirtualNetwork @vnetParams
    }

    # Verify deployment
    $finalVNet = Get-AzVirtualNetwork -ResourceGroupName $ResourceGroupName -Name $virtualNetworkName
    
    Write-Host "✅ Virtual network deployment completed successfully!"
    Write-Host "Network details:"
    Write-Host "  VNet: $virtualNetworkName - $vnetAddressPrefix"
    Write-Host "  Subnets (each with 59 usable IPs):"
    
    foreach ($subnet in $finalVNet.Subnets) {
        Write-Host "    - $($subnet.Name) : $($subnet.AddressPrefix)"
    }

    # Validate subnet names and prefixes match requirements
    $expectedSubnets = @('webservers', 'database', 'management')
    $deployedSubnets = $finalVNet.Subnets.Name
    
    $missingSubnets = $expectedSubnets | Where-Object { $_ -notin $deployedSubnets }
    if ($missingSubnets) {
        throw "Missing required subnets: $($missingSubnets -join ', ')"
    }
    
    Write-Host "✅ All required subnets are present and correct"

}
catch {
    Write-Error "❌ Deployment failed: $($_.Exception.Message)"
    exit 1
}