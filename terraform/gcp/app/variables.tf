variable "name" {
  description = "app name"
  default     = "app"
}

variable "appPort" {
  description = "app exposed port"
  default     = "80"
}

variable "adminAccountName" {
  description = "username for ssh key access"
  default     = "xadmin"

}

variable "gce_ssh_pub_key_file" {
  description = "path to public key for ssh access"
  default     = "/root/.ssh/key.pub"
}

variable "int_vpc" {

}
variable "int_subnet" {

}

variable "projectPrefix" {
  description = "prefix for resources"
}
