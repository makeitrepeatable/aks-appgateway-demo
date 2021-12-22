variable "prefix" {
    type = string
    default ="xlabs"
}

variable "virtual_network_address_prefix" {
    type = string
    default = "10.1.0.0/16"
}

variable "aks_subnet_address_prefix" {
    type = string
    default = "10.1.1.0/24"
}

variable "app_gateway_subnet_address_prefix" {
    type = string
    default = "10.1.2.0/24"
}

variable "aks_service_cidr" {
    default     = "10.0.0.0/16"
}

variable "aks_dns_service_ip" {
    default     = "10.0.0.10"
}

variable "aks_docker_bridge_cidr" {
    default     = "172.17.0.1/16"
}

variable "location" {
    type = string
    default = "uksouth"
}

variable "CLIENT_ID" {
    default = "bc84c5dda014477d8054eb4c3617a008"
}
variable "CLIENT_SECRET" {}