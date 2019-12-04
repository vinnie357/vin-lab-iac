#===============================================================================
# vSphere Provider
#===============================================================================
#https://github.com/terraform-providers/terraform-provider-vsphere/releases

provider "vsphere" {
  version        = "1.12.0"
  vsphere_server = "${var.vsphere_vcenter}"
  user           = "${var.vsphere_user}"
  password       = "${var.vsphere_password}"

  allow_unverified_ssl = "${var.vsphere_unverified_ssl}"
}
data "vsphere_datacenter" "dc" {
  name = "${var.vsphere_datacenter}"
}

resource "vsphere_folder" "dev" {
  path          = "dev"
  type          = "vm"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}
resource "vsphere_folder" "test" {
  path          = "test"
  type          = "vm"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

resource "vsphere_folder" "prod" {
  path          = "prod"
  type          = "vm"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}
# tags
resource "vsphere_tag_category" "Application" {
  name        = "Application"
  cardinality = "SINGLE"
  description = "Managed by Terraform"

  associable_types = [
    "VirtualMachine",
    "Datastore",
  ]
}
resource "vsphere_tag_category" "Environment" {
  name        = "Environment"
  cardinality = "SINGLE"
  description = "Managed by Terraform"

  associable_types = [
    "VirtualMachine",
    "Datastore",
  ]
}
resource "vsphere_tag" "dev" {
  name        = "${vsphere_folder.dev.path}"
  category_id = "${vsphere_tag_category.Environment.id}"
  description = "Managed by Terraform"
}
resource "vsphere_tag" "test" {
  name        = "${vsphere_folder.test.path}"
  category_id = "${vsphere_tag_category.Environment.id}"
  description = "Managed by Terraform"
}
resource "vsphere_tag" "prod" {
  name        = "${vsphere_folder.prod.path}"
  category_id = "${vsphere_tag_category.Environment.id}"
  description = "Managed by Terraform"
}


# Deploy Awx machine
module "awx" {
  source   = "./awx"
  #====================#
  # vCenter connection #
  #====================#
  vsphere_datacenter = "${var.vsphere_datacenter}"
  # vsphere_cluster = "${var.vsphere_cluster}"
  vsphere_folder_env = "${var.vsphere_folder_dev}"
  vm_tags_application = "${vsphere_tag_category.Application.id}"
  vm_tags_environment = "${vsphere_tag.dev.id}"
}

# Deploy nfs machine
module "nfs" {
  source   = "./nfs"
  #====================#
  # vCenter connection #
  #====================#
  vsphere_datacenter = "${var.vsphere_datacenter}"
  # vsphere_cluster = "${var.vsphere_cluster}"
  vsphere_folder_env = "${var.vsphere_folder_dev}"
  vm_tags_application = "${vsphere_tag_category.Application.id}"
  vm_tags_environment = "${vsphere_tag.dev.id}"
}

# Deploy k8s cluster
module "k8s" {
  source   = "./k8s"
  #====================#
  # vCenter connection #
  #====================#
  vsphere_datacenter = "${var.vsphere_datacenter}"
  # vsphere_cluster = "${var.vsphere_cluster}"
  vsphere_folder_env = "${var.vsphere_folder_dev}"
  vm_tags_application = "${vsphere_tag_category.Application.id}"
  vm_tags_environment = "${vsphere_tag.dev.id}"
}
# Deploy k8s cluster for kubespray
module "kubespray" {
  source   = "./kubespray"
  #====================#
  # vCenter connection #
  #====================#
  vsphere_datacenter = "${var.vsphere_datacenter}"
  # vsphere_cluster = "${var.vsphere_cluster}"
  vsphere_folder_env = "${var.vsphere_folder_dev}"
  vm_tags_application = "${vsphere_tag_category.Application.id}"
  vm_tags_environment = "${vsphere_tag.dev.id}"
}
# Deploy legacy machine
module "legacy" {
  source   = "./legacy"
  #====================#
  # vCenter connection #
  #====================#
  vsphere_datacenter = "${var.vsphere_datacenter}"
  # vsphere_cluster = "${var.vsphere_cluster}"
  vsphere_folder_env = "${var.vsphere_folder_dev}"
  vm_tags_application = "${vsphere_tag_category.Application.id}"
  vm_tags_environment = "${vsphere_tag.dev.id}"
}
# Deploy nginx controller
module "controller" {
  source   = "./controller"
  #====================#
  # vCenter connection #
  #====================#
  vsphere_datacenter = "${var.vsphere_datacenter}"
  # vsphere_cluster = "${var.vsphere_cluster}"
  vsphere_folder_env = "${var.vsphere_folder_dev}"
  vm_tags_application = "${vsphere_tag_category.Application.id}"
  vm_tags_environment = "${vsphere_tag.dev.id}"
}
# Deploy afm cluster
module "afm" {
  source   = "./afm"
  #====================#
  # vCenter connection #
  #====================#
  vsphere_datacenter = "${var.vsphere_datacenter}"
  # vsphere_cluster = "${var.vsphere_cluster}"
  vsphere_folder_env = "${var.vsphere_folder_dev}"
  vm_tags_application = "${vsphere_tag_category.Application.id}"
  vm_tags_environment = "${vsphere_tag.dev.id}"
  vm_admin_password = "${var.bigip_admin_password}"
  vm_root_password = "${var.bigip_root_password}"
}

# Deploy asm cluster
module "asm" {
  source   = "./asm"
  #====================#
  # vCenter connection #
  #====================#
  vsphere_datacenter = "${var.vsphere_datacenter}"
  # vsphere_cluster = "${var.vsphere_cluster}"
  vsphere_folder_env = "${var.vsphere_folder_dev}"
  vm_tags_application = "${vsphere_tag_category.Application.id}"
  vm_tags_environment = "${vsphere_tag.dev.id}"
}