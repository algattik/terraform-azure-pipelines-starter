# Deploy a Resource Group with Azure resources.
#
# For suggested naming conventions, refer to:
#   https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/naming-and-tagging

# Sample Resource Group

resource "azurerm_resource_group" "main" {
  name     = "rg-${var.appname}-${var.environment}-main"
  location = var.location
}

# Sample Resource
# NB: You should organize your resources in Terraform modules.

resource "azurerm_sql_server" "example" {
  name                         = "algattik01sqlserver"
  resource_group_name          = ${azurerm_resource_group.main.name}
  location                     = ${azurerm_resource_group.main.location}
  version                      = "12.0"
  administrator_login          = "mradministrator"
  administrator_login_password = "thisIsDog11"
}

# Add additional resources / modules...

