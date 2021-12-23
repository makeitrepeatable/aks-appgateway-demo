variable "prefix" {
    type = string
}

variable "virtual_network_address_prefix" {
    type = string
    default = "10.1.0.0/16"
}

variable "location" {
    type = string
    default = "uksouth"
}