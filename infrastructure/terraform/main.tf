# Deploy a Resource Group with Azure resources.
#
# For suggested naming conventions, refer to:
#   https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/naming-and-tagging

# Sample Resource Group

resource "azurerm_resource_group" "main" {
  name     = "rg-${var.appname}-${var.environment}-main"
  location = var.location
  tags     = {
    department = var.department
  }
}

data "azurerm_key_vault" "keyvault" {
  name = var.keyvault_name
  resource_group_name = var.keyvault_rg
}
 
# Sample Resources

module "sqlserver" {
  source = "./sqlserver"
  environment = var.environment
  resource_group = azurerm_resource_group.main.name
  location = azurerm_resource_group.main.location
  key_vault_id = data.azurerm_key_vault.keyvault.id
}

# Add additional modules...
