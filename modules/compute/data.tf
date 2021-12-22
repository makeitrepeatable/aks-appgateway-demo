data "azurerm_subnet" "aks" {
    name = "aks-subnet"
    resource_group_name = var.resource_group_name
    virtual_network_name = var.virtual_network_name
}

data "azurerm_subnet" "appgateway" {
    name = "appgateway-subnet"
    resource_group_name = var.resource_group_name
    virtual_network_name = var.virtual_network_name
}