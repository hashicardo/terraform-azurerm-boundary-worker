# Set up Boundary worker service parameters for the Azure worker instance and create the worker in HCP Boundary.
locals {
  # Compute:
  image_publisher = "Canonical"
  image_offer     = "0001-com-ubuntu-server-jammy"
  image_sku       = "22_04-LTS-gen2"
  image_version   = "latest"

  # Create a map for workers
  workers = { for i in range(var.number_of_workers) : i => i }

  type_id = var.worker_type == "ingress" ? "inw" : "egw" # Changes type_id based on worker_type
}

# Scripts:
data "cloudinit_config" "boundary_worker" {
  for_each      = local.workers
  gzip          = false
  base64_encode = true
  part {
    content_type = "text/x-shellscript"
    content = templatefile("${path.module}/scripts/cloudinit-worker.tftpl", {
      hcp_boundary_cluster_id = split(".", split("//", var.boundary_addr)[1])[0]
      worker_uid              = random_string.worker_id[each.key].id
      worker_activation_token = boundary_worker.hcp_pki_worker[each.key].controller_generated_activation_token
      worker_type             = var.worker_type
      region                  = var.region
      boundary_version        = var.boundary_version
      vm_ip_address           = var.worker_type == "ingress" ? azurerm_public_ip.vm[each.key].ip_address : azurerm_network_interface.vm[each.key].private_ip_address
      lz_name                 = var.lz_name
    })
  }
}

# Random ID for worker:
resource "random_string" "worker_id" {
  count = var.number_of_workers
  length  = 4
  special = false
  upper   = false
}

resource "boundary_worker" "hcp_pki_worker" {
  count                       = var.number_of_workers
  name                        = "azure-worker-${random_string.worker_id[count.index].id}-${local.type_id}${count.index}"
  worker_generated_auth_token = ""
  lifecycle {
    ignore_changes = [scope_id]
  }
}