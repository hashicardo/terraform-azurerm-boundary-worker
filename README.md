# Azure Worker Ingress
This infrastructure deploys the necessary infrastructure and configuration for an Ingress worker in Azure.

The reason why I call this an ingress worker is because it creates a public IP for the VM where it will be running and it should be deployed inside a public network. I.e. a network that can accept connections to this IP from anywhere on the internet.

This will satisfy the condition that basically any client can access it from the internet.

## What This Module Creates

- **Azure Linux VM** (Ubuntu 22.04 LTS) with Boundary Enterprise worker installed
- **Public IP address** (Static) for external client access
- **Network Interface** with both public and private IP configurations
- **Network Interface Security Group Association** (associates with existing NSG)
- **HCP Boundary Worker** registration with controller-generated activation token
- **SSH Key Pair** (TLS-generated) for VM access

## Public Network Requirements

- **Existing Network Security Group**: This module requires a pre-existing NSG with rules for:
  - Inbound: SSH (22), Boundary proxy (9202, 9203)
  - Outbound: Boundary controller (9201), internet access
  - (WIP) Connection to Vault for credential retrieval (credential injection)
- The module associates the VM's network interface with the existing NSG but does not create or manage the NSG itself

## Prerequisites

- Existing Azure Resource Group
- Existing Virtual Network (VNet)
- Existing Public Subnet
- **Existing Network Security Group** configured with appropriate rules for Boundary worker
- HCP Boundary cluster with admin credentials
- Azure authentication credentials set via environment variables:
  ```bash
  export ARM_CLIENT_ID=<your-client-id>
  export ARM_CLIENT_SECRET=<your-client-secret>
  export ARM_SUBSCRIPTION_ID=<your-subscription-id>
  export ARM_TENANT_ID=<your-tenant-id>
  ```

## Example Usage

1. Copy the example variables file:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. Add the required configuration and instantiate the module like this:
```hcl
module "azure_worker_ingress" {
  source              = "git::https://github.com/hashicardo/terraform-azurerm-boundary-ingress-worker/tree/main"
  count               = 3
  region              = var.region
  boundary_public_url = var.boundary_public_url
  boundary_username   = var.boundary_username
  boundary_password   = var.boundary_password
  boundary_version    = var.boundary_version
  lz_name             = var.lz_name
  admin_username      = var.admin_username

  vnet_name           = azurerm_virtual_network.main.name
  subnet_name  = azurerm_subnet.public.name
  resource_group_name = azurerm_resource_group.main.name
  nsg_name     = azurerm_network_security_group.public.name
}
```

3. Initialize and apply:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Worker Configuration

The worker is configured with the following properties:
- **Type**: `ingress`
- **Purpose**: Accept connections from external clients
- **Tags**: Automatically tagged with `type`, `cloud`, `region`, and `lz_name`
- **Version**: Boundary Enterprise (configurable, default 0.20.0)
- **Authentication**: Controller-generated PKI token
- **Public Address**: Uses the VM's public IP for client connectivity

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `region` | Azure region where resources will be deployed | string | - | yes |
| `resource_group_name` | Name of the existing resource group | string | - | yes |
| `vnet_name` | Name of the existing VNet | string | - | yes |
| `subnet_name` | Name of the existing public subnet | string | - | yes |
| `nsg_name` | Name of the existing public network security group | string | - | yes |
| `lz_name` | Landing zone identifier for worker tags | string | - | yes |
| `boundary_public_url` | Public URL of the Boundary Controller | string | - | yes |
| `boundary_username` | Username for Boundary admin authentication | string | - | yes |
| `boundary_password` | Password for Boundary admin authentication | string | - | yes |
| `vm_size` | Size of the Virtual Machine | string | `"Standard_D2s_v5"` | no |
| `admin_username` | Administrator username for the VM | string | - | yes |
| `vm_name` | Name of the public VM | string | `"public-vm"` | no |
| `boundary_version` | Version of Boundary Enterprise binary | string | `"0.20.0"` | no |
| `common_tags` | Common tags to apply to all resources | map(string) | See variables.tf | no |
| `vm_tags` | Additional tags for public VM | map(string) | See variables.tf | no |

## Outputs

| Name | Description |
|------|-------------|
| `vm_name` | Name of the public VM |
| `vm_public_ip` | Public IP address of the public VM |
| `vm_private_ip` | Private IP address of the public VM |
| `ssh_key` | SSH private key for admin purposes (sensitive) |

## Files

- `boundary-worker.tf` - HCP Boundary worker resource and cloudinit configuration
- `public-vm.tf` - Azure VM, network interface, public IP, and NSG association resources
- `networking-data.tf` - Data sources for existing network resources (VNet, subnet, NSG, resource group)
- `variables.tf` - Input variable definitions
- `outputs.tf` - Output value definitions
- `terraform.tf` - Provider version requirements
- `scripts/cloudinit-worker.tftpl` - Cloud-init script template for worker installation

## Notes

- The VM is automatically replaced when the Boundary worker resource is replaced
- SSH key pair is generated by Terraform and stored in state (retrieve via outputs)
- Worker registers with HCP Boundary using a controller-generated activation token
- Cloud-init logs are available at `/var/log/cloud-init-worker.log` on the VM
- Boundary service runs as a systemd service and can be managed with `systemctl`
