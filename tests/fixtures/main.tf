terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
  required_version = ">= 0.13"
}

provider "azurerm" {
  features {}
}

variable "prefix" {}


module "foundation" {
  source = "../../modules/foundation"
  prefix = var.prefix
}


output "virtual_network_name" {
  value = module.foundation.virtual_network_name
}
