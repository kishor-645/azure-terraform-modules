# Canada Central Production Environment - Main Configuration

resource "azurerm_resource_group" "hub" {
  name     = local.rg_hub_name
  location = local.region
  tags     = local.common_tags
}

resource "azurerm_resource_group" "spoke" {
  name     = local.rg_spoke_name
  location = local.region
  tags     = local.common_tags
}

resource "azurerm_resource_group" "aks_nodes" {
  name     = local.rg_aks_nodes_name
  location = local.region
  tags     = local.common_tags
}

resource "azurerm_resource_group" "global" {
  name     = local.rg_global_name
  location = local.region
  tags     = local.common_tags
}

module "log_analytics" {
  source = "../../../modules/monitoring/log-analytics"
  
  workspace_name      = "log-${local.naming_prefix}"
  location            = local.region
  resource_group_name = azurerm_resource_group.global.name
  retention_in_days   = var.log_analytics_retention_days
  
  tags = local.common_tags
}

module "hub_vnet" {
  source = "../../../modules/networking/hub-vnet"
  
  vnet_name           = local.hub_vnet_name
  location            = local.region
  resource_group_name = azurerm_resource_group.hub.name
  address_space       = local.hub_vnet_address_space
  
  tags = local.common_tags
}

module "spoke_vnet" {
  source = "../../../modules/networking/spoke-vnet"
  
  vnet_name           = local.spoke_vnet_name
  location            = local.region
  resource_group_name = azurerm_resource_group.spoke.name
  address_space       = local.spoke_vnet_address_space
  
  tags = local.common_tags
}

module "vnet_peering" {
  source = "../../../modules/networking/vnet-peering"
  
  hub_vnet_name           = module.hub_vnet.vnet_name
  hub_vnet_id             = module.hub_vnet.vnet_id
  hub_resource_group_name = azurerm_resource_group.hub.name
  
  spoke_vnet_name           = module.spoke_vnet.vnet_name
  spoke_vnet_id             = module.spoke_vnet.vnet_id
  spoke_resource_group_name = azurerm_resource_group.spoke.name
  
  allow_forwarded_traffic = true
  use_remote_gateways     = false
}

module "azure_firewall" {
  source = "../../../modules/security/azure-firewall"
  
  firewall_name               = "azfw-${local.region}-${local.environment}"
  location                    = local.region
  resource_group_name         = azurerm_resource_group.hub.name
  firewall_policy_name        = "azfwpol-${local.region}-${local.environment}"
  firewall_public_ip_name     = "pip-azfw-${local.region}-${local.environment}"
  firewall_management_ip_name = "pip-azfw-mgmt-${local.region}-${local.environment}"
  
  firewall_subnet_id            = module.hub_vnet.firewall_subnet_id
  firewall_management_subnet_id = module.hub_vnet.firewall_management_subnet_id
  
  availability_zones = ["1", "2", "3"]
  
  internal_lb_ip                   = var.istio_internal_lb_ip
  fetch_cloudflare_ips_dynamically = true
  
  threat_intelligence_mode = var.firewall_threat_intel_mode
  idps_mode                = var.firewall_idps_mode
  
  hub_vnet_cidr   = local.hub_vnet_address_space[0]
  spoke_vnet_cidr = local.spoke_vnet_address_space[0]
  
  log_analytics_workspace_id = module.log_analytics.workspace_id
  
  tags = local.common_tags
}

module "route_table_aks" {
  source = "../../../modules/security/route-table"
  
  count = local.deployment_stage == "stage2" ? 1 : 0
  
  route_table_name              = "rt-aks-${local.region}-${local.environment}"
  location                      = local.region
  resource_group_name           = azurerm_resource_group.spoke.name
  disable_bgp_route_propagation = true
  
  routes = [
    {
      name                   = "default-via-firewall"
      address_prefix         = "0.0.0.0/0"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = module.azure_firewall.firewall_private_ip
    }
  ]
  
  subnet_ids = [
    module.spoke_vnet.aks_system_subnet_id,
    module.spoke_vnet.aks_user_subnet_id
  ]
  
  tags = local.common_tags
}

module "azure_bastion" {
  source = "../../../modules/security/bastion"
  
  bastion_name            = "bastion-${local.region}-${local.environment}"
  location                = local.region
  resource_group_name     = azurerm_resource_group.hub.name
  bastion_subnet_id       = module.hub_vnet.bastion_subnet_id
  bastion_public_ip_name  = "pip-bastion-${local.region}-${local.environment}"
  
  bastion_sku            = "Standard"
  copy_paste_enabled     = true
  file_copy_enabled      = true
  ip_connect_enabled     = true
  tunneling_enabled      = true
  shareable_link_enabled = false
  scale_units            = 2
  
  log_analytics_workspace_id = module.log_analytics.workspace_id
  
  tags = local.common_tags
}

module "aks_cluster" {
  source = "../../../modules/compute/aks-cluster"
  
  cluster_name             = local.aks_cluster_name
  location                 = local.region
  resource_group_name      = azurerm_resource_group.spoke.name
  dns_prefix               = "${local.aks_cluster_name}-dns"
  node_resource_group_name = azurerm_resource_group.aks_nodes.name
  kubernetes_version       = var.kubernetes_version
  
  vnet_id                    = module.spoke_vnet.vnet_id
  system_node_pool_subnet_id = module.spoke_vnet.aks_system_subnet_id
  user_node_pool_subnet_id   = module.spoke_vnet.aks_user_subnet_id
  
  outbound_type  = local.outbound_type
  service_cidr   = local.service_cidr
  dns_service_ip = local.dns_service_ip
  pod_cidr       = local.pod_cidr
  
  system_node_pool_vm_size   = var.system_node_pool_vm_size
  system_node_pool_min_count = var.system_node_pool_min_count
  system_node_pool_max_count = var.system_node_pool_max_count
  
  user_node_pool_enabled   = true
  user_node_pool_vm_size   = var.user_node_pool_vm_size
  user_node_pool_min_count = var.user_node_pool_min_count
  user_node_pool_max_count = var.user_node_pool_max_count
  
  aks_identity_name = "id-aks-${local.region}-${local.environment}"
  
  azure_rbac_enabled     = true
  tenant_id              = var.tenant_id
  admin_group_object_ids = var.aks_admin_group_object_ids
  
  istio_internal_ingress_gateway_enabled = true
  istio_external_ingress_gateway_enabled = false
  
  log_analytics_workspace_id = module.log_analytics.workspace_id
  
  tags = local.common_tags
  
  depends_on = [
    module.vnet_peering,
    module.azure_firewall
  ]
}
