

terraform {
  backend "azurerm" {
    key = "terraform.tfstate"
  }
}

module "foundation" {
  source   = ".//modules/foundation"
  prefix   = var.prefix
  location = var.location
}

module "compute" {
  source               = ".//modules/compute"
  prefix               = var.prefix
  resource_group_name  = module.foundation.resource_group_name
  public_ip_address    = module.foundation.public_ip_address_id
  virtual_network_name = module.foundation.virtual_network_name
  location             = var.location
  depends_on           = [module.foundation]
  spn_client_secret    = var.CLIENT_SECRET
  spn_client_id        = var.CLIENT_ID
  spn_object_id        = var.spn_object_id
}



output "resource_group_name" {
  value = module.foundation.resource_group_name
}

output "app_gateway_name" {
  value = module.compute.app_gateway_name
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
