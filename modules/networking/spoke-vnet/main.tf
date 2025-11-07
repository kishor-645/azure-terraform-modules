# Spoke VNet Module
# Creates spoke VNet with 4 subnets for AKS workloads

terraform {
  required_version = ">= 1.10.3"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.51.0"
    }
  }
}

# ========================================
# Spoke Virtual Network
# ========================================

resource "azurerm_virtual_network" "spoke" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = [var.address_space]

  tags = merge(
    var.tags,
    {
      VNetType = "Spoke"
      Purpose  = "AKS Workloads"
    }
  )
}

# ========================================
# Subnets
# ========================================

# 1. AKS System Node Pool Subnet
resource "azurerm_subnet" "aks_system" {
  name                 = var.aks_system_subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = [var.aks_system_subnet_cidr]

  # Service endpoints for AKS
  service_endpoints = [
    "Microsoft.Storage",
    "Microsoft.Sql",
    "Microsoft.KeyVault",
    "Microsoft.ContainerRegistry"
  ]
}

# 2. AKS User Node Pool Subnet
resource "azurerm_subnet" "aks_user" {
  name                 = var.aks_user_subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = [var.aks_user_subnet_cidr]

  # Service endpoints for AKS
  service_endpoints = [
    "Microsoft.Storage",
    "Microsoft.Sql",
    "Microsoft.KeyVault",
    "Microsoft.ContainerRegistry"
  ]
}

# 3. Private Endpoints Subnet (for regional services)
resource "azurerm_subnet" "private_endpoints" {
  name                 = var.private_endpoints_subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = [var.private_endpoints_subnet_cidr]

  # Disable private endpoint network policies
  private_endpoint_network_policies = "Disabled"
}

# 4. Jumpbox/Agent VM Subnet
resource "azurerm_subnet" "jumpbox" {
  name                 = var.jumpbox_subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = [var.jumpbox_subnet_cidr]

  service_endpoints = [
    "Microsoft.Storage",
    "Microsoft.KeyVault"
  ]
}
