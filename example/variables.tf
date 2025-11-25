# Variable Definitions
# Define what type of worker this is:
variable "worker_type" {
    description = "Type of Boundary worker to deploy (ingress or egress)"
    type        = string
    validation {
      condition = var.worker_type == "ingress" || var.worker_type == "egress"
      error_message = "Worker type must be one of 'ingress' or 'egress'"
    }
}

variable "region" {
  description = "Azure region where resources will be deployed"
  type        = string
}

variable "lz_name" {
  description = "Name of the landing zone. Identifier for worker tags. This corresponds to the LZ assigned to this worker."
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "Demo"
    Project     = "Boundary-demo-2"
    ManagedBy   = "Terraform"
  }
}

######################
#     NETWORKING     #
######################
variable "resource_group_name" {
  description = "Name of the existing resource group."
  type        = string
}

variable "vnet_name" {
  description = "Name of the existing VNET."
  type        = string
}

variable "subnet_name" {
  description = "Name of the existing subnet."
  type        = string
}

variable "nsg_name" {
  description = "Name of the existing network security group."
  type        = string
}

######################
#         VM         #
######################
variable "vm_size" {
  description = "Size of the Virtual Machines (2 CPUs, 8GB RAM, 10GB/s network)"
  type        = string
  default     = "Standard_D2s_v5" # 2 vCPUs, 8GB RAM, up to 12.5 Gbps network
}

variable "admin_username" {
  description = "Administrator username for the VMs"
  type        = string
}

variable "vm_name" {
  description = "Name of the public VM"
  type        = string
  default     = "worker-vm"
}

variable "vm_tags" {
  description = "Additional tags for VM"
  type        = map(string)
  default = {
    Purpose = "boundary-worker"
  }
}

variable "number_of_workers" {
  description = "Number of workers to deploy on this network."
  type        = number
}

######################
#      BOUNDARY      #
######################
variable "boundary_addr" {
  description = "Public URL of the Boundary Controller."
  type        = string
}

variable "boundary_username" {
  description = "Username for Boundary admin authentication."
  type        = string
}

variable "boundary_password" {
  description = "Password for Boundary admin authentication."
  type        = string
}

variable "boundary_version" {
  description = "Version of Boundary Enterprise binary to run worker. Must match controller."
  type        = string
  default     = "0.20.0"
}


