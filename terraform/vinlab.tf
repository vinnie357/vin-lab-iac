#===============================================================================
# Create lab infra
#===============================================================================



# Deploy vsphere Module
module "vsphere" {
  source   = "./vsphere"
  # #====================#
  # # vCenter connection #
  # #====================#
  vsphere_password = "${var.vsphere_password}"
  #====================#
  # BIG-IP creds       #
  #====================#
  bigip_admin_password ="${var.bigip_admin_password}"
  bigip_root_password ="${var.bigip_root_password}"
}

# # Deploy aws Module
# module "aws" {
#   source   = "./aws"
#   prefix   = "${var.prefix}"
#   location = "${var.location}"
#   cidr     = "${var.cidr}"
#   subnets  = "${var.subnets}"
# }

# # Deploy azure Module
# module "azure" {
#   source   = "./azure"
#   prefix   = "${var.prefix}"
#   location = "${var.location}"
#   cidr     = "${var.cidr}"
#   subnets  = "${var.subnets}"
# }