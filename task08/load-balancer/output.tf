output "LB-Public-IP" {
  value = azurerm_public_ip.publiciplb_resource.ip_address
}  
