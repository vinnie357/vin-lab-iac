###################
# Azure resources #
###################
provider "azurerm" {
}

resource "azurerm_resource_group" "azure_rg" {
  name = "${var.owner}-${var.project_name}-RG"
  location = "${var.azure_region}"
  tags = {
    environment = "${var.owner}"
  }
}

resource "azurerm_virtual_network" "azurerm_virtualnet" {
    name                = "${var.owner}-${var.project_name}-VNet"
    address_space       = ["${var.azure_rg_cidr}"]
    location            = "${var.azure_region}"
    resource_group_name = "${azurerm_resource_group.azure_rg.name}"

    tags = {
        environment = "Terraform Demo"
    }
}

resource "azurerm_subnet" "azurerm_publicsubnet1" {
    name                 = "${var.owner}-${var.project_name}-publicsubnet1"
    resource_group_name  = "${azurerm_resource_group.azure_rg.name}"
    virtual_network_name = "${azurerm_virtual_network.azurerm_virtualnet.name}"
    address_prefix       = "${var.public_subnet1_cidr}"
}

resource "azurerm_subnet" "azurerm_privatesubnet1" {
    name                 = "${var.owner}-${var.project_name}-privatesubnet1"
    resource_group_name  = "${azurerm_resource_group.azure_rg.name}"
    virtual_network_name = "${azurerm_virtual_network.azurerm_virtualnet.name}"
    address_prefix       = "${var.private_subnet1_cidr}"
}

# templates
resource "template_dir" "bigip" {
  source_dir      = "${path.module}/templates"
  destination_dir = "${path.cwd}/templates"
}

# Deploy afm cluster
module "afm" {
  source   = "./afm"
  DO_URL = "${var.DO_URL}"
  AS3_URL = "${var.AS3_URL}"
  azure_rg_name = "${azurerm_resource_group.azure_rg.name}"
  f5_ssh_publickey = "${var.key_path}"
  AllowedIPs = "${var.AllowedIPs}"
  azure_region ="${var.azure_region}"
  subnet1_public_id = "${azurerm_subnet.azurerm_publicsubnet1.id}"
  owner = "${var.owner}"
  templates = "${template_dir.bigip.source_dir}"
}

