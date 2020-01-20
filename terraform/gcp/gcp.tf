# https://cloud.google.com/community/tutorials/getting-started-on-gcp-with-terraform
provider "google" {
  credentials = "${file("/creds/gcp/${var.GCP_SA_FILE}.json")}"
  project     = "${var.GCP_PROJECT_ID}"
  region      = "${var.GCP_REGION}"
  zone        = "${var.GCP_ZONE}"
}

# networks
# vpc
resource "google_compute_network" "vpc_network_mgmt" {
  name                    = "terraform-network-mgmt"
  auto_create_subnetworks = "false"
  routing_mode = "REGIONAL"
}
resource "google_compute_subnetwork" "vpc_network_mgmt_sub" {
  name          = "mgmt-sub"
  ip_cidr_range = "10.0.10.0/24"
  region        = "us-east1"
  network       = "${google_compute_network.vpc_network_mgmt.self_link}"

}
resource "google_compute_network" "vpc_network_int" {
  name                    = "terraform-network-int"
  auto_create_subnetworks = "false"
  routing_mode = "REGIONAL"
}
resource "google_compute_subnetwork" "vpc_network_int_sub" {
  name          = "int-sub"
  ip_cidr_range = "10.0.20.0/24"
  region        = "us-east1"
  network       = "${google_compute_network.vpc_network_int.self_link}"

}
resource "google_compute_network" "vpc_network_ext" {
  name                    = "terraform-network-ext"
  auto_create_subnetworks = "false"
  routing_mode = "REGIONAL"
}
resource "google_compute_subnetwork" "vpc_network_ext_sub" {
  name          = "ext-sub"
  ip_cidr_range = "10.0.30.0/24"
  region        = "us-east1"
  network       = "${google_compute_network.vpc_network_ext.self_link}"

}
resource "google_compute_firewall" "default-allow-internal-mgmt" {
  name    = "${var.projectPrefix}default-allow-internal-mgmt-firewall"
  network = "${google_compute_network.vpc_network_mgmt.name}"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }
  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }
  priority = "65534"

  source_ranges = ["10.0.10.0/24"]
}
resource "google_compute_firewall" "default-allow-internal-ext" {
  name    = "${var.projectPrefix}default-allow-internal-ext-firewall"
  network = "${google_compute_network.vpc_network_ext.name}"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }
  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }
  priority = "65534"

  source_ranges = ["10.0.30.0/24"]
}
resource "google_compute_firewall" "default-allow-internal-int" {
  name    = "${var.projectPrefix}default-allow-internal-int-firewall"
  network = "${google_compute_network.vpc_network_int.name}"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }
  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }
  priority = "65534"

  source_ranges = ["10.0.20.0/24"]
}

# }
# workloads

module "app" {
  source   = "./app"
  #====================#
  # app settings       #
  #====================#
  name = "${var.appName}"
  gce_ssh_pub_key_file = "${var.sshKeyPath}"
  adminAccountName = "${var.adminAccount}"
  int_vpc = "${google_compute_network.vpc_network_int}"
  int_subnet = "${google_compute_subnetwork.vpc_network_int_sub}"
  projectPrefix = "${var.projectPrefix}"
}

module "afm" {
  source   = "./afm"
  #====================#
  # afm settings       #
  #====================#
  gce_ssh_pub_key_file = "${var.sshKeyPath}"
  adminSrcAddr = "${var.adminSrcAddr}"
  adminPass = "${var.adminPass}"
  adminAccountName = "${var.adminAccount}"
  mgmt_vpc = "${google_compute_network.vpc_network_mgmt}"
  int_vpc = "${google_compute_network.vpc_network_int}"
  ext_vpc = "${google_compute_network.vpc_network_ext}"
  mgmt_subnet = "${google_compute_subnetwork.vpc_network_mgmt_sub}"
  int_subnet = "${google_compute_subnetwork.vpc_network_int_sub}"
  ext_subnet = "${google_compute_subnetwork.vpc_network_ext_sub}"
  projectPrefix = "${var.projectPrefix}"
  service_accounts = "${var.service_accounts}"
}

# module "ltm" {
#   source   = "./ltm"
#   #====================#
#   # ltm settings       #
#   #====================#
#   gce_ssh_pub_key_file = "${var.sshKeyPath}"
#   adminSrcAddr = "${var.adminSrcAddr}"
#   adminPass = "${var.adminPass}"
#   adminAccountName = "${var.adminAccount}"
#   mgmt_vpc = "${google_compute_network.vpc_network_mgmt}"
#   int_vpc = "${google_compute_network.vpc_network_int}"
#   ext_vpc = "${google_compute_network.vpc_network_ext}"
#   mgmt_subnet = "${google_compute_subnetwork.vpc_network_mgmt_sub}"
#   int_subnet = "${google_compute_subnetwork.vpc_network_int_sub}"
#   ext_subnet = "${google_compute_subnetwork.vpc_network_ext_sub}"
#   projectPrefix = "${var.projectPrefix}"
# }

output "f5vm01_mgmt_public_ip" {
  value = "${module.afm.f5vm01_mgmt_public_ip}"
}
output "f5vm02_mgmt_public_ip" {
  value = "${module.afm.f5vm02_mgmt_public_ip}"
}

output "f5vm01_app_public_ip" {
  value = "${module.afm.f5vm01_app_public_ip}"
}
output "f5vm02_app_public_ip" {
  value = "${module.afm.f5vm02_app_public_ip}"
}