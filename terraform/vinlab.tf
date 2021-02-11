#===============================================================================
# Create lab infra
#===============================================================================



# Deploy vsphere Module
module vsphere {
  source = "./vsphere"
  # admin
  adminPubKey = var.adminPubKey
  adminPass   = var.adminPass
  # #====================#
  # # vCenter connection #
  # #====================#
  vsphere_password = var.vsphere_password
  #====================#
  # BIG-IP creds       #
  #====================#
  bigip_admin_password = var.bigip_admin_password
  bigip_root_password  = var.bigip_root_password
}

# # Deploy aws Module
# module aws {
#   source   = "./aws"
#   prefix   = var.prefix
#   location = var.location
#   cidr     = var.cidr
#   subnets  = var.subnets
# }

# Deploy Azure Module
// module azure {
//   source     = "./azure"
//   AllowedIPs = var.AllowedIPs
//   key_path   = var.key_path
// }

# Deploy GCP Module
// module gcp {
//   source = "./gcp"
//   #   AllowedIPs = var.AllowedIPs
//   #   key_path = var.key_path
//   GCP_SA_FILE      = var.GCP_SA_FILE
//   GCP_PROJECT_ID   = var.GCP_PROJECT_ID
//   sshKeyPath       = var.GCP_SSH_KEY_PATH
//   adminSrcAddr     = var.adminSrcAddr
//   adminAccount     = var.adminAccount
//   adminPass        = var.adminPass
//   projectPrefix    = var.projectPrefix
//   service_accounts = var.gcp_service_accounts
// }

# Deploy ansible test Module
module test {
  source = "./test"

}