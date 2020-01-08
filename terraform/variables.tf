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

#====================#
# Azure connection   #
#====================#

variable "owner" {}

variable "project_name" {}

variable "azure_region" {}

variable "AllowedIPs" {}

variable "key_path" {}

variable "azure_az1" {}

variable "azure_az2" {}

#====================#
# GCP   connection   #
#====================#
variable "GCP_SA_FILE" {
  description = "creds file name"
}

variable "GCP_PROJECT_ID" {
  description = "project ID"
}

variable "GCP_SSH_KEY_PATH" {
    description = " path to ssh public key for vms"
  
}

#====================#
# admin   connection #
#====================#

variable "adminSrcAddr" {
  description = "admin source range in CIDR x.x.x.x/24"
}

variable "adminAccount" {
  description = "admin account name"
}
variable "adminPass" {
  description = "admin account password"
}
