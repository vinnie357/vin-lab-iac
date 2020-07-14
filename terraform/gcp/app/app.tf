
# resource "google_compute_network" "vpc_network" {
#   name                    = "terraform-network"
#   auto_create_subnetworks = "true"
#   routing_mode = "REGIONAL"
# }

#application template
data template_file dockerApp {
  template = "${file("${path.module}/app.tpl")}"
  vars ={
      port = "4000"
      ssl = true
  }
}

resource google_compute_instance vm_instance {
  name         = "${var.projectPrefix}terraform-app-instance"
  machine_type = "f1-micro"

  boot_disk {
    initialize_params {
      # https://cloud.google.com/container-optimized-os/docs/
      # container optimized
      image = "gce-uefi-images/cos-stable-79-12607-80-0"
    }
  }
  metadata = {
    ssh-keys = "${var.adminAccountName}:${file(var.gce_ssh_pub_key_file)}"
    block-project-ssh-keys = true
    juiceShop = "dev"
    demoApp = "dev"
 }
 metadata_startup_script = data.template_file.dockerApp.rendered
  
  network_interface {
    # A default network is created for all GCP projects
    network    = var.int_vpc.name
    subnetwork = var.int_subnet.name
    network_ip = "10.0.20.200"
    # network = "${google_compute_network.vpc_network.self_link}"
    # enabling access config requests a public ip
    access_config {
    }
  }
}