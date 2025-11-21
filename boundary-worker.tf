# Set up Boundary worker service parameters for the Azure worker instance and create the worker in HCP Boundary.
locals {
  # Compute:
  image_publisher = "Canonical"
  image_offer     = "0001-com-ubuntu-server-jammy"
  image_sku       = "22_04-LTS-gen2"
  image_version   = "latest"

  boundary_worker_config = templatefile("${path.module}/scripts/cloudinit-worker.tftpl", {
    hcp_boundary_cluster_id = split(".", split("//", var.boundary_public_url)[1])[0]
    worker_uid              = random_string.worker_id.id
    worker_activation_token = boundary_worker.hcp_pki_worker.controller_generated_activation_token
    worker_type             = "ingress"
    region                  = var.region
    boundary_version        = var.boundary_version
    vm_ip_address           = azurerm_public_ip.public_vm.ip_address
    lz_name                 = var.lz_name
  })
}

# Scripts:
data "cloudinit_config" "boundary_worker" {
  gzip          = false
  base64_encode = true
  part {
    content_type = "text/x-shellscript"
    content      = local.boundary_worker_config
  }
}

# Random ID for worker:
resource "random_string" "worker_id" {
  length  = 4
  special = false
  upper   = false
  lifecycle {
    create_before_destroy = true
  }
}

resource "boundary_worker" "hcp_pki_worker" {
  count                       = var.number_of_workers
  name                        = "azure-worker-${random_string.worker_id.id}-iw${count.index}"
  worker_generated_auth_token = ""
  lifecycle {
    ignore_changes = [scope_id]
  }
}