# This data source retrieves information about the existing virtual network
data "azurerm_subnet" "existing_public" {
  name                 = var.subnet_name
  virtual_network_name = var.vnet_name
  resource_group_name  = var.resource_group_name
}

data "azurerm_resource_group" "existing_rg" {
  name = var.resource_group_name
}

data "azurerm_network_security_group" "existing_nsg" {
  name                = var.nsg_name
  resource_group_name = var.resource_group_name
}