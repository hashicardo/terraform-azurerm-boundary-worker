# Output Values
output "vm_names" {
  description = "Name of the public VM"
  value       = [for vm in azurerm_linux_virtual_machine.vm : vm.name]
}

output "vm_public_ips" {
  description = "Public IP address of the public VM"
  value       = [for ip in azurerm_public_ip.vm : ip.ip_address]
}

output "vm_private_ips" {
  description = "Private IP address of the public VM"
  value       = [for vm in azurerm_linux_virtual_machine.vm : vm.private_ip_address]
}

output "ssh_key" {
  description = "SSH private key for admin purposes."
  sensitive   = true
  value       = tls_private_key.ssh_key.private_key_pem
}
