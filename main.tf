

terraform {
  backend "azurerm" {
    key = "terraform.tfstate"
  }
}

locals {
  subnets = [
    {
      name = "aks-subnet"
      address_prefix = "10.1.1.0/24"
    },
    {
      name = "appgateway-subnet"
      address_prefix = "10.1.2.0/24"
    }    
  ]
    backend_address_pool_name      = "${var.prefix}-beap"
  frontend_port_name             = "${var.prefix}-feport"
  frontend_ip_configuration_name = "${var.prefix}-feip"
  http_setting_name              = "${var.prefix}-be-htst"
  listener_name                  = "${var.prefix}-httplstn"
  request_routing_rule_name      = "${var.prefix}-rqrt"
}

variable "subnets" {
  type = map
  default = {
    aks-subnet = {
      name = "aks-subnet"
      address_prefix = "10.1.1.0/24"
    }
    appgateway-subnet = {
      name = "appgateway-subnet"
      address_prefix = "10.1.2.0/24"
    }
  }
}

module "foundation" {
  source = ".//modules/foundation"
  prefix = var.prefix
  location = var.location
}

module "compute" {
  source = ".//modules/compute"
  prefix = var.prefix
  resource_group_name = module.foundation.resource_group_name
  public_ip_address = module.foundation.public_ip_address_id
  virtual_network_name = module.foundation.virtual_network_name
  location = var.location
  depends_on = [ module.foundation ]
  spn_client_secret = var.CLIENT_SECRET
  spn_client_id = var.CLIENT_ID
  spn_object_id = var.spn_object_id
}



output "resource_group_name" {
  value = module.foundation.resource_group_name
}


output "aks_cluster_name" {
  value = module.compute.aksName
}


output "identity_resource_id" {
  value = module.compute.identity_resource_id
}

output "identity_client_id" {
  value = module.compute.identity_client_id
}

/*
resource "azurerm_application_gateway" "network" {
    name                = "${var.prefix}-appgateway"
    resource_group_name = azurerm_resource_group.xlabs.name
    location            = azurerm_resource_group.xlabs.location

    sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
    }

    gateway_ip_configuration {
    name      = "appGatewayIpConfig"
    subnet_id = data.azurerm_subnet.appgateway_subnet.id
    }

  # could use a dynamic resource here
    frontend_port {
    name = local.frontend_port_name
    port = 80
    }


    frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.pip.id
    }

    backend_address_pool {
    name = local.backend_address_pool_name
    }

    backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 1
    }

    http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
    }

    request_routing_rule {
    name                       = local.request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
    }

      tags = {
    Environment = "dev"
  }

    depends_on = [azurerm_virtual_network.aks_vnet, azurerm_public_ip.pip]
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${var.prefix}-aks"
  location            = azurerm_resource_group.xlabs.location
  resource_group_name = azurerm_resource_group.xlabs.name
  dns_prefix          = var.prefix

  addon_profile {
    http_application_routing {
      enabled = false
    }
  }

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2_v2"
    vnet_subnet_id = data.azurerm_subnet.aks_subnet.id
  }



  network_profile {
    network_plugin     = "azure"
    dns_service_ip     = var.aks_dns_service_ip
    docker_bridge_cidr = var.aks_docker_bridge_cidr
    service_cidr       = var.aks_service_cidr
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

output "aksName" {
  value = azurerm_kubernetes_cluster.aks.name
}

output "aksRGName" {
  value = azurerm_resource_group.xlabs.name
}
*/