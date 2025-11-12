resource "azurerm_role_assignment" "acr_pull" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.aks_cluster.kubelet_identity[0].object_id
}

resource "azurerm_role_assignment" "blob_contrib" {
  scope                = azurerm_storage_account.media_sa.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_kubernetes_cluster.aks_cluster.kubelet_identity[0].object_id
}

resource "azurerm_role_assignment" "queue_contrib" {
  scope                = azurerm_storage_account.media_sa.id
  role_definition_name = "Storage Queue Data Contributor"
  principal_id         = azurerm_kubernetes_cluster.aks_cluster.kubelet_identity[0].object_id
}
