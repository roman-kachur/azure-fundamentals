#### Create resource group ####
resource "azurerm_resource_group" "rg_resource" {
  name     = "task08"
  location = var.location
}

#### Create VPC1 ####
resource "azurerm_virtual_network" "vpc1_resource" {
  name                = "vpc1"
  location            = azurerm_resource_group.rg_resource.location
  resource_group_name = azurerm_resource_group.rg_resource.name
  address_space       = [var.vnet1_cidr]
  
  depends_on = [
    azurerm_resource_group.rg_resource
  ]
}

#### Create three subnets in vpc1 ####
resource "azurerm_subnet" "vnet1_subnet1_resource" {
  name                 = "vnet1_subnet1"
  resource_group_name  = azurerm_resource_group.rg_resource.name
  virtual_network_name = azurerm_virtual_network.vpc1_resource.name
  address_prefixes     = [var.vnet1_subnet1_cidr]

  depends_on = [
    azurerm_virtual_network.vpc1_resource
  ]
}

resource "azurerm_subnet" "vnet1_subnet2_resource" {
  name                 = "vnet1_subnet2"
  resource_group_name  = azurerm_resource_group.rg_resource.name
  virtual_network_name = azurerm_virtual_network.vpc1_resource.name
  address_prefixes     = [var.vnet1_subnet2_cidr]

  depends_on = [
    azurerm_virtual_network.vpc1_resource
  ]
}

resource "azurerm_subnet" "vnet1_subnet3_resource" {
  name                 = "vnet1_subnet3"
  resource_group_name  = azurerm_resource_group.rg_resource.name
  virtual_network_name = azurerm_virtual_network.vpc1_resource.name
  address_prefixes     = [var.vnet1_subnet3_cidr]

  depends_on = [
    azurerm_virtual_network.vpc1_resource
  ]
}

#### Create VPC2 ####
resource "azurerm_virtual_network" "vpc2_resource" {
  name                = "vpc2"
  location            = azurerm_resource_group.rg_resource.location
  resource_group_name = azurerm_resource_group.rg_resource.name
  address_space       = [var.vnet2_cidr]
  
  depends_on = [
    azurerm_resource_group.rg_resource
  ]
}

#### Create two subnets in vpc2 ####
resource "azurerm_subnet" "vnet2_subnet1_resource" {
  name                 = "vnet2_subnet1"
  resource_group_name  = azurerm_resource_group.rg_resource.name
  virtual_network_name = azurerm_virtual_network.vpc2_resource.name
  address_prefixes     = [var.vnet2_subnet1_cidr]

  depends_on = [
    azurerm_virtual_network.vpc2_resource
  ]
}

resource "azurerm_subnet" "vnet2_subnet2_resource" {
  name                 = "vnet2_subnet2"
  resource_group_name  = azurerm_resource_group.rg_resource.name
  virtual_network_name = azurerm_virtual_network.vpc2_resource.name
  address_prefixes     = [var.vnet2_subnet2_cidr]

  depends_on = [
    azurerm_virtual_network.vpc2_resource
  ]
}

#### Create VPC3 ####
resource "azurerm_virtual_network" "vpc3_resource" {
  name                = "vpc3"
  location            = azurerm_resource_group.rg_resource.location
  resource_group_name = azurerm_resource_group.rg_resource.name
  address_space       = [var.vnet3_cidr]
  
  depends_on = [
    azurerm_resource_group.rg_resource
  ]
}

#### Create three subnets in vpc3 ####
resource "azurerm_subnet" "vnet3_subnet1_resource" {
  name                 = "vnet3_subnet1"
  resource_group_name  = azurerm_resource_group.rg_resource.name
  virtual_network_name = azurerm_virtual_network.vpc3_resource.name
  address_prefixes     = [var.vnet3_subnet1_cidr]

  depends_on = [
    azurerm_virtual_network.vpc3_resource
  ]
}

resource "azurerm_subnet" "vnet3_subnet2_resource" {
  name                 = "vnet3_subnet2"
  resource_group_name  = azurerm_resource_group.rg_resource.name
  virtual_network_name = azurerm_virtual_network.vpc3_resource.name
  address_prefixes     = [var.vnet3_subnet2_cidr]

  depends_on = [
    azurerm_virtual_network.vpc3_resource
  ]
}

resource "azurerm_subnet" "vnet3_subnet3_resource" {
  name                 = "vnet3_subnet3"
  resource_group_name  = azurerm_resource_group.rg_resource.name
  virtual_network_name = azurerm_virtual_network.vpc3_resource.name
  address_prefixes     = [var.vnet3_subnet3_cidr]

  depends_on = [
    azurerm_virtual_network.vpc3_resource
  ]
}

# https://learn.microsoft.com/en-us/azure/virtual-network/virtual-network-peering-overview
# 
# If you open full connectivity between peered virtual networks,
# you can apply network security groups to block or deny specific access.
# Full connectivity is the default option.

