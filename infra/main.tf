resource "azurerm_resource_group" "rg" {
  name     = "rg-media-pipeline"
  location = "westeurope"
  tags = {
    env     = "dev"
    project = "beyza-challenge"
  }
}

resource "random_string" "suffix" {
  length  = 4
  upper   = false
  special = false
}