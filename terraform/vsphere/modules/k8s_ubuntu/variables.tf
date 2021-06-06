## admin
variable "adminUser" {
  description = "default admin account"
}
variable "adminPass" {
  description = "default admin pass"
}
variable "adminPubKey" {
  description = "admin public ssh key"
}
variable "vm_domain" {
  description = "Domain for the vSphere virtual machine"
}
variable "vsphere_datacenter" {
  description = "vsphere datacenter name"
}
variable "vsphere_folder_env" {
  description = "deployment environment"
}
variable "vm_tags_application" {

}
variable "vm_tags_environment" {

}
variable "vm_linked_clone" {
  default = false
}
variable "masterCount" {
  default     = 1
  description = "number of control nodes to create"
}
variable "nodeCount" {
  default     = 3
  description = "number of worker nodes to create"
}
variable "vm_name" {
  default     = "k8svm"
  description = "name for vms created"
}
variable "podCidr" {
  default = "10.10.0.0/16"
}
