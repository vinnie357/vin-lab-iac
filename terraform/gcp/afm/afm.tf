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

# Obtain Gateway IP for each Subnet
locals {
  depends_on = ["google_compute_network.vpc_network_mgmt", "google_compute_network.vpc_network_mgmt_ext","google_compute_network.vpc_network_mgmt_int"]
  mgmt_gw    = "${google_compute_subnetwork.vpc_network_mgmt_sub.gateway_address}"
  ext_gw     = "${google_compute_subnetwork.vpc_network_ext_sub.gateway_address}"
  int_gw     = "${google_compute_subnetwork.vpc_network_int_sub.gateway_address}"
}
# firewall
resource "google_compute_firewall" "mgmt" {
  name    = "mgmt-firewall"
  network = "${google_compute_network.vpc_network_mgmt.name}"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = [ "22", "443"]
  }

  source_ranges = ["${var.adminSrcAddr}"]
}
resource "google_compute_firewall" "app" {
  name    = "app-firewall"
  network = "${google_compute_network.vpc_network_ext.name}"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["${var.adminSrcAddr}"]
}
# Setup Onboarding scripts
data "template_file" "vm_onboard" {
  template = "${file("${path.module}/templates/onboard.tpl")}"

  vars = {
    uname        	      = "${var.adminAccountName}"
    upassword        	  = "${var.adminPass}"
    DO_onboard_URL      = "${var.DO_onboard_URL}"
    AS3_URL		          = "${var.AS3_URL}"
    libs_dir		        = "${var.libs_dir}"
    onboard_log		      = "${var.onboard_log}"
    DO1_Document        = "${data.template_file.vm01_do_json.rendered}"
    DO2_Document        = "${data.template_file.vm02_do_json.rendered}"
    AS3_Document        = "${data.template_file.as3_json.rendered}"
  }
}
#Declarative Onboarding template 01
data "template_file" "vm01_do_json" {
  template = "${file("${path.module}/templates/cluster.json")}"

  vars = {
    #Uncomment the following line for BYOL
    #local_sku	    = "${var.license1}"

    host1	    = "${var.host1_name}"
    host2	    = "${var.host2_name}"
    local_host      = "${var.host1_name}"
    local_selfip    = "${var.f5vm01ext}"
    remote_host	    = "${var.host2_name}"
    remote_selfip   = "${var.f5vm02ext}"
    gateway	        = "${local.ext_gw}"
    dns_server	    = "${var.dns_server}"
    ntp_server	    = "${var.ntp_server}"
    timezone	    = "${var.timezone}"
    admin_user      = "${var.adminAccountName}"
    admin_password  = "${var.adminPass}"
  }
}
#Declarative Onboarding template 02
data "template_file" "vm02_do_json" {
  template = "${file("${path.module}/templates/cluster.json")}"

  vars = {
    #Uncomment the following line for BYOL
    #local_sku      = "${var.license2}"

    host1           = "${var.host1_name}"
    host2           = "${var.host2_name}"
    local_host      = "${var.host2_name}"
    local_selfip    = "${var.f5vm02ext}"
    remote_host     = "${var.host1_name}"
    remote_selfip   = "${var.f5vm01ext}"
    gateway         = "${local.ext_gw}"
    dns_server      = "${var.dns_server}"
    ntp_server      = "${var.ntp_server}"
    timezone        = "${var.timezone}"
    admin_user      = "${var.adminAccountName}"
    admin_password  = "${var.adminPass}"
  }
}
# as3 uuid generation
resource "random_uuid" "as3_uuid" { }

#application services 3 template
data "template_file" "as3_json" {
  template = "${file("${path.module}/templates/scca.json")}"
  vars ={
      uuid = "${random_uuid.as3_uuid.result}"
  }
}


# bigips
resource "google_compute_instance" "vm_instance" {
  count            = "${var.vm_count}"
  name             = "${var.name}-${count.index + 1}-instance"
  machine_type = "${var.bigipMachineType}"

  boot_disk {
    initialize_params {
      image = "${var.bigipImage}"
    }
  }
  metadata = {
    ssh-keys = "${var.gce_ssh_user}:${file(var.gce_ssh_pub_key_file)}"
    block-project-ssh-keys = true
    startup-script = "${data.template_file.vm_onboard.rendered}"
    #metadata_startup_script = "deviceId=${count.index + 1}\n ${data.template_file.vm_onboard.rendered}"
    deviceId = "${count.index + 1}"
 }

  network_interface {
    # mgmt
    # A default network is created for all GCP projects
    network       = "${google_compute_network.vpc_network_mgmt.name}"
    subnetwork = "${google_compute_subnetwork.vpc_network_mgmt_sub.name}"
    # network = "${google_compute_network.vpc_network.self_link}"
    access_config {
    }
  }
    network_interface {
    # external
    # A default network is created for all GCP projects
    network       = "${google_compute_network.vpc_network_ext.name}"
    subnetwork = "${google_compute_subnetwork.vpc_network_ext_sub.name}"
    # network = "${google_compute_network.vpc_network.self_link}"
    access_config {
    }
  }
    network_interface {
    # internal
    # A default network is created for all GCP projects
    network       = "${google_compute_network.vpc_network_int.name}"
    subnetwork = "${google_compute_subnetwork.vpc_network_int_sub.name}"
    # network = "${google_compute_network.vpc_network.self_link}"
    # access_config {
    # }
  }
}
# gcloud compute instances describe afm-1-instance --format='get(networkInterfaces[0].accessConfigs[0].natIP)'

#output "f5vm01_mgmt_public_ip" { value = "${google_compute_instance.afm-1-instance.access_config[0].natIP}" }
