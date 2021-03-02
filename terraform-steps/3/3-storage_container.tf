resource "azurerm_storage_container" "asc" {
  name                  = var.STORAGE_CONTAINER_NAME
  storage_account_name  = var.STORAGE_ACCOUNT_NAME
  container_access_type = "private"
}

