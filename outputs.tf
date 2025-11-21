# Output Values
output "public_vm_names" {
  description = "Name of the public VM"
  value       = [for vm in azurerm_linux_virtual_machine.public : vm.name]
}

output "public_vm_public_ips" {
  description = "Public IP address of the public VM"
  value       = [for ip in azurerm_public_ip.public_vm : ip.ip_address]
}

output "public_vm_private_ips" {
  description = "Private IP address of the public VM"
  value       = [for vm in azurerm_linux_virtual_machine.public : vm.private_ip_address]
}

output "ssh_key" {
  description = "SSH private key for admin purposes."
  sensitive   = true
  value       = tls_private_key.ssh_key.private_key_pem
}
