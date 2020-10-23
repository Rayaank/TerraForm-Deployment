variable "prefix" {
  default = "tfvmex"
}

provider "azurerm" {
  version = "2.11"
  features {}
}
resource "azurerm_resource_group" "main" {
  name     = "${var.prefix}-RG"
  location = "australiaeast"
}

resource "azurerm_storage_account" "StorageAccount1" {
  name                     = "jkapadia"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "GRS"
}
resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}
resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}
resource "azurerm_public_ip" "pip" {
  count = 2
  name                = "${var.prefix}${count.index}-pip"
  resource_group_name = azurerm_resource_group.main.name
  location = azurerm_resource_group.main.location
  allocation_method = "Dynamic"
}
resource "azurerm_network_interface" "main" {
  count               = 2
  name                = "${var.prefix}${count.index}-nic"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
   
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = "${element(azurerm_public_ip.pip.*.id,count.index)}"
  }
}
resource "azurerm_virtual_machine" "vm" {
  count = 2
  name                  = "${var.prefix}${count.index}-vm"
  location              = azurerm_resource_group.main.location
  resource_group_name   = azurerm_resource_group.main.name
  network_interface_ids = [element(azurerm_network_interface.main.*.id,count.index)]
  vm_size               = "Standard_DS1_v2"

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
      version = "latest"
  }
  storage_os_disk {
    name              = "myosdisk${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  os_profile_windows_config {
    
  }
}