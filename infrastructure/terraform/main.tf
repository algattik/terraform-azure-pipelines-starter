# Deploy a Resource Group with Azure resources.
#
# For suggested naming conventions, refer to:
#   https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/naming-and-tagging

#Set the terraform required version
terraform {
  required_version = ">= 0.12.6"
}

# Configure the Azure Provider
provider "azurerm" {
  # It is recommended to pin to a given version of the Provider
  version = "=1.38.0"
}

# Data

# Make client_id, tenant_id, subscription_id and object_id variables
data "azurerm_client_config" "current" {}

# Sample Resource Group

resource "azurerm_resource_group" "main" {
  name     = "rg-${var.appname}-${var.environment}-main"
  location = var.location
}

# Add additional resources / modules...

resource "azurerm_sql_server" "example" {
  name                         = "algattik01sqlserver"
  resource_group_name          = "${azurerm_resource_group.main.name}"
  location                     = "${azurerm_resource_group.main.location}"
  version                      = "12.0"
  administrator_login          = "mradministrator"
  administrator_login_password = "thisIsDog11"
}
