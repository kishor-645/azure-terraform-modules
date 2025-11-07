# VNet Peering Module Outputs

# ========================================
# Hub to Spoke Peering Outputs
# ========================================

output "hub_to_spoke_peering_id" {
  description = "The ID of the hub-to-spoke peering connection"
  value       = azurerm_virtual_network_peering.hub_to_spoke.id
}

output "hub_to_spoke_peering_name" {
  description = "The name of the hub-to-spoke peering connection"
  value       = azurerm_virtual_network_peering.hub_to_spoke.name
}

output "hub_to_spoke_peering_state" {
  description = "The state of the hub-to-spoke peering connection"
  value       = azurerm_virtual_network_peering.hub_to_spoke.virtual_network_peering_state
}

# ========================================
# Spoke to Hub Peering Outputs
# ========================================

output "spoke_to_hub_peering_id" {
  description = "The ID of the spoke-to-hub peering connection"
  value       = azurerm_virtual_network_peering.spoke_to_hub.id
}

output "spoke_to_hub_peering_name" {
  description = "The name of the spoke-to-hub peering connection"
  value       = azurerm_virtual_network_peering.spoke_to_hub.name
}

output "spoke_to_hub_peering_state" {
  description = "The state of the spoke-to-hub peering connection"
  value       = azurerm_virtual_network_peering.spoke_to_hub.virtual_network_peering_state
}

# ========================================
# Consolidated Output
# ========================================

output "peering_details" {
  description = "Consolidated details of both peering connections"
  value = {
    hub_to_spoke = {
      id                  = azurerm_virtual_network_peering.hub_to_spoke.id
      name                = azurerm_virtual_network_peering.hub_to_spoke.name
      state               = azurerm_virtual_network_peering.hub_to_spoke.virtual_network_peering_state
      allow_gateway_transit = azurerm_virtual_network_peering.hub_to_spoke.allow_gateway_transit
    }
    spoke_to_hub = {
      id                  = azurerm_virtual_network_peering.spoke_to_hub.id
      name                = azurerm_virtual_network_peering.spoke_to_hub.name
      state               = azurerm_virtual_network_peering.spoke_to_hub.virtual_network_peering_state
      use_remote_gateways = azurerm_virtual_network_peering.spoke_to_hub.use_remote_gateways
    }
  }
}

output "peering_status" {
  description = "Status message indicating whether peering is successful"
  value       = azurerm_virtual_network_peering.hub_to_spoke.virtual_network_peering_state == "Connected" && azurerm_virtual_network_peering.spoke_to_hub.virtual_network_peering_state == "Connected" ? "Peering established successfully" : "Peering in progress or failed"
}
