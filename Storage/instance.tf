provider "azurerm" {
  version = "2.11"
  features {}
}
resource "azurerm_resource_group" "main" {
  name     = "module-rg"
  location = "australiaeast"
}
module "storage_instance" {
    source = "./instances"
    storage_name ="modulestorage100"
    resource_group_name ="${azurerm_resource_group.main.name}"
    location= "${azurerm_resource_group.main.location}"
    account_kind = "StorageV2"
    account_tier ="Standard"
    account_replication_type = "LRS"

}