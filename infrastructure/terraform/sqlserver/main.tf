resource "random_password" "sql" {
  length = 16
  special = true
  override_special = "!@#$%&*()-_=+[]:?"
  min_upper = 1
  min_lower = 1
  min_numeric = 1
  min_special = 1
}

resource "azurerm_sql_server" "example" {
  name                         = "algattik01sqlserver"
  resource_group_name          = var.resource_group
  location                     = var.location
  version                      = "12.0"
  administrator_login          = "sa"
  administrator_login_password = random_password.sql.result
}
