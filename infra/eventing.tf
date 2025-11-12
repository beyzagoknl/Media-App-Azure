resource "azurerm_eventgrid_system_topic" "st" {
  name                  = "egst-bg-challenge"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  source_arm_resource_id = azurerm_storage_account.media_sa.id
  topic_type            = "Microsoft.Storage.StorageAccounts"
}

resource "azurerm_eventgrid_system_topic_event_subscription" "toqueue" {
  name                = "egsub-raw-to-queue"
  system_topic        = azurerm_eventgrid_system_topic.st.name
  resource_group_name = azurerm_resource_group.rg.name

  included_event_types = ["Microsoft.Storage.BlobCreated"]

  storage_queue_endpoint {
    storage_account_id = azurerm_storage_account.media_sa.id
    queue_name         = azurerm_storage_queue.jobqueue.name
  }

  subject_filter {
    subject_begins_with = "/blobServices/default/containers/${azurerm_storage_container.raw.name}/blobs/"
  }
}