output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "storage_account_name" {
  value = azurerm_storage_account.media_sa.name
}

output "acr_name" {
  value = azurerm_container_registry.acr.name
}

output "aks_name" {
  value = azurerm_kubernetes_cluster.aks_cluster.name
}

output "queue_name" {
  value = azurerm_storage_queue.jobqueue.name
}

output "raw_container" {
  value = azurerm_storage_container.raw.name
}

output "processed_container" {
  value = azurerm_storage_container.processed.name
}