# AKS Cluster Module with Istio Service Mesh
# Creates private AKS cluster with Azure CNI Overlay and Calico network policy

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
# AKS Cluster
# ========================================

resource "azurerm_kubernetes_cluster" "this" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix
  kubernetes_version  = var.kubernetes_version
  
  # Private Cluster Configuration
  private_cluster_enabled             = var.private_cluster_enabled
  private_dns_zone_id                 = var.private_dns_zone_id
  private_cluster_public_fqdn_enabled = false

  # Node Resource Group
  node_resource_group = var.node_resource_group_name

  # Default (System) Node Pool - defined in system-nodepool.tf
  default_node_pool {
    name                = var.system_node_pool_name
    vm_size             = var.system_node_pool_vm_size
    vnet_subnet_id      = var.system_node_pool_subnet_id
    enable_auto_scaling = var.system_node_pool_enable_autoscaling
    min_count           = var.system_node_pool_enable_autoscaling ? var.system_node_pool_min_count : null
    max_count           = var.system_node_pool_enable_autoscaling ? var.system_node_pool_max_count : null
    node_count          = var.system_node_pool_enable_autoscaling ? null : var.system_node_pool_count
    max_pods            = var.system_node_pool_max_pods
    os_disk_size_gb     = var.system_node_pool_os_disk_size_gb
    os_disk_type        = var.system_node_pool_os_disk_type
    zones               = var.system_node_pool_availability_zones
    
    upgrade_settings {
      max_surge = var.system_node_pool_max_surge
    }

    tags = merge(
      var.tags,
      {
        NodePoolType = "System"
      }
    )
  }

  # Identity (User-Assigned Managed Identity)
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aks.id]
  }

  # Network Profile - Azure CNI Overlay
  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    network_policy      = "calico"
    outbound_type       = var.outbound_type
    load_balancer_sku   = "standard"
    
    service_cidr   = var.service_cidr
    dns_service_ip = var.dns_service_ip
    
    # Pod CIDR for Overlay mode
    pod_cidr = var.pod_cidr
  }

  # Azure AD Integration with RBAC
  azure_active_directory_role_based_access_control {
    managed                = true
    azure_rbac_enabled     = var.azure_rbac_enabled
    tenant_id              = var.tenant_id
    admin_group_object_ids = var.admin_group_object_ids
  }

  # Istio Service Mesh Profile
  service_mesh_profile {
    mode                             = "Istio"
    internal_ingress_gateway_enabled = var.istio_internal_ingress_gateway_enabled
    external_ingress_gateway_enabled = var.istio_external_ingress_gateway_enabled
  }

  # Monitoring
  oms_agent {
    log_analytics_workspace_id = var.log_analytics_workspace_id
  }

  # Key Vault Secrets Provider
  key_vault_secrets_provider {
    secret_rotation_enabled  = var.key_vault_secrets_rotation_enabled
    secret_rotation_interval = var.key_vault_secrets_rotation_interval
  }

  # Maintenance Window (optional)
  dynamic "maintenance_window" {
    for_each = var.maintenance_window_enabled ? [1] : []
    content {
      allowed {
        day   = var.maintenance_window_day
        hours = var.maintenance_window_hours
      }
    }
  }

  # Auto-scaler Profile
  auto_scaler_profile {
    balance_similar_node_groups      = true
    expander                         = "random"
    max_graceful_termination_sec     = 600
    max_node_provisioning_time       = "15m"
    scale_down_delay_after_add       = "10m"
    scale_down_delay_after_delete    = "10s"
    scale_down_delay_after_failure   = "3m"
    scale_down_unneeded              = "10m"
    scale_down_unready               = "20m"
    scale_down_utilization_threshold = "0.5"
  }

  tags = merge(
    var.tags,
    {
      ClusterType = "Private"
      NetworkMode = "AzureCNIOverlay"
      ServiceMesh = "Istio"
    }
  )

  depends_on = [
    azurerm_role_assignment.aks_acr_pull,
    azurerm_role_assignment.aks_network_contributor
  ]
}
