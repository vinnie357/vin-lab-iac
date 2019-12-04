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