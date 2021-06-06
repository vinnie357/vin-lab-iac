# new cluster with contianerd and ubuntu

module "k8s_ubuntu" {
  source              = "../modules/k8s_ubuntu"
  masterCount         = var.masterCount
  nodeCount           = var.nodeCount
  vsphere_datacenter  = var.vsphere_datacenter
  vsphere_folder_env  = var.vsphere_folder_env
  vm_tags_application = var.vm_tags_application
  vm_tags_environment = var.vm_tags_environment
  adminPubKey         = var.adminPubKey
  adminPass           = var.adminPass
  adminUser           = var.adminUser
  vm_name             = var.vm_name
  vm_domain           = var.vm_domain
}
