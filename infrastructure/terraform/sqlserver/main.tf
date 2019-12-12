data "azurerm_key_vault_secret" "sql_password" {
  name = "${var.environment}-sql-password"
  key_vault_id = var.key_vault_id
}

resource "azurerm_sql_server" "example" {
  name                         = "algattik01sqlserver"
  resource_group_name          = var.resource_group
  location                     = var.location
  version                      = "12.0"
  administrator_login          = "mradministrator"
  administrator_login_password = data.azurerm_key_vault_secret.sql_password.value
}
