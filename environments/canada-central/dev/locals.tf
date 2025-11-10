# Local Values and Data Sources

data "azurerm_client_config" "current" {}

data "azurerm_subscription" "current" {}

data "http" "cloudflare_ips_v4" {
  url = "https://www.cloudflare.com/ips-v4"
}

locals {
  environment = "dev"
  region      = "canadacentral"
  region_code = "cc"
  
  common_tags = {
    Environment  = "Development"
    Region         = "Canada Central"
    ManagedBy      = "Terraform"
    Project        = "ERP-Infrastructure"
    CostCenter     = "IT-Operations"
    DeployedDate   = timestamp()
  }
  
  naming_prefix = "erp-${local.region_code}-${local.environment}"
  
  # Single resource group for all resources
  rg_name = "rg-${local.naming_prefix}"
  
  hub_vnet_name          = "vnet-hub-${local.region}-${local.environment}"
  hub_vnet_address_space = "10.2.0.0/16"
  
  # Hub VNet Subnet CIDRs
  hub_firewall_subnet_cidr        = "10.2.1.0/26"   # Azure Firewall subnet
  hub_firewall_mgmt_subnet_cidr  = "10.2.2.0/26"   # Azure Firewall Management subnet
  hub_bastion_subnet_cidr         = "10.2.3.0/27"   # Azure Bastion subnet
  hub_shared_services_subnet_cidr = "10.2.4.0/24"   # Shared services subnet
  hub_private_endpoints_subnet_cidr = "10.2.5.0/24" # Private endpoints subnet (hub)
  hub_jumpbox_subnet_cidr         = "10.2.6.0/27"   # Jumpbox subnet (hub, if needed)
  
  spoke_vnet_name          = "vnet-spoke-${local.region}-${local.environment}"
  spoke_vnet_address_space = ["10.3.0.0/16"]
  
  # Spoke VNet Subnet CIDRs
  aks_node_pool_subnet_cidr = "10.3.0.0/20"      # Shared subnet for both system and user node pools
  private_endpoints_subnet_cidr = "10.3.16.0/24"  # Private endpoints subnet
  jumpbox_subnet_cidr = "10.3.17.0/27"            # Jumpbox/Agent VM subnet
  
  aks_cluster_name = "aks-${local.region}-${local.environment}"
  service_cidr     = "10.200.0.0/16"
  dns_service_ip   = "10.200.0.10"
  pod_cidr         = "10.245.0.0/16"
  
  deployment_stage = var.deployment_stage
  outbound_type    = var.deployment_stage == "stage1" ? "loadBalancer" : "userDefinedRouting"
  
  cloudflare_ipv4_list = split("\n", trimspace(data.http.cloudflare_ips_v4.response_body))
}

