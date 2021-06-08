# k8s cluster using ubuntu and containerd
# requires ubuntu20 module

data "vsphere_datacenter" "dc" {
  name = var.vsphere_datacenter
}

resource "vsphere_folder" "folder" {
  path          = "${var.vsphere_folder_env}/${var.vm_name}"
  type          = "vm"
  datacenter_id = data.vsphere_datacenter.dc.id
}
resource "vsphere_folder" "folder_masters" {
  depends_on    = [vsphere_folder.folder]
  path          = "${var.vsphere_folder_env}/${var.vm_name}/masters"
  type          = "vm"
  datacenter_id = data.vsphere_datacenter.dc.id
}
resource "vsphere_folder" "folder_nodes" {
  depends_on    = [vsphere_folder.folder]
  path          = "${var.vsphere_folder_env}/${var.vm_name}/nodes"
  type          = "vm"
  datacenter_id = data.vsphere_datacenter.dc.id
}

# master
data "template_file" "masterMetaData" {
  count    = var.masterCount
  template = file("${path.module}/templates/master/metadata.yml.tpl")
  vars = {
    HOST = format("%s-master-%s-%s", var.vm_name, (count.index), var.vsphere_folder_env)
  }
}
data "template_file" "masterUserData" {
  count    = var.masterCount
  template = file("${path.module}/templates/master/userdata.yml.tpl")
  vars = {
    HOST      = format("%s-master-%s-%s", var.vm_name, (count.index), var.vsphere_folder_env)
    podCidr   = var.podCidr
    dnsDomain = var.vm_domain
    cniUrl    = var.cniUrl
    vaultUrl  = var.vaultUrl
    vaultToken = var.vaultToken
  }
}

module "masters" {
  count               = var.masterCount
  source              = "../ubuntu20"
  adminUser           = var.adminUser
  adminPass           = var.adminPass
  adminPubKey         = var.adminPubKey
  customMetaData      = data.template_file.masterMetaData[count.index].rendered
  customUserData      = data.template_file.masterUserData[count.index].rendered
  vsphere_datacenter  = var.vsphere_datacenter
  vm_tags_environment = var.vm_tags_environment
  vm_tags_application = var.vm_tags_application
  vm_linked_clone     = var.vm_linked_clone
  vm_name             = format("%s-master-%s-%s.%s", var.vm_name, count.index, var.vsphere_folder_env, var.vm_domain)
  vsphere_folder      = vsphere_folder.folder_masters.path
}

# nodes
data "template_file" "nodeMetaData" {
  count    = var.nodeCount
  template = file("${path.module}/templates/nodes/metadata.yml.tpl")
  vars = {
    HOST = format("%s-node-%s-%s", var.vm_name, (count.index), var.vsphere_folder_env)
  }
}
data "template_file" "nodeUserData" {
  count    = var.nodeCount
  template = file("${path.module}/templates/nodes/userdata.yml.tpl")
  vars = {
    HOST      = format("%s-node-%s-%s", var.vm_name, (count.index), var.vsphere_folder_env)
    dnsDomain = var.vm_domain
    vaultUrl  = var.vaultUrl
    vaultToken = var.vaultToken
  }
}

module "nodes" {
  count               = var.nodeCount
  source              = "../ubuntu20"
  adminUser           = var.adminUser
  adminPass           = var.adminPass
  adminPubKey         = var.adminPubKey
  customMetaData      = data.template_file.nodeMetaData[count.index].rendered
  customUserData      = data.template_file.nodeUserData[count.index].rendered
  vsphere_datacenter  = var.vsphere_datacenter
  vm_tags_environment = var.vm_tags_environment
  vm_tags_application = var.vm_tags_application
  vm_linked_clone     = var.vm_linked_clone
  vm_name             = format("%s-node-%s-%s.%s", var.vm_name, count.index, var.vsphere_folder_env, var.vm_domain)
  vsphere_folder      = vsphere_folder.folder_nodes.path
}
