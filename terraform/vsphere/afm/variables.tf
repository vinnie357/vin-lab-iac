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
  default = "synology_ssd"
}

variable vm_network_1 {
  description = "Network used for the vSphere virtual machines"
  default = "192.168.20.0/24_mgmt_vlan20"
}
variable vm_network_2 {
  description = "Network used for the vSphere virtual machines"
  default = "192.168.1.0"
}
variable vm_network_3 {
  description = "Network used for the vSphere virtual machines"
  default = "any"
}
variable vm_network_4 {
  description = "Network used for the vSphere virtual machines"
  default = "192.168.2.0"
}

variable vm_template {
  description = "Template used to create the vSphere virtual machines"
  #default = "BIGIP-14.1.2.1-0.0.4.ALL"
  default ="BIGIP-15.1.0-0.0.31"
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
  default = "4"
}

variable vm_ram {
  description = "Amount of RAM for the vSphere virtual machines (example: 2048)"
#   default = "16384"
    default = "6144"
}

variable vm_name {
  description = "The name of the vSphere virtual machines and the hostname of the machine"
  default = "afm"
}

variable vm_count {
  description = "The number of virtual machine instances"
  default = "1"
}

variable vm_ovf {
  description = "vmware ovf already on vcenter"
  #default = "BIGIP-14.1.2.1-0.0.4.ALL"
  default = "BIGIP-15.1.0-0.0.31"
}

variable vm_admin_password {
  description = "vm admin pass"
  default = ""
}

variable vm_root_password {
  description = "vm root pass"
  default = ""
}

variable vm_mgmt_gw {
  description = "vm mgmt gw"
  default = "192.168.20.254"
}

variable vm_mgmt_ip {
  description = "vm mgmt ip 192.168.10x will append machine number as last address number"
  default = "192.168.20.11"
}
variable dns_server_list {
    default = ["192.168.2.251","8.8.8.8"]
  
}


# bigip stuff

# afm-01
variable f5vm01_mgmt { default = "192.168.20.248" }
variable f5vm01_ext { default = "192.168.1.248" }

variable f5vm01_int { default = "192.168.2.248" }
variable f5vm01_server { default = "192.168.3.248" }
variable f5vm01_virtuals { default = "192.168.10.248" }
variable f5vm01_client { default = "192.168.30.248" }
# afm- 02

variable f5vm02_mgmt { default = "192.168.20.249" }
variable f5vm02_ext { default = "192.168.1.249" }

variable f5vm02_int { default = "192.168.2.249" }
variable f5vm02_server { default = "192.168.3.249" }
variable f5vm02_virtuals { default = "192.168.10.249" }
variable f5vm02_client { default = "192.168.30.249" }
# other

variable f5vm0ext_sec { default = "10.90.2.11" }
variable f5vm01int { default = "10.0.3.111"}
variable f5vm02mgmt { default = "10.0.10.4" }
variable f5vm02ext { default = "10.0.30.4" }
variable f5vm02ext_sec { default = "10.90.2.12" }
variable f5vm02int { default = "10.0.20.4"}
variable backend01ext { default = "10.0.20.101" }

variable adminAccountName { default = "xadmin" }
variable adminPass { 
    description = "bigip admin password"
    default = "2018F5Networks!!"
 }
variable license1 { default = "" }
variable license2 { default = "" }
variable host1_name { default = "afm-vm01" }
variable host2_name { default = "f5vm02" }
variable dns_server { default = "8.8.8.8" }
variable ntp_server { default = "0.us.pool.ntp.org" }
variable timezone { default = "EST" }
variable domain { default = "vin-lab.com" }

variable libs_dir { default = "/config/cloud/gcp/node_modules" }
variable onboard_log { default = "/var/log/startup-script.log" }

## Please check and update the latest DO URL from https://github.com/F5Networks/f5-declarative-onboarding/releases
variable DO_onboard_URL { default = "https://github.com/F5Networks/f5-declarative-onboarding/releases/download/v1.9.0/f5-declarative-onboarding-1.9.0-1.noarch.rpm" }
## Please check and update the latest AS3 URL from https://github.com/F5Networks/f5-appsvcs-extension/releases/latest 
variable AS3_URL { default = "https://github.com/F5Networks/f5-appsvcs-extension/releases/download/v3.16.0/f5-appsvcs-3.16.0-6.noarch.rpm" }