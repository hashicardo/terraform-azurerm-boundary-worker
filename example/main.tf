# Main Terraform Configuration for Azure Infrastructure

terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.53.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.1.0"
    }
    boundary = {
      source  = "hashicorp/boundary"
      version = "~> 1.4"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.7.2"
    }
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "2.3.7"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "boundary" {
  addr                   = var.boundary_addr
  auth_method_login_name = var.boundary_username
  auth_method_password   = var.boundary_password
}

module "azure_worker" {
  source            = "git::https://github.com/hashicardo/terraform-azurerm-boundary-worker.git"
  number_of_workers = var.number_of_workers
  worker_type       = var.worker_type

  region            = var.region
  boundary_addr     = var.boundary_addr
  boundary_username = var.boundary_username
  boundary_password = var.boundary_password
  boundary_version  = var.boundary_version
  lz_name           = var.lz_name
  admin_username    = var.admin_username

  vnet_name           = var.vnet_name
  subnet_name         = var.subnet_name
  resource_group_name = var.resource_group_name
  nsg_name            = var.nsg_name
}