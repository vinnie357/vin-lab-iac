#====================#
# vCenter connection #
#====================#

variable "vsphere_user" {
  description = "vSphere user name"
  default     = "svc-terraform@vinlab.com"
}

variable "vsphere_password" {
  description = "vSphere password"
}

variable "vsphere_vcenter" {
  description = "vCenter server FQDN or IP"
  default     = "192.168.3.10"
}

variable "vsphere_unverified_ssl" {
  description = "Is the vCenter using a self signed certificate (true/false)"
  default     = "true"
}

variable "vsphere_datacenter" {
  description = "vSphere datacenter"
  default     = "vin-lab.com"
}

# variable vsphere_cluster {
#   description = "vSphere cluster"
#   default     = "BladeCenter"
# }

variable "vsphere_folder_dev" {
  description = "vSphere folder dev"
  default     = "dev"
}

variable "vsphere_folder_test" {
  description = "vSphere folder test"
  default     = "test"
}

variable "vsphere_folder_prod" {
  description = "vSphere folder prod"
  default     = "prod"
}

#====================#
# BIG-IP creds       #
#====================#

variable "bigip_admin_password" {
  description = "bigip web gui password"
}

variable "bigip_root_password" {
  description = "bigip ssh password"
}

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
variable "dnsServer" {
  description = "default server for nsupdate"
  default     = "ad.vin-lab.com"
}
