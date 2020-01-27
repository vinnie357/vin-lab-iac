
# Obtain Gateway IP for each Subnet
locals {
  depends_on = ["google_compute_network.vpc_network_mgmt", "google_compute_network.vpc_network_mgmt_ext","google_compute_network.vpc_network_mgmt_int"]
  mgmt_gw    = "${var.mgmt_subnet.gateway_address}"
  ext_gw     = "${var.ext_subnet.gateway_address}"
  int_gw     = "${var.int_subnet.gateway_address}"
}
# firewall
resource "google_compute_firewall" "mgmt" {
  name    = "${var.projectPrefix}mgmt-firewall"
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
resource "google_compute_firewall" "app" {
  name    = "${var.projectPrefix}app-firewall"
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
    projectPrefix       = "${var.projectPrefix}"
  }
}
#Declarative Onboarding template 01
data "template_file" "vm01_do_json" {
  template = "${file("${path.module}/templates/${var.vm_count >= 2 ? "cluster" : "standalone"}.json")}"

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
  template = "${file("${path.module}/templates/${var.vm_count >= 2 ? "cluster" : "standalone"}.json")}"

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
# resource "random_uuid" "as3_uuid" { }

#application services 3 template
data "template_file" "as3_json" {
  template = "${file("${path.module}/templates/scca.json")}"
  vars ={
      uuid = "uuid()"
    #   sdCreds = "${base64encode(file("/creds/gcp/${var.GCP_SA_FILE}.json"))}"
  }
}


# bigips
resource "google_compute_instance" "vm_instance" {
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
  metadata_startup_script = "${data.template_file.vm_onboard.rendered}"

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
    service_account {
    # https://cloud.google.com/sdk/gcloud/reference/alpha/compute/instances/set-scopes#--scopes
    # email = "${var.service_accounts.compute}"
    scopes = [ "storage-ro", "logging-write", "monitoring-write", "monitoring", "pubsub", "service-management" , "service-control" ]
    # scopes = [ "storage-ro"]
  }
#     provisioner "local-exec" {
#     command = <<-EOF
#       ansible-playbook  --version
#     EOF
#   }
# # Copies the script file to /tmp/script.sh
#   provisioner "file" {
#     source      = "script.sh"
#     destination = "/tmp/script.sh"
#   }

#   provisioner "remote-exec" {
#     inline = [
#       "chmod +x /tmp/script.sh",
#       "/tmp/script.sh args",
#     ]
#   }
}
# resource "google_storage_bucket" "instance-store-1" {
#   name     = "${google_compute_instance.vm_instance.0.name}-storage"
#   location = "US"

#   website {
#     main_page_suffix = "index.html"
#     not_found_page   = "404.html"
#   }
# }
# resource "google_storage_bucket" "instance-store-2" {
#   name     = "${google_compute_instance.vm_instance.1.name}-storage"
#   location = "US"

#   website {
#     main_page_suffix = "index.html"
#     not_found_page   = "404.html"
#   }
# }
resource "google_storage_bucket" "bigip-ha" {
  name     = "${var.projectPrefix}bigip-storage"
  location = "US"

  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }
}

resource "google_storage_bucket_object" "bigip-1" {
name = "bigip-1"
content = "${google_compute_instance.vm_instance.0.network_interface.2.network_ip}"
bucket = "${google_storage_bucket.bigip-ha.name}"
}
resource "google_storage_bucket_object" "bigip-2" {
name = "bigip-2"
content = "${var.vm_count >= 2 ? "${google_compute_instance.vm_instance.1.network_interface.2.network_ip}" : "none" }"
bucket = "${google_storage_bucket.bigip-ha.name}"
}

# gcloud compute instances describe afm-1-instance --format='get(networkInterfaces[0].accessConfigs[0].natIP)'

#output "f5vm01_mgmt_public_ip" { value = "${google_compute_instance.afm-1-instance.access_config[0].natIP}" }

# // A variable for extracting the external ip of the instance
# output "ip" {
#  value = "${google_compute_instance.default.network_interface.0.access_config.0.nat_ip}"
# }
output "f5vm01_mgmt_public_ip" { value = "${google_compute_instance.vm_instance.0.network_interface.0.access_config.0.nat_ip}" }
output "f5vm01_app_public_ip" { value = "${google_compute_instance.vm_instance.0.network_interface.1.access_config.0.nat_ip}" }

output "f5vm02_mgmt_public_ip" { value = "${var.vm_count >= 2 ? "${google_compute_instance.vm_instance.1.network_interface.0.access_config.0.nat_ip}" : "none"}"}
output "f5vm02_app_public_ip" { value = "${var.vm_count >= 2 ? "${google_compute_instance.vm_instance.1.network_interface.1.access_config.0.nat_ip}" : "none" }"}

# // A variable for extracting the external ip of the instance
# output "ip" {
#  value = "${google_compute_instance.default.network_interface.0.access_config.0.nat_ip}"
# }

# as3
# provider "bigip" {
#     address = "${google_compute_instance.vm_instance.0.network_interface.0.access_config.0.nat_ip}"
#     #address = "34.73.208.201"
#     username = "${var.adminAccountName}"
#     password = "${var.adminPass}"
# }

# data "template_file" "as3" {
#   template = "${file("${path.module}/templates/scca_gcp.json")}"
#   vars ={
#       uuid = "uuid()"
#       virtualIP = "${google_compute_instance.vm_instance.0.network_interface.1.network_ip}"
#   }
# }
# resource "bigip_as3"  "as3-example" {
#      as3_json = "${data.template_file.as3.rendered}"
#      config_name = "Example"
# }