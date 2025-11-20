# This data source retrieves information about the existing virtual network
data "azurerm_subnet" "existing_public" {
  name                 = var.public_subnet_name
  virtual_network_name = var.vnet_name
  resource_group_name  = var.resource_group_name
}

data "azurerm_resource_group" "existing_rg" {
  name = var.resource_group_name
}

# Associate NSG with Public Subnet
resource "azurerm_subnet_network_security_group_association" "public" {
  subnet_id                 = data.azurerm_subnet.existing_public.id
  network_security_group_id = azurerm_network_security_group.public.id
}

# Network Security Group for Public Subnet
resource "azurerm_network_security_group" "public" {
  name                = "${var.public_subnet_name}-nsg"
  location            = data.azurerm_resource_group.existing_rg.location
  resource_group_name = data.azurerm_resource_group.existing_rg.name
  tags                = var.common_tags

  # Inbound rule for port 22
  security_rule {
    name                       = "allow-inbound-ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Inbound rule for port 9202
  security_rule {
    name                       = "allow-inbound-9202"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "9202"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Inbound rule for port 9203
  security_rule {
    name                       = "allow-inbound-9203"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "9203"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Outbound rule for port 9201
  security_rule {
    name                       = "allow-outbound-9201"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "9201"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Allow outbound internet access (required for updates, etc.)
  security_rule {
    name                       = "allow-outbound-internet"
    priority                   = 110
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}