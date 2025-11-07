# Azure Container Registry Module
# Creates Premium ACR with private endpoint and geo-replication

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
# Container Registry
# ========================================

resource "azurerm_container_registry" "this" {
  name                = var.registry_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku
  admin_enabled       = var.admin_enabled
  
  # Public network access
  public_network_access_enabled = var.public_network_access_enabled
  
  # Network Rule Set
  dynamic "network_rule_set" {
    for_each = var.sku == "Premium" ? [1] : []
    content {
      default_action = var.default_network_action
      
      dynamic "ip_rule" {
        for_each = var.allowed_ip_ranges
        content {
          action   = "Allow"
          ip_range = ip_rule.value
        }
      }

      dynamic "virtual_network" {
        for_each = var.allowed_subnet_ids
        content {
          action    = "Allow"
          subnet_id = virtual_network.value
        }
      }
    }
  }

  # Geo-replication (Premium only)
  dynamic "georeplications" {
    for_each = var.sku == "Premium" ? var.georeplications : []
    content {
      location                  = georeplications.value.location
      zone_redundancy_enabled   = georeplications.value.zone_redundancy_enabled
      regional_endpoint_enabled = georeplications.value.regional_endpoint_enabled
      tags                      = georeplications.value.tags
    }
  }

  # Retention Policy
  dynamic "retention_policy" {
    for_each = var.sku == "Premium" && var.retention_policy_enabled ? [1] : []
    content {
      days    = var.retention_policy_days
      enabled = true
    }
  }

  # Trust Policy
  dynamic "trust_policy" {
    for_each = var.sku == "Premium" && var.trust_policy_enabled ? [1] : []
    content {
      enabled = true
    }
  }

  # Identity (for customer-managed encryption)
  dynamic "identity" {
    for_each = var.encryption_identity_id != null ? [1] : []
    content {
      type         = "UserAssigned"
      identity_ids = [var.encryption_identity_id]
    }
  }

  # Customer-Managed Encryption
  dynamic "encryption" {
    for_each = var.encryption_key_vault_key_id != null ? [1] : []
    content {
      enabled            = true
      key_vault_key_id   = var.encryption_key_vault_key_id
      identity_client_id = var.encryption_identity_client_id
    }
  }

  tags = merge(
    var.tags,
    {
      Purpose = "ContainerRegistry"
    }
  )
}

# ========================================
# Private Endpoint
# ========================================

resource "azurerm_private_endpoint" "this" {
  count = var.enable_private_endpoint ? 1 : 0

  name                = "${var.registry_name}-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "${var.registry_name}-psc"
    private_connection_resource_id = azurerm_container_registry.this.id
    subresource_names              = ["registry"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "acr-dns-zone-group"
    private_dns_zone_ids = var.private_dns_zone_ids
  }

  tags = var.tags
}

# ========================================
# Diagnostic Settings
# ========================================

resource "azurerm_monitor_diagnostic_setting" "acr" {
  count = var.log_analytics_workspace_id != null ? 1 : 0

  name                       = "diag-${var.registry_name}"
  target_resource_id         = azurerm_container_registry.this.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "ContainerRegistryRepositoryEvents"
  }

  enabled_log {
    category = "ContainerRegistryLoginEvents"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
