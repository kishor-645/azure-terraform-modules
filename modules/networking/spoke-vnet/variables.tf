# Spoke VNet Module Variables

# ========================================
# Required Variables
# ========================================

variable "vnet_name" {
  description = "Name of the spoke virtual network"
  type        = string
}

variable "location" {
  description = "Azure region for the spoke VNet"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group for the spoke VNet"
  type        = string
}

variable "address_space" {
  description = "Address space for the spoke VNet (e.g., 10.1.0.0/16)"
  type        = string

  validation {
    condition     = can(cidrhost(var.address_space, 0))
    error_message = "The address_space must be a valid CIDR block."
  }
}

# ========================================
# Subnet CIDR Variables
# ========================================

variable "aks_system_subnet_cidr" {
  description = "CIDR block for AKS system node pool subnet (recommend /20 for 4,091 IPs)"
  type        = string

  validation {
    condition     = can(cidrhost(var.aks_system_subnet_cidr, 0))
    error_message = "The aks_system_subnet_cidr must be a valid CIDR block."
  }
}

variable "aks_user_subnet_cidr" {
  description = "CIDR block for AKS user node pool subnet (recommend /22 for 1,019 IPs)"
  type        = string

  validation {
    condition     = can(cidrhost(var.aks_user_subnet_cidr, 0))
    error_message = "The aks_user_subnet_cidr must be a valid CIDR block."
  }
}

variable "private_endpoints_subnet_cidr" {
  description = "CIDR block for private endpoints subnet (recommend /24 for 251 IPs)"
  type        = string

  validation {
    condition     = can(cidrhost(var.private_endpoints_subnet_cidr, 0))
    error_message = "The private_endpoints_subnet_cidr must be a valid CIDR block."
  }
}

variable "jumpbox_subnet_cidr" {
  description = "CIDR block for jumpbox/agent VM subnet (recommend /27 for 32 IPs)"
  type        = string

  validation {
    condition     = can(cidrhost(var.jumpbox_subnet_cidr, 0))
    error_message = "The jumpbox_subnet_cidr must be a valid CIDR block."
  }
}

# ========================================
# Optional Variables
# ========================================

variable "aks_system_subnet_name" {
  description = "Name for the AKS system node pool subnet"
  type        = string
  default     = "AKSSystemNodeSubnet"
}

variable "aks_user_subnet_name" {
  description = "Name for the AKS user node pool subnet"
  type        = string
  default     = "AKSUserNodeSubnet"
}

variable "private_endpoints_subnet_name" {
  description = "Name for the private endpoints subnet"
  type        = string
  default     = "PrivateEndpointsSubnet"
}

variable "jumpbox_subnet_name" {
  description = "Name for the jumpbox subnet"
  type        = string
  default     = "JumpboxSubnet"
}

variable "tags" {
  description = "Tags to apply to all resources in this module"
  type        = map(string)
  default     = {}
}
