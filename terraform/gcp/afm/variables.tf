variable "name" {
  description = "device name"
  default = "afm"
}

variable "bigipImage" {
 description = " bigip gce image name"
 #default = "projects/f5-7626-networks-public/global/images/f5-bigip-15-0-1-1-0-0-3-byol-all-modules-2boot-loc-191118"
 default = "projects/f5-7626-networks-public/global/images/f5-bigip-15-0-1-1-0-0-3-payg-best-1gbps-191118"
}

variable "bigipMachineType" {
    description = "bigip gce machine type/size"
    default = "n1-standard-4"
}

variable "vm_count" {
    description = " number of devices"
    default = 1
}

variable "adminSrcAddr" {
  description = "admin source range in CIDR"

}

variable "gce_ssh_user" {
  description = "username for ssh key access"
  default = "admin"
  
}

variable "gce_ssh_pub_key_file" {
    description = "path to public key for ssh access"
    default = "/root/.ssh/key.pub"
}

# bigip stuff

# variable f5vm01mgmt { default = "10.0.10.3" }
# variable f5vm01ext { default = "10.0.30.3" }
# variable f5vm01ext_sec { default = "10.90.2.11" }
# variable f5vm01int { default = "10.0.20.3"}
# variable f5vm02mgmt { default = "10.90.1.5" }
# variable f5vm02ext { default = "10.90.2.5" }
# variable f5vm02ext_sec { default = "10.90.2.12" }
# variable f5vm02int { default = "10.90.3.5"}
# variable backend01ext { default = "10.90.2.101" }