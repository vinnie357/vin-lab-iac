variable "GCP_SA_FILE" {
  description = "creds file name"
}

variable "GCP_PROJECT_ID" {
  description = "project ID"
}

variable "GCP_REGION" {
  description = "region"
  default = "us-east1"
}
variable "GCP_ZONE" {
  description = "zone"
  default = "us-east1-b"
}

variable "appName" {
  description = "app name"
  default = "app1"
}

variable "prefix" {
  description = "prefix for object names"
  default = "afm"
}

# creds
variable "sshKeyPath" {
    description = "path to public key for ssh access"
    default = "/root/.ssh/key.pub"
}

variable "adminSrcAddr" {
  description = "admin source range in CIDR x.x.x.x/24"
}

variable "gce_ssh_user" {
  description = "username for ssh key access"
  default = "admin"
  
}