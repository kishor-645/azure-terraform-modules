# VNet Peering Module
# Creates bidirectional hub-spoke VNet peering with gateway transit support

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
# Hub to Spoke Peering
# ========================================

resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  name                         = var.hub_to_spoke_peering_name
  resource_group_name          = var.hub_resource_group_name
  virtual_network_name         = var.hub_vnet_name
  remote_virtual_network_id    = var.spoke_vnet_id

  # Traffic settings
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true

  # Gateway transit (hub provides gateway)
  allow_gateway_transit        = var.enable_gateway_transit
  use_remote_gateways          = false
}

# ========================================
# Spoke to Hub Peering
# ========================================

resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  name                         = var.spoke_to_hub_peering_name
  resource_group_name          = var.spoke_resource_group_name
  virtual_network_name         = var.spoke_vnet_name
  remote_virtual_network_id    = var.hub_vnet_id

  # Traffic settings
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true

  # Gateway transit (spoke uses hub gateway)
  allow_gateway_transit        = false
  use_remote_gateways          = var.enable_gateway_transit && var.use_hub_gateway

  # Ensure hub peering is created first
  depends_on = [
    azurerm_virtual_network_peering.hub_to_spoke
  ]
}
