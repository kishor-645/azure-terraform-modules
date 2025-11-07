# Local Values and Data Sources

data "azurerm_client_config" "current" {}

data "azurerm_subscription" "current" {}

data "http" "cloudflare_ips_v4" {
  url = "https://www.cloudflare.com/ips-v4"
}

locals {
  environment = "prod"
  region      = "canadacentral"
  region_code = "cc"
  
  common_tags = {
    Environment  = "Production"
    Region       = "Canada Central"
    ManagedBy    = "Terraform"
    Project      = "ERP-Infrastructure"
    CostCenter   = "IT-Operations"
    DeployedDate = timestamp()
  }
  
  naming_prefix = "erp-${local.region_code}-${local.environment}"
  
  rg_hub_name       = "rg-hub-${local.region}-${local.environment}"
  rg_spoke_name     = "rg-spoke-${local.region}-${local.environment}"
  rg_aks_nodes_name = "rg-aks-nodes-${local.region}-${local.environment}"
  rg_global_name    = "rg-global-shared-${local.environment}"
  
  hub_vnet_name          = "vnet-hub-${local.region}-${local.environment}"
  hub_vnet_address_space = ["10.0.0.0/16"]
  
  spoke_vnet_name          = "vnet-spoke-${local.region}-${local.environment}"
  spoke_vnet_address_space = ["10.1.0.0/16"]
  
  aks_cluster_name = "aks-${local.region}-${local.environment}"
  service_cidr     = "10.100.0.0/16"
  dns_service_ip   = "10.100.0.10"
  pod_cidr         = "10.244.0.0/16"
  
  deployment_stage = var.deployment_stage
  outbound_type    = var.deployment_stage == "stage1" ? "loadBalancer" : "userDefinedRouting"
  
  cloudflare_ipv4_list = split("\n", trimspace(data.http.cloudflare_ips_v4.response_body))
}
