terraform {
  backend "azurerm" {
    key = "xlabs.tfstate"
  }
}
resource "azurerm_resource_group" "xlabs" {
  name     = "xlab-platform"
  location = "uksouth"
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "xlabs-aks"
  location            = azurerm_resource_group.xlabs.location
  resource_group_name = azurerm_resource_group.xlabs.name
  dns_prefix          = "xlabs"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "dev"
  }
}

data "azurerm_container_registry" "acr" {
    name = "makeitrepeatable"
    resource_group_name = "makeitrepeatable-acr"
}

resource "azurerm_role_assignment" "attach_acr" {
  scope                = data.azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id

}

output "client_certificate" {
  value = azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.aks.kube_config_raw

  sensitive = true
}