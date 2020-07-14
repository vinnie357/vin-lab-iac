#====================#
# vCenter connection #
#====================#

variable vsphere_datacenter {
  description = "vSphere datacenter"
}

variable vsphere_cluster {
  description = "vSphere cluster"
  default     = "BladeCenter"
}

variable vsphere_folder_env {
    description = "vsphere environment folder"
    default = "dev"
  
}

#=========================#
# vSphere virtual machine #
#=========================#

variable vm_tags_application {
  description = "application name tag"
}

variable vm_tags_environment {
  description = "environment name"
}


variable vm_datastore {
  description = "Datastore used for the vSphere virtual machines"
  default = "synology2_ssd"
}

variable vm_network {
  description = "Network used for the vSphere virtual machines"
  default = "192.168.3.0"
}

variable vm_template {
  description = "Template used to create the vSphere virtual machines"
#   default = "centos8"
  #default = "centos7"
  default = "ubuntu-18.04"
}

variable vm_linked_clone {
  description = "Use linked clone to create the vSphere virtual machine from the template (true/false). If you would like to use the linked clone feature, your template need to have one and only one snapshot"
  default = "false"
}

variable vm_ip {
  description = "Ip used for the vSphere virtual machine"
  default = ""
}

variable vm_netmask {
  description = "Netmask used for the vSphere virtual machine (example: 24)"
  default = "24"
}

variable vm_gateway {
  description = "Gateway for the vSphere virtual machine"
  default = "192.168.3.254"
}

variable vm_dns {
  description = "DNS for the vSphere virtual machine"
  default = "192.168.2.251"
}

variable vm_domain {
  description = "Domain for the vSphere virtual machine"
  default = "vin-lab.com"
}

variable vm_cpu {
  description = "Number of vCPU for the vSphere virtual machines"
  default = "2"
}

variable vm_ram {
  description = "Amount of RAM for the vSphere virtual machines (example: 2048)"
  default = "4096"
}

variable vm_name {
  description = "The name of the vSphere virtual machines and the hostname of the machine"
  default = "letsencrypt"
}

variable vm_count {
  description = "The number of virtual machine instances"
  default = "1"
}
