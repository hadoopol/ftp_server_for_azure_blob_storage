resource "azurerm_storage_account" "asc" {
  name                     = var.STORAGE_ACCOUNT_NAME
  resource_group_name      = var.RESOURCE_GROUP_NAME
  location                 = var.RESOURCE_GROUP_REGION
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
