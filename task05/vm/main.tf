#### Create resource group ####
resource "azurerm_resource_group" "rg1_resource" {
  name     = "task5"
  location = "West Europe"
}

#### Create storage account ####
resource "azurerm_storage_account" "st1_resource" {
  name                     = "st05task05"
  resource_group_name      = azurerm_resource_group.rg1_resource.name
  location                 = azurerm_resource_group.rg1_resource.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
  
  depends_on = [
    azurerm_resource_group.rg1_resource
  ]
}

#### Create security groups ####
resource "azurerm_network_security_group" "nsg1_resource" {
  name                	   = "nsg1"
  resource_group_name      = azurerm_resource_group.rg1_resource.name
  location                 = azurerm_resource_group.rg1_resource.location

  security_rule {
    name                       = "in_web"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = [22, 80, 443] 
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "Production"
  }
  
  depends_on = [
    azurerm_resource_group.rg1_resource
  ]
}

resource "azurerm_network_security_group" "nsg2_resource" {
  name                	   = "nsg2"
  resource_group_name      = azurerm_resource_group.rg1_resource.name
  location                 = azurerm_resource_group.rg1_resource.location

  security_rule {
    name                       = "in_db"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = [3306] 
    source_address_prefix      = "10.5.0.0/16"
    destination_address_prefix = "10.5.0.0/16"
  }

  tags = {
    environment = "Production"
  }
  
  depends_on = [
    azurerm_resource_group.rg1_resource
  ]
}

#### Create VPC ####
resource "azurerm_virtual_network" "vpc1_resource" {
  name                = "vpc1"
  location            = azurerm_resource_group.rg1_resource.location
  resource_group_name = azurerm_resource_group.rg1_resource.name
  address_space       = ["10.5.0.0/16"]

  tags = {
    environment = "Production"
  }
  
  depends_on = [
    azurerm_resource_group.rg1_resource
  ]
}

#### Create subnet1 ####
resource "azurerm_subnet" "subnet1_resource" {
  name                 = "subnet1"
  resource_group_name  = azurerm_resource_group.rg1_resource.name
  virtual_network_name = azurerm_virtual_network.vpc1_resource.name
  address_prefixes     = ["10.5.1.0/24"]

  depends_on = [
    azurerm_virtual_network.vpc1_resource,
    azurerm_resource_group.rg1_resource
  ]
}

resource "azurerm_subnet_network_security_group_association" "subnet1_nsg1_resource" {
  subnet_id                 = azurerm_subnet.subnet1_resource.id
  network_security_group_id = azurerm_network_security_group.nsg1_resource.id
  
  depends_on = [
    azurerm_subnet.subnet1_resource,
    azurerm_network_security_group.nsg1_resource
  ]
}

#### Create subnet2 ####
resource "azurerm_subnet" "subnet2_resource" {
  name                 = "subnet2"
  resource_group_name  = azurerm_resource_group.rg1_resource.name
  virtual_network_name = azurerm_virtual_network.vpc1_resource.name
  address_prefixes     = ["10.5.2.0/24"]

  depends_on = [
    azurerm_virtual_network.vpc1_resource,
    azurerm_resource_group.rg1_resource
  ]
}

resource "azurerm_subnet_network_security_group_association" "subnet2_nsg2_resource" {
  subnet_id                 = azurerm_subnet.subnet2_resource.id
  network_security_group_id = azurerm_network_security_group.nsg2_resource.id
  
  depends_on = [
    azurerm_subnet.subnet2_resource,
    azurerm_network_security_group.nsg2_resource
  ]
}

#### Create public IP ####
resource "azurerm_public_ip" "publicip1_resource" {
  name                = "publicip1"
  location            = azurerm_resource_group.rg1_resource.location
  resource_group_name = azurerm_resource_group.rg1_resource.name
  allocation_method   = "Static"
  sku				  = "Basic"
  sku_tier			  = "Regional"
  ip_version		  = "IPv4"

  tags = {
    environment = "Production"
  }
  
  depends_on = [
    azurerm_resource_group.rg1_resource
  ]
}

#### Create nic1 ####
resource "azurerm_network_interface" "nic1_resource" {
  name                = "nic1"
  location            = azurerm_resource_group.rg1_resource.location
  resource_group_name = azurerm_resource_group.rg1_resource.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet1_resource.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id		  = azurerm_public_ip.publicip1_resource.id
  }

  depends_on = [
    azurerm_subnet.subnet1_resource,
    azurerm_public_ip.publicip1_resource
  ]
}

#### Create VM ####
resource "azurerm_virtual_machine" "vm1_resource" {
  name                  = "vm5"
  location            = azurerm_resource_group.rg1_resource.location
  resource_group_name = azurerm_resource_group.rg1_resource.name
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
    computer_name  = "hostname5"
    admin_username = "testadmin"
    admin_password = "testPassword!234!"
    custom_data	   = filebase64("custom-data.txt")
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "staging"
  }
  
  depends_on = [
    azurerm_network_interface.nic1_resource
  ]
}
