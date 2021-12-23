
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

resource "azurerm_resource_group" "aks" {
  name     = "${var.prefix}-aks-rg"
  location = "uksouth"
}

# begin appgw creation
resource "azurerm_virtual_network" "aks_vnet" {
    name                = "${var.prefix}-vnet"
    location            = azurerm_resource_group.aks.location
    resource_group_name = azurerm_resource_group.aks.name
    address_space       = [var.virtual_network_address_prefix]

  tags = {
    Environment = "dev"
  }
}

resource "azurerm_subnet" "subnets" {
  for_each = var.subnets
  name = each.value.name
  address_prefix = each.value.address_prefix
  virtual_network_name = azurerm_virtual_network.aks_vnet.name
  resource_group_name = azurerm_resource_group.aks.name
  depends_on = [azurerm_virtual_network.aks_vnet]
}


# Public Ip 
resource "azurerm_public_ip" "pip" {
    name                         = "${var.prefix}-publicip"
    location                     = azurerm_resource_group.aks.location
    resource_group_name          = azurerm_resource_group.aks.name
    allocation_method            = "Static"
    sku                          = "Standard"

      tags = {
    Environment = "dev"
  }

  depends_on = [ azurerm_virtual_network.aks_vnet ]
}

output "resource_group_name" {
  value = azurerm_resource_group.aks.name
}

output "virtual_network_id" {
  value = azurerm_virtual_network.aks_vnet.id
}

output "virtual_network_name" {
  value = azurerm_virtual_network.aks_vnet.name
}


output "public_ip_address_id" {
  value = azurerm_public_ip.pip.id
}