#### Create vnet peering vpc 1<->2 ####
resource "azurerm_virtual_network_peering" "peering1-2" {
  name                      	= "peer1-2"
  resource_group_name  			= azurerm_resource_group.rg_resource.name
  virtual_network_name      	= azurerm_virtual_network.vpc1_resource.name
  remote_virtual_network_id 	= azurerm_virtual_network.vpc2_resource.id
  allow_virtual_network_access 	= true

  depends_on = [
    azurerm_virtual_network.vpc1_resource,
    azurerm_virtual_network.vpc2_resource
  ]
}
resource "azurerm_virtual_network_peering" "peering2-1" {
  name                      	= "peer2-1"
  resource_group_name  			= azurerm_resource_group.rg_resource.name
  virtual_network_name      	= azurerm_virtual_network.vpc2_resource.name
  remote_virtual_network_id 	= azurerm_virtual_network.vpc1_resource.id
  allow_virtual_network_access 	= true

  depends_on = [
    azurerm_virtual_network.vpc1_resource,
    azurerm_virtual_network.vpc2_resource
  ]
}

#### Create vnet peering vpc 1<->3 ####
resource "azurerm_virtual_network_peering" "peering1-3" {
  name                      	= "peer1-3"
  resource_group_name  			= azurerm_resource_group.rg_resource.name
  virtual_network_name      	= azurerm_virtual_network.vpc1_resource.name
  remote_virtual_network_id 	= azurerm_virtual_network.vpc3_resource.id
  allow_virtual_network_access 	= true

  depends_on = [
    azurerm_virtual_network.vpc1_resource,
    azurerm_virtual_network.vpc3_resource
  ]
}
resource "azurerm_virtual_network_peering" "peering3-1" {
  name                      	= "peer3-1"
  resource_group_name  			= azurerm_resource_group.rg_resource.name
  virtual_network_name      	= azurerm_virtual_network.vpc3_resource.name
  remote_virtual_network_id 	= azurerm_virtual_network.vpc1_resource.id
  allow_virtual_network_access 	= true

  depends_on = [
    azurerm_virtual_network.vpc1_resource,
    azurerm_virtual_network.vpc3_resource
  ]
}


#### Create nic1 and vm1 ####
resource "azurerm_network_interface" "nic1_resource" {
  name                = "nic1"
  location            = azurerm_resource_group.rg_resource.location
  resource_group_name = azurerm_resource_group.rg_resource.name

  ip_configuration {
    name                          = "internal_1"
    subnet_id                     = azurerm_subnet.vnet1_subnet1_resource.id
    private_ip_address_allocation = "Dynamic"
  }

  depends_on = [
    azurerm_subnet.vnet1_subnet1_resource
  ]
}

resource "azurerm_virtual_machine" "vm1_resource" {
  name                  = "vm1"
  location            = azurerm_resource_group.rg_resource.location
  resource_group_name = azurerm_resource_group.rg_resource.name
  network_interface_ids = [azurerm_network_interface.nic1_resource.id]
  vm_size               = "Standard_B1ls"

  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true

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
    computer_name  = "host1"
    admin_username = "testadmin"
    admin_password = "testPassword!234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  
  depends_on = [
    azurerm_network_interface.nic1_resource
  ]
}

#### Create nic2 and vm2 ####
resource "azurerm_network_interface" "nic2_resource" {
  name                = "nic2"
  location            = azurerm_resource_group.rg_resource.location
  resource_group_name = azurerm_resource_group.rg_resource.name

  ip_configuration {
    name                          = "internal_2"
    subnet_id                     = azurerm_subnet.vnet2_subnet1_resource.id
    private_ip_address_allocation = "Dynamic"
  }

  depends_on = [
    azurerm_subnet.vnet2_subnet1_resource
  ]
}

resource "azurerm_virtual_machine" "vm2_resource" {
  name                  = "vm2"
  location            = azurerm_resource_group.rg_resource.location
  resource_group_name = azurerm_resource_group.rg_resource.name
  network_interface_ids = [azurerm_network_interface.nic2_resource.id]
  vm_size               = "Standard_B1ls"

  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true

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
    computer_name  = "host2"
    admin_username = "testadmin"
    admin_password = "testPassword!234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  
  depends_on = [
    azurerm_network_interface.nic2_resource
  ]
}

#### Create nic3 and vm3 ####
resource "azurerm_network_interface" "nic3_resource" {
  name                = "nic3"
  location            = azurerm_resource_group.rg_resource.location
  resource_group_name = azurerm_resource_group.rg_resource.name

  ip_configuration {
    name                          = "internal_3"
    subnet_id                     = azurerm_subnet.vnet3_subnet1_resource.id
    private_ip_address_allocation = "Dynamic"
  }

  depends_on = [
    azurerm_subnet.vnet3_subnet1_resource
  ]
}

resource "azurerm_virtual_machine" "vm3_resource" {
  name                  = "vm3"
  location            = azurerm_resource_group.rg_resource.location
  resource_group_name = azurerm_resource_group.rg_resource.name
  network_interface_ids = [azurerm_network_interface.nic3_resource.id]
  vm_size               = "Standard_B1ls"

  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk3"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
    disk_size_gb	  = "30"
  }
  os_profile {
    computer_name  = "host3"
    admin_username = "testadmin"
    admin_password = "testPassword!234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  
  depends_on = [
    azurerm_network_interface.nic3_resource
  ]
}
