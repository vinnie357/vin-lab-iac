
variable service_accounts {
  type = map
}
# networks
variable int_vpc {
  
}
variable ext_vpc {
  
}
variable mgmt_vpc {
  
}
variable mgmt_subnet {
  
}
variable int_subnet {
  
}
variable ext_subnet {
  
}



# device
variable projectPrefix {
  description = "prefix for resources"
}

variable name {
  description = "device name"
  default = "afm"
}

variable bigipImage {
 description = " bigip gce image name"
 #default = "projects/f5-7626-networks-public/global/images/f5-bigip-15-0-1-1-0-0-3-byol-all-modules-2boot-loc-191118"
 default = "projects/f5-7626-networks-public/global/images/f5-bigip-15-0-1-1-0-0-3-payg-best-1gbps-191118"
}

variable bigipMachineType {
    description = "bigip gce machine type/size"
    default = "n1-standard-4"
}

variable vm_count {
    description = " number of devices"
    default = 2
}

variable adminSrcAddr {
  description = "admin source range in CIDR"

}

variable gce_ssh_pub_key_file {
    description = "path to public key for ssh access"
    default = "/root/.ssh/key.pub"
}

# bigip stuff

variable f5vm01mgmt { default = "10.0.10.3" }
variable f5vm01ext { default = "10.0.30.3" }
variable f5vm01ext_sec { default = "10.90.2.11" }
variable f5vm01int { default = "10.0.20.3"}
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
variable host1_name { default = "f5vm01" }
variable host2_name { default = "f5vm02" }
variable dns_server { default = "8.8.8.8" }
variable ntp_server { default = "0.us.pool.ntp.org" }
variable timezone { default = "UTC" }

variable libs_dir { default = "/config/cloud/gcp/node_modules" }
variable onboard_log { default = "/var/log/startup-script.log" }

## Please check and update the latest DO URL from https://github.com/F5Networks/f5-declarative-onboarding/releases
variable DO_onboard_URL { default = "https://github.com/F5Networks/f5-declarative-onboarding/releases/download/v1.9.0/f5-declarative-onboarding-1.9.0-1.noarch.rpm" }
## Please check and update the latest AS3 URL from https://github.com/F5Networks/f5-appsvcs-extension/releases/latest 
variable AS3_URL { default = "https://github.com/F5Networks/f5-appsvcs-extension/releases/download/v3.16.0/f5-appsvcs-3.16.0-6.noarch.rpm" }