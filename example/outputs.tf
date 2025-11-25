output "vm_private_ips" {
  description = "Private IP address of the public VM"
  value       = module.azure_worker.vm_private_ips
}

output "ssh_key" {
  description = "SSH private key for admin purposes."
  sensitive   = true
  value       = module.azure_worker.ssh_key
}
