variable "azure_rg_name" {
    type = "string"
}
variable "f5_username" {
  description = "user of the F5 admin that will be created"
  default = "xadmin"
}
variable "azure_region" {
  type = "string"
}

variable "subnet1_public_id" {
  type = "string"
}
variable "AllowedIPs" {
  type = list(string)
}

variable libs_dir { 
  default = "/config/cloud/azure/node_modules" 
}
variable onboard_log { 
  default = "/var/log/startup-script.log" 
}

variable "f5_ssh_publickey" {
  type = "string"
}
variable "owner" {
  type = "string"
}

##
## F5 variables related to the F5 BIG-IP deployment
##
variable "f5_instance_type" {
  description = "instance type for F5 VM to be deployed"
  default     = "Standard_DS4_v2"
}

variable "f5_version" {
    type = "string"
    default = "latest"
}

variable "f5_image_name" {
    type = "string"
    default = "f5-big-all-2slot-byol"
}

variable "f5_product_name" {
    type = "string"
    default = "f5-big-ip-byol"
}

variable AS3_URL { 
  type = "string"
}
variable DO_URL { 
  type = "string"
}

variable "templates" {
    description = "path to templates"
  
}