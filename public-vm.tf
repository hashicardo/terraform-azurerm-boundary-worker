# Ingress Worker = PUBLIC

# Public IP for Public VM
resource "azurerm_public_ip" "public_vm" {
  count               = var.number_of_workers
  name                = "${var.public_vm_name}-pip-${random_string.worker_id.id}-${count.index}"
  location            = data.azurerm_resource_group.existing_rg.location
  resource_group_name = data.azurerm_resource_group.existing_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = merge(var.common_tags, var.public_vm_tags)
}

# Network Interface for Public VM
resource "azurerm_network_interface" "public_vm" {
  count               = var.number_of_workers
  name                = "${var.public_vm_name}-nic-${random_string.worker_id.id}-${count.index}"
  location            = data.azurerm_resource_group.existing_rg.location
  resource_group_name = data.azurerm_resource_group.existing_rg.name
  tags                = merge(var.common_tags, var.public_vm_tags)

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.existing_public.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_vm[count.index].id
  }
}

# Associate Network Interface with Public NSG
resource "azurerm_network_interface_security_group_association" "public_vm" {
  count                     = var.number_of_workers
  network_interface_id      = azurerm_network_interface.public_vm[count.index].id
  network_security_group_id = data.azurerm_network_security_group.existing_nsg.id
}

# Public VM
resource "azurerm_linux_virtual_machine" "public" {
  count               = var.number_of_workers
  name                = "${var.public_vm_name}-${random_string.worker_id.id}-${count.index}"
  location            = data.azurerm_resource_group.existing_rg.location
  resource_group_name = data.azurerm_resource_group.existing_rg.name
  size                = var.vm_size
  admin_username      = var.admin_username
  tags                = merge(var.common_tags, var.public_vm_tags)

  # Configure Worker:
  custom_data = data.cloudinit_config.boundary_worker.rendered

  network_interface_ids = [
    azurerm_network_interface.public_vm[count.index].id,
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = tls_private_key.ssh_key.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = 30
  }

  source_image_reference {
    publisher = local.image_publisher
    offer     = local.image_offer
    sku       = local.image_sku
    version   = local.image_version
  }

  disable_password_authentication = true

  lifecycle {
    replace_triggered_by = [boundary_worker.hcp_pki_worker]
  }

  depends_on = [
    azurerm_network_interface_security_group_association.public_vm, # to destroy correctly
    boundary_worker.hcp_pki_worker                                  # This is critical to ensure the worker will have the auth token.
  ]
}

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}