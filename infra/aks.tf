resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = "aks-bg-challenge"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "bgchallengeaks"

  default_node_pool {
    name       = "nodepool1"
    node_count = 1
    vm_size    = "Standard_DS2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    project = "beyza-challenge"
  }
}