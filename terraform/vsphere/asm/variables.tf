#====================#
# vCenter connection #
#====================#

variable "vsphere_datacenter" {
  description = "vSphere datacenter"
}

variable "vsphere_cluster" {
  description = "vSphere cluster"
  default     = "BladeCenter"
}

variable "vsphere_folder_env" {
  description = "vsphere environment folder"
  default     = "dev"

}
#=========================#
# vSphere virtual machine #
#=========================#
variable "vm_tags_application" {
  description = "application name tag"
}

variable "vm_tags_environment" {
  description = "environment name"
}
variable "vm_datastore" {
  description = "Datastore used for the vSphere virtual machines"
  default     = "synology_ssd"
}

variable "vm_network_1" {
  description = "Network used for the vSphere virtual machines"
  #   default = "192.168.20.0/24_mgmt_vlan20"
  default = "192.168.20.0/24_mgmt_vlan20"
}
variable "vm_network_2" {
  description = "Network used for the vSphere virtual machines"
  default     = "192.168.3.0"
}
variable "vm_network_3" {
  description = "Network used for the vSphere virtual machines"
  default     = "192.168.2.0"
}
variable "vm_network_4" {
  description = "Network used for the vSphere virtual machines"
  default     = "192.168.40.0/24_f5_ha_vlan40"
}

variable "vm_template" {
  description = "Template used to create the vSphere virtual machines"
  #   default = "BIGIP-14.1.2.1-0.0.4.ALL"
  default = "BIGIP-15.1.0-0.0.31"
}

variable "vm_linked_clone" {
  description = "Use linked clone to create the vSphere virtual machine from the template (true/false). If you would like to use the linked clone feature, your template need to have one and only one snapshot"
  default     = "false"
}

variable "vm_ip" {
  description = "Ip used for the vSphere virtual machine"
  default     = ""
}

variable "vm_netmask" {
  description = "Netmask used for the vSphere virtual machine (example: 24)"
  default     = "24"
}

variable "vm_gateway" {
  description = "Gateway for the vSphere virtual machine"
  default     = "192.168.3.254"
}

variable "vm_dns" {
  description = "DNS for the vSphere virtual machine"
  default     = "192.168.2.251"
}

variable "vm_domain" {
  description = "Domain for the vSphere virtual machine"
  default     = "vin-lab.com"
}

variable "vm_cpu" {
  description = "Number of vCPU for the vSphere virtual machines"
  default     = "4"
}

variable "vm_ram" {
  description = "Amount of RAM for the vSphere virtual machines (example: 2048)"
  default     = "16384"
}

variable "vm_name" {
  description = "The name of the vSphere virtual machines and the hostname of the machine"
  default     = "asm"
}

variable "vm_count" {
  description = "The number of virtual machine instances"
  default     = "1"
}

variable "vm_ovf" {
  description = "vmware ovf already on vcenter"
  #   default = "BIGIP-14.1.2.1-0.0.4.ALL"
  default = "BIGIP-15.1.0-0.0.31"
}

variable "vm_admin_password" {
  description = "vm admin pass"
  default     = "teraawhat123!"
}

variable "vm_root_password" {
  description = "vm root pass"
  default     = "teraawhat123!"
}

variable "vm_mgmt_gw" {
  description = "vm mgmt gw"
  default     = "192.168.20.254"
}

variable "vm_mgmt_ip" {
  description = "vm mgmt ip 192.168.10x will append machine number as last address number"
  default     = "192.168.20.12"
}
