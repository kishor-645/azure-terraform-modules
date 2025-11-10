# Spoke VNet Module
# Creates spoke VNet with 3 subnets

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
# Subnets (3 Total)
# ========================================

# 1. Shared AKS Node Pool Subnet (for both system and user node pools)
resource "azurerm_subnet" "aks_nodes" {
  name                 = var.aks_node_pool_subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = [var.aks_node_pool_subnet_cidr]

  # Service endpoints for AKS
  service_endpoints = [
    "Microsoft.Storage",
    "Microsoft.Sql",
    "Microsoft.KeyVault",
    "Microsoft.ContainerRegistry"
  ]
}

# 2. Private Endpoints Subnet (for regional services)
resource "azurerm_subnet" "private_endpoints" {
  name                 = var.private_endpoints_subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = [var.private_endpoints_subnet_cidr]

  # Disable private endpoint network policies
  private_endpoint_network_policies = "Disabled"
}

# 3. Jumpbox/Agent VM Subnet
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