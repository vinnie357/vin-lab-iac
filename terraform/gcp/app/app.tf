
# resource "google_compute_network" "vpc_network" {
#   name                    = "terraform-network"
#   auto_create_subnetworks = "true"
#   routing_mode = "REGIONAL"
# }

#application template
data "template_file" "dockerApp" {
  template = "${file("${path.module}/app.tpl")}"
  vars ={
      port = "80"
      ssl = true
  }
}

resource "google_compute_instance" "vm_instance" {
  name         = "${var.projectPrefix}terraform-app-instance"
  machine_type = "f1-micro"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }
  metadata = {
    ssh-keys = "${var.adminAccountName}:${file(var.gce_ssh_pub_key_file)}"
    block-project-ssh-keys = true
 }
 metadata_startup_script = "${data.template_file.dockerApp.rendered}"
  
  network_interface {
    # A default network is created for all GCP projects
    network       = "${var.int_vpc.name}"
    subnetwork = "${var.int_subnet.name}"
    # network = "${google_compute_network.vpc_network.self_link}"
    # enabling access config requests a public ip
    # access_config {
    # }
  }
}