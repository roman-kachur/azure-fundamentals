#### Create resource group ####
resource "azurerm_resource_group" "rg_resource" {
  name     = "task08"
  location = var.location
}

#### Create availability set ####
resource "azurerm_availability_set" "availset_resource" {
  name                = "availabilityset08"
  location            = azurerm_resource_group.rg_resource.location
  resource_group_name = azurerm_resource_group.rg_resource.name
  platform_update_domain_count = 3
  platform_fault_domain_count  = 2
  
  depends_on = [
    azurerm_resource_group.rg_resource
  ]
}

#### Create VPC ####
resource "azurerm_virtual_network" "vpc1_resource" {
  name                = "vpc1"
  location            = azurerm_resource_group.rg_resource.location
  resource_group_name = azurerm_resource_group.rg_resource.name
  address_space       = ["10.8.0.0/16"]
  
  depends_on = [
    azurerm_resource_group.rg_resource
  ]
}

#### Create backend subnet ####
resource "azurerm_subnet" "subnet1_resource" {
  name                 = "subnet1"
  resource_group_name  = azurerm_resource_group.rg_resource.name
  virtual_network_name = azurerm_virtual_network.vpc1_resource.name
  address_prefixes     = ["10.8.1.0/24"]

  depends_on = [
    azurerm_virtual_network.vpc1_resource,
    azurerm_resource_group.rg_resource
  ]
}

