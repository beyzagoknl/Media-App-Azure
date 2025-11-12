resource "kubernetes_namespace" "ns" {
  metadata {
    name = "media-pipeline"
  }
}

resource "kubernetes_secret" "storage_secret" {
  metadata {
    name      = "storage-account-secret"
    namespace = kubernetes_namespace.ns.metadata[0].name
  }

  data = {
    STORAGE_ACCOUNT_NAME            = base64encode(azurerm_storage_account.media_sa.name)
    STORAGE_ACCOUNT_KEY             = base64encode(azurerm_storage_account.media_sa.primary_access_key)
    AZURE_STORAGE_CONNECTION_STRING = base64encode(azurerm_storage_account.media_sa.primary_connection_string)
    RAW_CONTAINER                   = base64encode(azurerm_storage_container.raw.name)
    PROCESSED_CONTAINER             = base64encode(azurerm_storage_container.processed.name)
    QUEUE_NAME                      = base64encode(azurerm_storage_queue.jobqueue.name)
  }

  type = "Opaque"
}
