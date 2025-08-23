Param(
  [string]$Location = "westeurope",
  [string]$ProjectRg = "mate-azure-task-15",
  [string]$VNetName = "todoapp",
  [string]$AddressSpace = "10.20.30.0/24"
)

# Гарантуємо, що є логін і контекст
try { Get-AzContext | Out-Null } catch { Connect-AzAccount | Out-Null }

# 1) RG для завдання
if (-not (Get-AzResourceGroup -Name $ProjectRg -ErrorAction SilentlyContinue)) {
  New-AzResourceGroup -Name $ProjectRg -Location $Location | Out-Null
}

# 2) Три сабнети по /26 (по ~59 usable IP кожен)
$snWeb  = New-AzVirtualNetworkSubnetConfig -Name "webservers" -AddressPrefix "10.20.30.0/26"
$snDb   = New-AzVirtualNetworkSubnetConfig -Name "database"   -AddressPrefix "10.20.30.64/26"
$snMgmt = New-AzVirtualNetworkSubnetConfig -Name "management" -AddressPrefix "10.20.30.128/26"

# 3) Створити/оновити VNet todoapp
$vnet = Get-AzVirtualNetwork -Name $VNetName -ResourceGroupName $ProjectRg -ErrorAction SilentlyContinue
if ($null -eq $vnet) {
  $vnet = New-AzVirtualNetwork `
    -Name $VNetName `
    -ResourceGroupName $ProjectRg `
    -Location $Location `
    -AddressPrefix $AddressSpace `
    -Subnet $snWeb,$snDb,$snMgmt
} else {
  # гарантуємо address space та сабнети
  if ($vnet.AddressSpace.AddressPrefixes -notcontains $AddressSpace) {
    $vnet.AddressSpace.AddressPrefixes.Clear()
    [void]$vnet.AddressSpace.AddressPrefixes.Add($AddressSpace)
  }

  function Ensure-Subnet([Microsoft.Azure.Commands.Network.Models.PSVirtualNetwork]$vn, [string]$name, [string]$prefix) {
    $existing = $vn.Subnets | Where-Object { $_.Name -eq $name }
    if ($null -eq $existing) {
      $vn = Add-AzVirtualNetworkSubnetConfig -VirtualNetwork $vn -Name $name -AddressPrefix $prefix
    } else {
      $existing.AddressPrefix = $prefix
    }
    return $vn
  }

  $vnet = Ensure-Subnet $vnet "webservers" "10.20.30.0/26"
  $vnet = Ensure-Subnet $vnet "database"   "10.20.30.64/26"
  $vnet = Ensure-Subnet $vnet "management" "10.20.30.128/26"
  $vnet = Set-AzVirtualNetwork -VirtualNetwork $vnet
}

# 4) Короткий результат для рев’ю/валідації
$result = [ordered]@{
  resourceGroup = $ProjectRg
  location      = $Location
  vnetName      = $VNetName
  addressSpace  = $AddressSpace
  subnets       = @(
    @{ name="webservers"; prefix="10.20.30.0/26";   usableIPs=59 },
    @{ name="database";   prefix="10.20.30.64/26";  usableIPs=59 },
    @{ name="management"; prefix="10.20.30.128/26"; usableIPs=59 }
  )
}
$result | ConvertTo-Json -Depth 5 | Set-Content -Path ".\result.json" -Encoding utf8

Write-Host "✅ VNet '$VNetName' у RG '$ProjectRg' створено/оновлено у $Location."
