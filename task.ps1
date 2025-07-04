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

Write-Host "Creating a resource group $resourceGroupName ..."
# Check if resource group exists before creating to make script re-runnable
if (-not (Get-AzResourceGroup -Name $resourceGroupName -ErrorAction SilentlyContinue)) {
    New-AzResourceGroup -Name $resourceGroupName -Location $location
} else {
    Write-Host "Resource group '$resourceGroupName' already exists. Skipping creation."
}

Write-Host "Creating a virtual network ..."
# Check if virtual network exists before creating
$existingVNet = Get-AzVirtualNetwork -Name $virtualNetworkName -ResourceGroupName $resourceGroupName -ErrorAction SilentlyContinue
if (-not $existingVNet) {
    $virtualNetwork = New-AzVirtualNetwork `
        -ResourceGroupName $resourceGroupName `
        -Location $location `
        -Name $virtualNetworkName `
        -AddressPrefix $vnetAddressPrefix
} else {
    Write-Host "Virtual network '$virtualNetworkName' already exists. Retrieving existing configuration."
    $virtualNetwork = $existingVNet
}

# Add/Update subnets. This part needs to ensure subnets are configured correctly
# It's more robust to define subnet configs and then apply them to the VNet
$webSubnetConfig = New-AzVirtualNetworkSubnetConfig `
    -Name $webSubnetName `
    -AddressPrefix $webSubnetIpRange

$dbSubnetConfig = New-AzVirtualNetworkSubnetConfig `
    -Name $dbSubnetName `
    -AddressPrefix $dbSubnetIpRange

$mngSubnetConfig = New-AzVirtualNetworkSubnetConfig `
    -Name $mngSubnetName `
    -AddressPrefix $mngSubnetIpRange

# If VNet was newly created, apply subnets directly.
# If VNet existed, ensure subnets are added/updated.
# The original script's `Add-AzVirtualNetworkSubnetConfig` and then `Set-AzVirtualNetwork` works for initial creation
# but for idempotent updates, you might need more complex logic. For simplicity, we adapt to the initial create flow.

$virtualNetwork.Subnets.Clear() # Clear existing subnets to reconfigure cleanly if needed, be cautious in production
$virtualNetwork.Subnets.Add($webSubnetConfig)
$virtualNetwork.Subnets.Add($dbSubnetConfig)
$virtualNetwork.Subnets.Add($mngSubnetConfig)

$virtualNetwork | Set-AzVirtualNetwork | Out-Null

# Create result object with enhanced details for security and scalability
$result = @{
    VirtualNetwork = @{
        Name = $virtualNetworkName
        AddressSpace = $vnetAddressPrefix
        Subnets = @(
            @{
                Name = $webSubnetName
                AddressRange = $webSubnetIpRange
                Purpose = "Front-end web application servers"
                Security = @{
                    NSG_Rules = @(
                        "Дозволити вхідний HTTPS (порт 443) з Інтернету",
                        "Дозволити вхідний HTTP (порт 80) з Інтернету (якщо застосовно, для перенаправлення)",
                        "Дозволити вихідний трафік до App Subnet (конкретні порти)",
                        "Заборонити весь інший вхідний/вихідний трафік"
                    )
                }
                Scalability = "Використання балансувальника навантаження для розподілу трафіку між веб-серверами."
            },
            @{
                Name = $dbSubnetName
                AddressRange = $dbSubnetIpRange
                Purpose = "Database servers"
                Security = @{
                    NSG_Rules = @(
                        "Дозволити вхідний трафік з App Subnet (конкретний порт бази даних, наприклад, 1433 для SQL)",
                        "Дозволити вхідний трафік з Management Subnet (для адміністрування)",
                        "Заборонити весь інший вхідний трафік з Інтернету",
                        "Заборонити весь інший вхідний/вихідний трафік"
                    )
                    BestPractices = @(
                        "Використання приватних кінцевих точок (Private Endpoints) для PaaS баз даних"
                    )
                }
                Scalability = "Можливість налаштування реплікації бази даних та кластеризації."
            },
            @{
                Name = $mngSubnetName
                AddressRange = $mngSubnetIpRange
                Purpose = "Management jump-box / administrative tools"
                Security = @{
                    NSG_Rules = @(
                        "Дозволити вхідний трафік з певних адміністративних IP-адрес (наприклад, підмережі VPN/Bastion)",
                        "Дозволити вихідний трафік до Web/App/DB Subnets (для завдань управління)",
                        "Заборонити весь інший вхідний/вихідний трафік"
                    )
                    BestPractices = @(
                        "Впровадити доступ Just-in-Time (JIT) до віртуальних машин",
                        "Використовувати Azure Bastion для безпечного RDP/SSH доступу"
                    )
                }
                Scalability = "Можливість розгортання додаткових 'jump-box' віртуальних машин за необхідності."
            }
        )
        NetworkServices = @(
            @{
                Type = "Балансувальник навантаження (Load Balancer)"
                Purpose = "Розподіл трафіку на веб-сервери для високої доступності та масштабованості"
            },
            @{
                Type = "Шлюз додатків (Application Gateway) (опціонально)"
                Purpose = "Веб-фаєрвол (WAF), розвантаження SSL, маршрутизація на рівні 7"
            },
            @{
                Type = "Шлюз VPN / ExpressRoute (опціонально)"
                Purpose = "Безпечне підключення до локальних мереж"
            }
        )
        ScalabilityConsiderations = @(
            "Можливість розширення діапазонів адрес підмереж у разі потреби (потребує ретельного планування)",
            "Інтеграція з автомасштабуванням для масштабованих наборів віртуальних машин (VM Scale Sets)",
            "Моніторинг та журналювання для продуктивності мережі та подій безпеки"
        )
    }
}

# Save to JSON
$result | ConvertTo-Json -Depth 10 | Out-File -FilePath "result.json"

Write-Host "Virtual network '$virtualNetworkName' created with 3 subnets"
Write-Host "Results saved to result.json"
