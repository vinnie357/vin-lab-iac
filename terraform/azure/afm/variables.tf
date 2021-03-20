variable "azure_rg_name" {

}
variable "f5_username" {
  description = "user of the F5 admin that will be created"
  default     = "xadmin"
}
variable "azure_region" {

}

variable "subnet1_public_id" {

}
variable "AllowedIPs" {
  type = list(string)
}

variable "libs_dir" {
  default = "/config/cloud/azure/node_modules"
}
variable "onboard_log" {
  default = "/var/log/startup-script.log"
}

variable "f5_ssh_publickey" {

}
variable "owner" {

}

##
## F5 variables related to the F5 BIG-IP deployment
##
variable "f5_instance_type" {
  description = "instance type for F5 VM to be deployed"
  default     = "Standard_DS4_v2"
}

variable "f5_version" {
  default = "latest"
}

variable "f5_image_name" {
  default = "f5-big-all-2slot-byol"
}

variable "f5_product_name" {
  default = "f5-big-ip-byol"
}

variable "AS3_URL" {

}
variable "DO_URL" {

}

variable "templates" {
  description = "path to templates"

}
