# User Node Pool for Application Workloads
# Separate node pool for running user workloads

resource "azurerm_kubernetes_cluster_node_pool" "user" {
  count = var.user_node_pool_enabled ? 1 : 0

  name                  = var.user_node_pool_name
  kubernetes_cluster_id = azurerm_kubernetes_cluster.this.id
  vm_size               = var.user_node_pool_vm_size
  vnet_subnet_id        = var.user_node_pool_subnet_id
  
  enable_auto_scaling   = var.user_node_pool_enable_autoscaling
  min_count             = var.user_node_pool_enable_autoscaling ? var.user_node_pool_min_count : null
  max_count             = var.user_node_pool_enable_autoscaling ? var.user_node_pool_max_count : null
  node_count            = var.user_node_pool_enable_autoscaling ? null : var.user_node_pool_count
  
  max_pods              = var.user_node_pool_max_pods
  os_disk_size_gb       = var.user_node_pool_os_disk_size_gb
  os_disk_type          = var.user_node_pool_os_disk_type
  zones                 = var.user_node_pool_availability_zones
  
  # Node Labels
  node_labels = merge(
    var.user_node_pool_labels,
    {
      "nodepool-type" = "user"
      "environment"   = var.environment
      "workload"      = "application"
    }
  )

  # Node Taints (optional - for workload isolation)
  node_taints = var.user_node_pool_taints

  upgrade_settings {
    max_surge = var.user_node_pool_max_surge
  }

  tags = merge(
    var.tags,
    {
      NodePoolType = "User"
      Purpose      = "ApplicationWorkloads"
    }
  )
}
