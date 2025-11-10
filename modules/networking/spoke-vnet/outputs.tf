# Spoke VNet Module Outputs

# ========================================
# VNet Outputs
# ========================================

output "vnet_id" {
  description = "The ID of the spoke virtual network"
  value       = azurerm_virtual_network.spoke.id
}

output "vnet_name" {
  description = "The name of the spoke virtual network"
  value       = azurerm_virtual_network.spoke.name
}

output "vnet_address_space" {
  description = "The address space of the spoke virtual network"
  value       = azurerm_virtual_network.spoke.address_space
}

output "vnet_location" {
  description = "The location of the spoke virtual network"
  value       = azurerm_virtual_network.spoke.location
}

output "resource_group_name" {
  description = "The resource group name of the spoke virtual network"
  value       = azurerm_virtual_network.spoke.resource_group_name
}

# ========================================
# Subnet Outputs - IDs
# ========================================

output "aks_node_pool_subnet_id" {
  description = "The ID of the shared AKS node pool subnet (used by both system and user node pools)"
  value       = azurerm_subnet.aks_nodes.id
}

# Legacy outputs for backward compatibility (deprecated - use aks_node_pool_subnet_id)
output "aks_system_subnet_id" {
  description = "[DEPRECATED] Use aks_node_pool_subnet_id instead. The ID of the shared AKS node pool subnet"
  value       = azurerm_subnet.aks_nodes.id
}

output "aks_user_subnet_id" {
  description = "[DEPRECATED] Use aks_node_pool_subnet_id instead. The ID of the shared AKS node pool subnet"
  value       = azurerm_subnet.aks_nodes.id
}

output "private_endpoints_subnet_id" {
  description = "The ID of the private endpoints subnet"
  value       = azurerm_subnet.private_endpoints.id
}

output "jumpbox_subnet_id" {
  description = "The ID of the jumpbox subnet"
  value       = azurerm_subnet.jumpbox.id
}

# ========================================
# Subnet Outputs - Names
# ========================================

output "subnet_names" {
  description = "Map of subnet names"
  value = {
    aks_nodes        = azurerm_subnet.aks_nodes.name
    private_endpoints = azurerm_subnet.private_endpoints.name
    jumpbox           = azurerm_subnet.jumpbox.name
  }
}

# ========================================
# Subnet Outputs - Address Prefixes
# ========================================

output "subnet_address_prefixes" {
  description = "Map of subnet address prefixes"
  value = {
    aks_nodes        = azurerm_subnet.aks_nodes.address_prefixes[0]
    private_endpoints = azurerm_subnet.private_endpoints.address_prefixes[0]
    jumpbox           = azurerm_subnet.jumpbox.address_prefixes[0]
  }
}

# ========================================
# Consolidated Output
# ========================================

output "spoke_vnet_details" {
  description = "Consolidated details of the spoke VNet and all subnets"
  value = {
    vnet = {
      id            = azurerm_virtual_network.spoke.id
      name          = azurerm_virtual_network.spoke.name
      address_space = azurerm_virtual_network.spoke.address_space
      location      = azurerm_virtual_network.spoke.location
    }
    subnets = {
      aks_nodes = {
        id             = azurerm_subnet.aks_nodes.id
        name           = azurerm_subnet.aks_nodes.name
        address_prefix = azurerm_subnet.aks_nodes.address_prefixes[0]
      }
      private_endpoints = {
        id             = azurerm_subnet.private_endpoints.id
        name           = azurerm_subnet.private_endpoints.name
        address_prefix = azurerm_subnet.private_endpoints.address_prefixes[0]
      }
      jumpbox = {
        id             = azurerm_subnet.jumpbox.id
        name           = azurerm_subnet.jumpbox.name
        address_prefix = azurerm_subnet.jumpbox.address_prefixes[0]
      }
    }
  }
}
