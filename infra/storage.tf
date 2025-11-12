resource "azurerm_storage_account" "media_sa" {
  name                     = "bgmediastore${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"
  allow_blob_public_access = false
}

resource "azurerm_storage_container" "raw" {
  name                  = "rawfiles"
  storage_account_name  = azurerm_storage_account.media_sa.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "processed" {
  name                  = "processed"
  storage_account_name  = azurerm_storage_account.media_sa.name
  container_access_type = "private"
}

resource "azurerm_storage_queue" "jobqueue" {
  name                 = "jobqueue"
  storage_account_name = azurerm_storage_account.media_sa.name
}