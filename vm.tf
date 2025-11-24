# Ingress Worker = PUBLIC

# Public IP for Public VM
resource "azurerm_public_ip" "vm" {
  # The public IP is conditionally created only if it's an ingress worker
  count               = var.worker_type == "ingress" ? var.number_of_workers : 0
  name                = "${var.vm_name}-pip-${random_string.worker_id[count.index].id}-${count.index}"
  location            = data.azurerm_resource_group.existing_rg.location
  resource_group_name = data.azurerm_resource_group.existing_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = merge(var.common_tags, var.vm_tags)
}

# Network Interface for Public VM
resource "azurerm_network_interface" "vm" {
  count               = var.number_of_workers
  name                = "${var.vm_name}-nic-${random_string.worker_id[count.index].id}-${count.index}"
  location            = data.azurerm_resource_group.existing_rg.location
  resource_group_name = data.azurerm_resource_group.existing_rg.name
  tags                = merge(var.common_tags, var.vm_tags)

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.existing_public.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.worker_type == "ingress" ? azurerm_public_ip.vm[count.index].id : null
  }
}

# Associate Network Interface with Public NSG
resource "azurerm_network_interface_security_group_association" "vm" {
  count                     = var.number_of_workers
  network_interface_id      = azurerm_network_interface.vm[count.index].id
  network_security_group_id = data.azurerm_network_security_group.existing_nsg.id
}

# SSH Key for Public VMs
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Public VM
resource "azurerm_linux_virtual_machine" "vm" {
  count               = var.number_of_workers
  name                = "${var.vm_name}-${random_string.worker_id[count.index].id}-${count.index}"
  location            = data.azurerm_resource_group.existing_rg.location
  resource_group_name = data.azurerm_resource_group.existing_rg.name
  size                = var.vm_size
  admin_username      = var.admin_username
  tags                = merge(var.common_tags, var.vm_tags, {WorkerType = var.worker_type})

  # Configure Worker:
  user_data = data.cloudinit_config.boundary_worker[count.index].rendered

  network_interface_ids = [
    azurerm_network_interface.vm[count.index].id,
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
    ignore_changes = [ user_data ]
  }

  depends_on = [
    azurerm_network_interface_security_group_association.vm, # to destroy correctly
    boundary_worker.hcp_pki_worker                           # This is critical to ensure the config will have the auth token.
  ]
}