#### Create network security group for backend subnet ####
resource "azurerm_network_security_group" "nsg1_resource" {
  name                	   = "nsg1"
  resource_group_name      = azurerm_resource_group.rg_resource.name
  location                 = azurerm_resource_group.rg_resource.location

  security_rule {
    name                       = "in_web"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = [80]
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  
  depends_on = [
    azurerm_resource_group.rg_resource
  ]
}

# https://learn.microsoft.com/en-us/security/benchmark/azure/baselines/azure-load-balancer-security-baseline#network-security
#
# Configuration Guidance: Implement network security groups 
# and only allow access to your application's trusted ports and IP address ranges. 
# In cases where there is no network security group assigned to the backend subnet 
# or NIC of the backend virtual machines, traffic will not be allowed to access 
# these resources from the load balancer. 

#### Associate nsg with backend subnet ####
resource "azurerm_subnet_network_security_group_association" "nsg1associate1_resource" {
  subnet_id                 = azurerm_subnet.subnet1_resource.id
  network_security_group_id = azurerm_network_security_group.nsg1_resource.id

  depends_on = [
    azurerm_subnet.subnet1_resource
  ]
}

#### Create public IP for NAT GW ####
resource "azurerm_public_ip" "publicip1_resource" {
  name                = "public_ip_natgw"
  location            = azurerm_resource_group.rg_resource.location
  resource_group_name = azurerm_resource_group.rg_resource.name
  allocation_method   = "Static"
  sku				  = "Standard"
  sku_tier			  = "Regional"
  ip_version		  = "IPv4"
  
  depends_on = [
    azurerm_resource_group.rg_resource
  ]
}

#### Create NAT GW ####
resource "azurerm_nat_gateway" "natgw_resource" {
  name                    = "nat-Gateway"
  location                = azurerm_resource_group.rg_resource.location
  resource_group_name     = azurerm_resource_group.rg_resource.name
  sku_name                = "Standard"
  
  depends_on = [
    azurerm_resource_group.rg_resource
  ]
}

#### Associate NAT GW with Public IP ####
resource "azurerm_nat_gateway_public_ip_association" "natgw-ip_resource" {
  nat_gateway_id       = azurerm_nat_gateway.natgw_resource.id
  public_ip_address_id = azurerm_public_ip.publicip1_resource.id
  
  depends_on = [
    azurerm_nat_gateway.natgw_resource,
    azurerm_public_ip.publicip1_resource
  ]
}

#### Associate NAT GW with Subnet ####
resource "azurerm_subnet_nat_gateway_association" "natgw-subnet1_resource" {
  subnet_id      = azurerm_subnet.subnet1_resource.id
  nat_gateway_id = azurerm_nat_gateway.natgw_resource.id

  depends_on = [
    azurerm_subnet.subnet1_resource,
    azurerm_nat_gateway.natgw_resource
  ]
}

#### Create nic for backend vm1 ####
resource "azurerm_network_interface" "nic1_resource" {
  name                = "nic1"
  location            = azurerm_resource_group.rg_resource.location
  resource_group_name = azurerm_resource_group.rg_resource.name

  ip_configuration {
    name                          = "internal_1"
    subnet_id                     = azurerm_subnet.subnet1_resource.id
    private_ip_address_allocation = "Dynamic"
  }

  depends_on = [
    azurerm_subnet.subnet1_resource
  ]
}

#### Create nic for backend vm2 ####
resource "azurerm_network_interface" "nic2_resource" {
  name                = "nic2"
  location            = azurerm_resource_group.rg_resource.location
  resource_group_name = azurerm_resource_group.rg_resource.name

  ip_configuration {
    name                          = "internal_2"
    subnet_id                     = azurerm_subnet.subnet1_resource.id
    private_ip_address_allocation = "Dynamic"
  }

  depends_on = [
    azurerm_subnet.subnet1_resource
  ]
}

#### Create backend vm1 ####
resource "azurerm_virtual_machine" "vm1_resource" {
  name                  = "vm1"
  location            = azurerm_resource_group.rg_resource.location
  resource_group_name = azurerm_resource_group.rg_resource.name
  network_interface_ids = [azurerm_network_interface.nic1_resource.id]
  vm_size               = "Standard_B1ls"

  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true

  availability_set_id = azurerm_availability_set.availset_resource.id

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
    disk_size_gb	  = "30"
  }
  os_profile {
    computer_name  = "backend-host-1"
    admin_username = "testadmin"
    admin_password = "testPassword!234!"
    custom_data	   = filebase64("custom-data.txt")
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  
  depends_on = [
    azurerm_subnet.subnet1_resource,
    azurerm_availability_set.availset_resource
  ]
}

#### Create backend vm2 ####
resource "azurerm_virtual_machine" "vm2_resource" {
  name                  = "vm2"
  location            = azurerm_resource_group.rg_resource.location
  resource_group_name = azurerm_resource_group.rg_resource.name
  network_interface_ids = [azurerm_network_interface.nic2_resource.id]
  vm_size               = "Standard_B1ls"

  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true

  availability_set_id = azurerm_availability_set.availset_resource.id

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk2"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
    disk_size_gb	  = "30"
  }
  os_profile {
    computer_name  = "backend-host-2"
    admin_username = "testadmin"
    admin_password = "testPassword!234!"
    custom_data	   = filebase64("custom-data.txt")
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  
  depends_on = [
    azurerm_subnet.subnet1_resource,
    azurerm_availability_set.availset_resource
  ]
}

#### Create public IP for public Load-Balancer ####
resource "azurerm_public_ip" "publiciplb_resource" {
  name                = "public_ip_lb"
  location            = azurerm_resource_group.rg_resource.location
  resource_group_name = azurerm_resource_group.rg_resource.name
  allocation_method   = "Static"
  sku				  = "Standard"
  sku_tier			  = "Regional"
  ip_version		  = "IPv4"
  
  depends_on = [
    azurerm_resource_group.rg_resource
  ]
}

#### Create public Load-Balancer ####
resource "azurerm_lb" "lb_resource" {
  name                = "PublicLoadBalancer"
  location            = azurerm_resource_group.rg_resource.location
  resource_group_name = azurerm_resource_group.rg_resource.name
  sku 				  = "Standard"

  frontend_ip_configuration {
    name                 			= "PublicIPAddress"
    private_ip_address_allocation 	= "Dynamic"
    public_ip_address_id 			= azurerm_public_ip.publiciplb_resource.id
  }

  depends_on = [
    azurerm_public_ip.publiciplb_resource,
    azurerm_subnet.subnet1_resource
  ]
}

#### Create Probe ####
resource "azurerm_lb_probe" "probe_resource" {
  loadbalancer_id     = azurerm_lb.lb_resource.id
  name                = "http-inbound-probe"
  protocol            = "Tcp"
  port				  = 80

  depends_on = [
    azurerm_lb.lb_resource
  ]
}

#### Create Backend Address Pool ####
resource "azurerm_lb_backend_address_pool" "backendpool_resource" {
  loadbalancer_id     = azurerm_lb.lb_resource.id
  name            	  = "backend-pool"

  depends_on = [
    azurerm_lb.lb_resource
  ]
}

#### Associate two VM IPs with Backend Address Pool ####
resource "azurerm_network_interface_backend_address_pool_association" "bepoolassociate1_resource" {
  network_interface_id    = azurerm_network_interface.nic1_resource.id
  ip_configuration_name   = "internal_1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.backendpool_resource.id

  depends_on = [
    azurerm_lb_backend_address_pool.backendpool_resource,
    azurerm_network_interface.nic1_resource
  ]
}

resource "azurerm_network_interface_backend_address_pool_association" "bepoolassociate2_resource" {
  network_interface_id    = azurerm_network_interface.nic2_resource.id
  ip_configuration_name   = "internal_2"
  backend_address_pool_id = azurerm_lb_backend_address_pool.backendpool_resource.id

  depends_on = [
    azurerm_lb_backend_address_pool.backendpool_resource,
    azurerm_network_interface.nic2_resource
  ]
}

#### Create LB rule ####
resource "azurerm_lb_rule" "lbrule_resource" {
  loadbalancer_id                = azurerm_lb.lb_resource.id
  name                           = "LBRule1"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "PublicIPAddress"
  backend_address_pool_ids		 = [azurerm_lb_backend_address_pool.backendpool_resource.id]
  probe_id						 = azurerm_lb_probe.probe_resource.id
}

