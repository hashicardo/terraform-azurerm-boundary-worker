# Output Values
output "public_vm_name" {
  description = "Name of the public VM"
  value       = azurerm_linux_virtual_machine.public.name
}

output "public_vm_public_ip" {
  description = "Public IP address of the public VM"
  value       = azurerm_public_ip.public_vm.ip_address
}

output "public_vm_private_ip" {
  description = "Private IP address of the public VM"
  value       = azurerm_linux_virtual_machine.public.private_ip_address
}

output "ssh_key" {
  description = "SSH private key for admin purposes."
  sensitive   = true
  value       = tls_private_key.ssh_key.private_key_pem
}
