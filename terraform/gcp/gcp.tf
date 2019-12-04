provider "google" {
  credentials = "${file("/creds/gcp/${var.GCP_SA_FILE}.json")}"
  project     = "${var.GCP_PROJECT_ID}"
  region      = "${var.GCP_REGION}"
  zone        = "${var.GCP_ZONE}"
}


module "app" {
  source   = "./app"
  #====================#
  # app settings       #
  #====================#
  name = "${var.appName}"  
}
