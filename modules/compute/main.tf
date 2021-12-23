locals {
    backend_address_pool_name      = "${var.prefix}-beap"
  frontend_port_name             = "${var.prefix}-feport"
  frontend_ip_configuration_name = "${var.prefix}-feip"
  http_setting_name              = "${var.prefix}-be-htst"
  listener_name                  = "${var.prefix}-httplstn"
  request_routing_rule_name      = "${var.prefix}-rqrt"
}

# User assigned identity 
resource "azurerm_user_assigned_identity" "aksmsi" {
    resource_group_name = var.resource_group_name
    location            = var.location

    name = "${var.prefix}-aks-identity"

}

resource "azurerm_application_gateway" "network" {
    name                = "${var.prefix}-appgateway"
    resource_group_name = var.resource_group_name
    location            = var.location

    sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
    }

    gateway_ip_configuration {
    name      = "appGatewayIpConfig"
    subnet_id = data.azurerm_subnet.appgateway.id
    }

  # could use a dynamic resource here
    frontend_port {
    name = local.frontend_port_name
    port = 80
    }


    frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = var.public_ip_address
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

}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${var.prefix}-aks"
  resource_group_name = var.resource_group_name
  location            = var.location
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
    vnet_subnet_id = data.azurerm_subnet.aks.id
  }



  network_profile {
    network_plugin     = "azure"
    dns_service_ip     = var.aks_dns_service_ip
    docker_bridge_cidr = var.aks_docker_bridge_cidr
    service_cidr       = var.aks_service_cidr
    }

  service_principal {
    client_id     = var.spn_client_id
    client_secret = var.spn_client_secret
    }

  role_based_access_control {
    enabled = false
  }

  tags = {
    Environment = "dev"
  }
}

data "azurerm_container_registry" "acr" {
    name = "makeitrepeatable"
    resource_group_name = "makeitrepeatable-acr"
}

# assign roles to managed identities 
resource "azurerm_role_assignment" "attach_acr" {
  scope                = data.azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.aksmsi.principal_id

}

resource "azurerm_role_assignment" "network" {
    scope                = data.azurerm_subnet.aks.id
    role_definition_name = "Network Contributor"
    principal_id         = var.spn_object_id
}

resource "azurerm_role_assignment" "msi" {
    scope                = azurerm_user_assigned_identity.aksmsi.id
    role_definition_name = "Managed Identity Operator"
    principal_id         = var.spn_object_id
    depends_on           = [azurerm_user_assigned_identity.aksmsi]
}

resource "azurerm_role_assignment" "contributor" {
    scope                = azurerm_application_gateway.network.id
    role_definition_name = "Contributor"
    principal_id         = azurerm_user_assigned_identity.aksmsi.principal_id
    depends_on           = [azurerm_user_assigned_identity.aksmsi, azurerm_application_gateway.network]
}

output "client_certificate" {
  value = azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate
}

output "app_gateway_name" {
  value = azurerm_application_gateway.network.name
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive = true
}

output "aksName" {
  value = azurerm_kubernetes_cluster.aks.name
}

output "identity_resource_id" {
  value = azurerm_user_assigned_identity.aksmsi.id
}

output "identity_client_id" {
  value = azurerm_user_assigned_identity.aksmsi.client_id
}
