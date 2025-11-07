# Canada Central Production Environment Variables

variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "tenant_id" {
  description = "Azure AD tenant ID"
  type        = string
  default     = null
}

variable "deployment_stage" {
  description = "Deployment stage (stage1 or stage2)"
  type        = string
  default     = "stage1"
  
  validation {
    condition     = contains(["stage1", "stage2"], var.deployment_stage)
    error_message = "Deployment stage must be stage1 or stage2"
  }
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.28"
}

variable "aks_admin_group_object_ids" {
  description = "Azure AD group object IDs for AKS cluster admin access"
  type        = list(string)
  default     = []
}

variable "system_node_pool_vm_size" {
  description = "VM size for AKS system node pool"
  type        = string
  default     = "Standard_D4s_v5"
}

variable "user_node_pool_vm_size" {
  description = "VM size for AKS user node pool"
  type        = string
  default     = "Standard_F16s_v2"
}

variable "system_node_pool_min_count" {
  description = "Minimum nodes in system pool"
  type        = number
  default     = 1
}

variable "system_node_pool_max_count" {
  description = "Maximum nodes in system pool"
  type        = number
  default     = 5
}

variable "user_node_pool_min_count" {
  description = "Minimum nodes in user pool"
  type        = number
  default     = 1
}

variable "user_node_pool_max_count" {
  description = "Maximum nodes in user pool"
  type        = number
  default     = 5
}

variable "firewall_threat_intel_mode" {
  description = "Firewall threat intelligence mode"
  type        = string
  default     = "Alert"
}

variable "firewall_idps_mode" {
  description = "Firewall IDPS mode"
  type        = string
  default     = "Alert"
}

variable "istio_internal_lb_ip" {
  description = "Istio internal load balancer IP"
  type        = string
  default     = ""
}

variable "jumpbox_vm_size" {
  description = "Jumpbox VM size"
  type        = string
  default     = "Standard_B2s"
}

variable "jumpbox_admin_username" {
  description = "Jumpbox admin username"
  type        = string
  default     = "azureuser"
}

variable "jumpbox_ssh_public_key" {
  description = "SSH public key for jumpbox access"
  type        = string
}

variable "log_analytics_retention_days" {
  description = "Log Analytics retention days"
  type        = number
  default     = 30
}

variable "additional_tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}
