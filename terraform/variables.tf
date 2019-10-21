#====================#
# vCenter connection #
#====================#

variable "vsphere_password" {
  description = "vSphere password"
}

variable "bigip_admin_password" {
  description = "bigip web gui password"
}

variable "bigip_root_password" {
  description = "bigip ssh password"
}
