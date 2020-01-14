#===============================================================================
# vSphere Data
#===============================================================================
data "vsphere_datacenter" "dc" {
  name = "${var.vsphere_datacenter}"
}

resource "vsphere_folder" "afm" {
  path          = "${var.vsphere_folder_env}/afm"
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
  name        = "afm"
  category_id = "${var.vm_tags_application}"
  description = "Managed by Terraform"
}

# data "template_file" "vm_onboard" {
#   template = "${file("${path.root}/vsphere/templates/f5/bigip/onboard.tpl")}"

#   vars = {
#     uname        	      = "${var.adminAccountName}"
#     upassword        	  = "${var.adminPass}"
#     DO_onboard_URL      = "${var.DO_onboard_URL}"
#     AS3_URL		          = "${var.AS3_URL}"
#     libs_dir		        = "${var.libs_dir}"
#     onboard_log		      = "${var.onboard_log}"
#     DO1_Document        = "${data.template_file.vm01_do_json.rendered}"
#     DO2_Document        = "${data.template_file.vm02_do_json.rendered}"
#     AS3_Document        = "${data.template_file.as3_json.rendered}"
#   }
# }
# #Declarative Onboarding template 01
# data "template_file" "vm01_do_json" {
#   template = "${file("${path.root}/vsphere/templates/f5/bigip/standalone.json")}"

#   vars = {
#     #Uncomment the following line for BYOL
#     #local_sku	    = "${var.license1}"

#     host1	    = "${var.host1_name}"
#     host2	    = "${var.host2_name}"
#     local_host      = "${var.host1_name}"
#     local_ext_selfip = "${var.f5vm01ext}"
#     local_int_selfip = "${var.f5vm01int}"
#     remote_host	    = "${var.host2_name}"
#     remote_selfip   = "${var.f5vm02int}"
#     #gateway         = "${local.ext_gw}"
#     gateway         = "192.168.1.1"
#     dns_server	    = "${var.dns_server}"
#     ntp_server	    = "${var.ntp_server}"
#     timezone	    = "${var.timezone}"
#     admin_user      = "${var.adminAccountName}"
#     admin_password  = "${var.adminPass}"
#     domain          = "${var.domain}"
#   }
# }
# #Declarative Onboarding template 02
# data "template_file" "vm02_do_json" {
#   template = "${file("${path.root}/vsphere/templates/f5/bigip/standalone.json")}"

#   vars = {
#     #Uncomment the following line for BYOL
#     #local_sku      = "${var.license2}"

#     host1           = "${var.host1_name}"
#     host2           = "${var.host2_name}"
#     local_host      = "${var.host2_name}"
#     local_ext_selfip = "${var.f5vm02ext}"
#     local_int_selfip = "${var.f5vm02int}"
#     remote_host     = "${var.host1_name}"
#     remote_selfip   = "${var.f5vm01int}"
#     #gateway         = "${local.ext_gw}"
#     gateway         = "192.168.1.1"
#     dns_server      = "${var.dns_server}"
#     ntp_server      = "${var.ntp_server}"
#     timezone        = "${var.timezone}"
#     admin_user      = "${var.adminAccountName}"
#     admin_password  = "${var.adminPass}"
#     domain          = "${var.domain}"
#   }
# }
# # as3 uuid generation
# resource "random_uuid" "as3_uuid" { }

# #application services 3 template
# data "template_file" "as3_json" {
#   template = "${file("${path.root}/vsphere/templates/f5/bigip/scca.json")}"
#   vars ={
#       uuid = "${random_uuid.as3_uuid.result}"
#   }
# }
resource "vsphere_virtual_machine" "vm" {
  count            = "${var.vm_count}"
  name             = "${var.vm_name}-${count.index + 1}-${var.vsphere_folder_env}.${var.vm_domain}"
  resource_pool_id = "${data.vsphere_compute_cluster.cluster.resource_pool_id}"
  datastore_id     = "${data.vsphere_datastore.datastore.id}"
  folder           = "${vsphere_folder.afm.path}" 

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
  cdrom {
    client_device = true
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
      dns_server_list = "${var.dns_server_list}"
      ipv4_gateway = "${var.vm_mgmt_gw}"
    }
  }
  
#   vapp {
#     properties = {
#       #"guestinfo.tf.internal.id" = "42"
#       "net.mgmt.addr" = "${var.vm_mgmt_ip}${count.index + 1}"
#       "net.mgmt.gw" = "${var.vm_mgmt_gw}"
#       "user.root.pwd" = "${var.vm_root_password}"
#       "user.admin.pwd" = "${var.vm_admin_password}"
#       #deployment_option: "{{var.size}}"
#     }
#   }

#   provisioner "file" {
#     source      = "${data.template_file.vm_onboard.rendered}"
#     destination = "/tmp/startup_script.sh"
#   }

#   provisioner "remote-exec" {
#     inline = [
#       "chmod +x /tmp/startup_script.sh",
#       "/tmp/startup_script.sh ${count.index + 1}",
#     ]
#   }
}