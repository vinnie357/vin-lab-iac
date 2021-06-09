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

variable "vm_linked_clone" {
  default = false
}
variable "vm_domain" {
  description = "Domain for the vSphere virtual machine"
  default     = "vin-lab.com"
}
variable "masterCount" {

}

variable "nodeCount" {

}
variable "vsphere_datacenter" {

}

variable "vsphere_folder_env" {}
variable "vm_tags_application" {}
variable "vm_tags_environment" {}

variable "vm_name" {}

variable "cniUrl" {
  default     = "https://docs.projectcalico.org/manifests/calico.yaml"
  description = <<EOD
  cni appplied to master
  default is calico
  EOD
}
variable "vaultUrl" {
  description = "URL for vault"
}
variable "vaultToken" {
  description = "token for vault"
}
variable "dnsServer" {
  description = "default server for nsupdate"
}
