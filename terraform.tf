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

# provider "azurerm" {
#   features {}
# }

# provider "boundary" {
#   addr                   = var.boundary_public_url
#   auth_method_login_name = var.boundary_username
#   auth_method_password   = var.boundary_password
# }