#===============================================================================
# vSphere Data
#===============================================================================
data "vsphere_datacenter" "dc" {
  name = "${var.vsphere_datacenter}"
}

resource "vsphere_folder" "asm" {
  path          = "${var.vsphere_folder_env}/asm"
  type          = "vm"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_datastore" "datastore" {
  name          = "${var.vm_datastore}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_compute_cluster" "cluster" {
  name          = "${var.vsphere_cluster}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_network" "network1" {
  name          = "${var.vm_network_1}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}
data "vsphere_network" "network2" {
  name          = "${var.vm_network_2}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}
data "vsphere_network" "network3" {
  name          = "${var.vm_network_3}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}
data "vsphere_network" "network4" {
  name          = "${var.vm_network_4}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_virtual_machine" "template_from_ovf" {
  name          = "${var.vm_ovf}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

# data "vsphere_virtual_machine" "template" {
#   name          = "${var.vm_template}"
#   datacenter_id = "${data.vsphere_datacenter.dc.id}"
# }

resource "vsphere_tag" "Application" {
  name        = "asm"
  category_id = "${var.vm_tags_application}"
  description = "Managed by Terraform"
}


resource "vsphere_virtual_machine" "vm" {
  count            = "${var.vm_count}"
  name             = "${var.vm_name}-${count.index + 1}-${var.vsphere_folder_env}.${var.vm_domain}"
  resource_pool_id = "${data.vsphere_compute_cluster.cluster.resource_pool_id}"
  datastore_id     = "${data.vsphere_datastore.datastore.id}"
  folder           = "${vsphere_folder.asm.path}" 

  tags = [ "${vsphere_tag.Application.id}","${var.vm_tags_environment}" ]  

  num_cpus = "${var.vm_cpu}"
  memory   = "${var.vm_ram}"
  guest_id = "${data.vsphere_virtual_machine.template_from_ovf.guest_id}"

  scsi_type = "${data.vsphere_virtual_machine.template_from_ovf.scsi_type}"

  network_interface {
    network_id   = "${data.vsphere_network.network1.id}"
    adapter_type = "${data.vsphere_virtual_machine.template_from_ovf.network_interface_types[0]}"
  }
  network_interface {
    network_id   = "${data.vsphere_network.network2.id}"
    adapter_type = "${data.vsphere_virtual_machine.template_from_ovf.network_interface_types[0]}"
  }
  network_interface {
    network_id   = "${data.vsphere_network.network3.id}"
    adapter_type = "${data.vsphere_virtual_machine.template_from_ovf.network_interface_types[0]}"
  }
  network_interface {
    network_id   = "${data.vsphere_network.network4.id}"
    adapter_type = "${data.vsphere_virtual_machine.template_from_ovf.network_interface_types[0]}"
  }

  disk {
    # name             = "disk0"
    label            = "${var.vm_name}.vmdk"
    size             = "${data.vsphere_virtual_machine.template_from_ovf.disks.0.size}"
    eagerly_scrub    = "${data.vsphere_virtual_machine.template_from_ovf.disks.0.eagerly_scrub}"
    thin_provisioned = "${data.vsphere_virtual_machine.template_from_ovf.disks.0.thin_provisioned}"
  }

 clone {
    template_uuid = "${data.vsphere_virtual_machine.template_from_ovf.id}"

    customize {
      linux_options {
        host_name = "${var.vm_name}-${count.index + 1}-${var.vsphere_folder_env}"
        domain    = "${var.vm_domain}"
      }

      network_interface {
        ipv4_address = "${var.vm_mgmt_ip}${count.index + 1}"
        ipv4_netmask = "${var.vm_netmask}"
      }
      network_interface {}
      network_interface {}
      network_interface {}

      ipv4_gateway = "${var.vm_mgmt_gw}"
    }
  }
}