#====================#
# vinlab             #
#====================#
variable "projectPrefix" {
  description = "prefix for resources"
  default     = "vinlab-"
}


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

variable "gcp_service_accounts" {
  type = map(any)
  default = {
    storage = "default-compute@developer.gserviceaccount.com"
    compute = "default-compute@developer.gserviceaccount.com"
  }
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
variable "adminPubKey" {
  description = "ssh public key for admin access"
}
## vault
variable "vaultToken" {
  description = "vault token for run"
}
variable "vaultPort" {
  description = "vault server port"
  default     = 443
}
variable "vaultHost" {
  description = "vault server host"
}
variable "vaultProtcol" {
  description = "HTTP service type"
  default     = "https"
}
variable "vaultUrl" {
  description = "vault url"
}