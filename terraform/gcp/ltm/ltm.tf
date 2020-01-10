
# Obtain Gateway IP for each Subnet
locals {
  depends_on = ["google_compute_network.vpc_network_mgmt", "google_compute_network.vpc_network_mgmt_ext","google_compute_network.vpc_network_mgmt_int"]
  mgmt_gw    = "${var.mgmt_subnet.gateway_address}"
  ext_gw     = "${var.ext_subnet.gateway_address}"
  int_gw     = "${var.int_subnet.gateway_address}"
}
# firewall
resource "google_compute_firewall" "ltm-mgmt" {
  name    = "${var.projectPrefix}ltm-mgmt-firewall"
  network = "${var.mgmt_vpc.name}"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = [ "22", "443"]
  }

  source_ranges = ["${var.adminSrcAddr}"]
}
resource "google_compute_firewall" "ltm-app" {
  name    = "${var.projectPrefix}ltm-app-firewall"
  network = "${var.ext_vpc.name}"

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
  template = "${file("${path.module}/templates/standalone.json")}"

  vars = {
    #Uncomment the following line for BYOL
    #local_sku	    = "${var.license1}"

    host1	    = "${var.host1_name}"
    host2	    = "${var.host2_name}"
    local_host      = "${var.host1_name}"
    local_ext_selfip = "${var.f5vm01ext}"
    local_int_selfip = "${var.f5vm01int}"
    remote_host	    = "${var.host2_name}"
    remote_selfip   = "${var.f5vm02int}"
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
  template = "${file("${path.module}/templates/standalone.json")}"

  vars = {
    #Uncomment the following line for BYOL
    #local_sku      = "${var.license2}"

    host1           = "${var.host1_name}"
    host2           = "${var.host2_name}"
    local_host      = "${var.host2_name}"
    local_ext_selfip = "${var.f5vm02ext}"
    local_int_selfip = "${var.f5vm02int}"
    remote_host     = "${var.host1_name}"
    remote_selfip   = "${var.f5vm01int}"
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
resource "google_compute_instance" "ltm_instance" {
  count            = "${var.vm_count}"
  name             = "${var.projectPrefix}${var.name}-${count.index + 1}-instance"
  machine_type = "${var.bigipMachineType}"

  boot_disk {
    initialize_params {
      image = "${var.bigipImage}"
    }
  }
  metadata = {
    ssh-keys = "${var.adminAccountName}:${file(var.gce_ssh_pub_key_file)}"
    block-project-ssh-keys = true
    #startup-script = "${data.template_file.vm_onboard.rendered}"
    deviceId = "${count.index + 1}"
 }
#   metadata_startup_script = "${data.template_file.vm_onboard.rendered}"

  network_interface {
    # mgmt
    # A default network is created for all GCP projects
    network       = "${var.mgmt_vpc.name}"
    subnetwork = "${var.mgmt_subnet.name}"
    # network = "${google_compute_network.vpc_network.self_link}"
    access_config {
    }
  }
    network_interface {
    # external
    # A default network is created for all GCP projects
    network       = "${var.ext_vpc.name}"
    subnetwork = "${var.ext_subnet.name}"
    # network = "${google_compute_network.vpc_network.self_link}"
    access_config {
    }
  }
    network_interface {
    # internal
    # A default network is created for all GCP projects
    network       = "${var.int_vpc.name}"
    subnetwork = "${var.int_subnet.name}"
    # network = "${google_compute_network.vpc_network.self_link}"
    # access_config {
    # }
  }
}
# gcloud compute instances describe ltm-1-instance --format='get(networkInterfaces[0].accessConfigs[0].natIP)'

#output "f5vm01_mgmt_public_ip" { value = "${google_compute_instance.ltm-1-instance.access_config[0].natIP}" }

# // A variable for extracting the external ip of the instance
# output "ip" {
#  value = "${google_compute_instance.default.network_interface.0.access_config.0.nat_ip}"
# }
output "f5vm01_mgmt_public_ip" { value = "${google_compute_instance.vm_instance.0.network_interface.0.access_config.0.nat_ip}" }

#output "f5vm02_mgmt_public_ip" { value = "${google_compute_instance.vm_instance.1.network_interface.0.access_config.0.nat_ip}" }

# // A variable for extracting the external ip of the instance
# output "ip" {
#  value = "${google_compute_instance.default.network_interface.0.access_config.0.nat_ip}"
# }