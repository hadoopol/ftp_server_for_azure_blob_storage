resource "azurerm_storage_blob" "azb" {
  name                   = var.STORAGE_BLOB_NAME
  storage_account_name   = var.STORAGE_ACCOUNT_NAME
  storage_container_name = var.STORAGE_CONTAINER_NAME
  type                   = "Block"
}