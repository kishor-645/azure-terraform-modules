# Backend Configuration for Canada Central Development
# Remote state storage in Azure Storage Account

terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state-canadacentral"
    storage_account_name = "sttfstateccdev"
    container_name       = "tfstate"
    key                  = "canada-central/dev/terraform.tfstate"
  }
}

