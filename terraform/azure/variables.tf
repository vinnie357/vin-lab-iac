variable azure_rg_cidr {
    description = "Azure Ressource Group CIDR"
    default = "10.10.0.0/16"
}

variable public_subnet1_cidr {
  description = "First public subnet IP range"
  default = "10.10.10.0/24"
}

variable public_subnet2_cidr {
  description = "2nd public subnet IP range"
  default = "10.10.11.0/24"
}

variable private_subnet1_cidr {
  description = "2nd public subnet IP range"
  default = "10.10.20.0/24"
}

variable private_subnet2_cidr {
  description = "2nd public subnet IP range"
  default = "10.10.21.0/24"
}
##
##  
## List of regions : francecentral, westeurope, westus2
## Can get the list of region with the command: az account list-locations
##
variable azure_region {
  default= "eastus"
}

variable owner {
  default = "mazza"
}

variable project_name {
    default = "vin-lab"
}

variable key_path {}

# public addresses that can reach instances
variable AllowedIPs {}

## Please check and update the latest DO URL from https://github.com/F5Networks/f5-declarative-onboarding/releases
variable DO_URL {
  default = "https://github.com/nmenant/Public-Cloud-Templates/raw/master/tools/f5-declarative-onboarding-1.4.0-1.noarch.rpm"
}

## Please check and update the latest AS3 URL from https://github.com/F5Networks/f5-appsvcs-extension/releases/latest 
variable AS3_URL {
  default = "https://github.com/F5Networks/f5-appsvcs-extension/releases/download/v3.12.0/f5-appsvcs-3.12.0-5.noarch.rpm"
}