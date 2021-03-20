
#===============================================================================
# vSphere Data
#===============================================================================
data "vsphere_datacenter" "dc" {
  name = var.vsphere_datacenter
}

resource "vsphere_folder" "folder" {
  path          = "${var.vsphere_folder_env}/${var.vm_name}"
  type          = "vm"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_compute_cluster" "cluster" {
  name          = var.vsphere_cluster
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_datastore" "datastore" {
  name          = var.vm_datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = var.vm_network
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template" {
  name          = var.vm_template
  datacenter_id = data.vsphere_datacenter.dc.id
}

#===============================================================================
# vSphere Resources
#===============================================================================

resource "vsphere_tag" "Application" {
  name        = var.vm_name
  category_id = var.vm_tags_application
  description = "Managed by Terraform"
}
# https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/cloudinit_config

data "template_file" "metadata" {
  template = file("${path.root}/vsphere/templates/f5/nginx/plus/metadata.yml")
  vars = {
    HOST = var.vm_name
  }
}
data "template_file" "userdata" {
  template = file("${path.root}/vsphere/templates/f5/nginx/plus/userdata.yml")
  vars = {
    VAULT_TOKEN       = var.vaultToken
    VAULT_PORT        = var.vaultPort
    VAULT_HOST        = var.vaultHost
    VAULT_PROTCOL     = var.vaultProtcol
    SECRET_NAME       = "nginx-plus-trial-1"
    controllerAddress = "none"
  }
}
data "template_file" "kickstart" {
  template = file("${path.root}/vsphere/templates/f5/nginx/plus/kickstart.yml")
  vars = {
    USER   = var.adminUser
    PASS   = var.adminPass
    PUBKEY = var.adminPubKey
  }
}
resource "vsphere_virtual_machine" "standalone" {
  count            = var.vm_count
  name             = "${var.vm_name}-${count.index + 1}-${var.vsphere_folder_env}.${var.vm_domain}"
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id
  folder           = vsphere_folder.folder.path

  tags = [vsphere_tag.Application.id, var.vm_tags_environment]

  num_cpus = var.vm_cpu
  memory   = var.vm_ram
  guest_id = data.vsphere_virtual_machine.template.guest_id

  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }

  disk {
    label            = "${var.vm_name}.vmdk"
    size             = var.vm_disk0_size
    eagerly_scrub    = data.vsphere_virtual_machine.template.disks.0.eagerly_scrub
    thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
  }

  cdrom {
    client_device = true
  }
  extra_config = {
    "guestinfo.metadata"          = base64encode(data.template_file.metadata.rendered)
    "guestinfo.metadata.encoding" = "base64"
    "guestinfo.userdata"          = base64encode(data.template_file.userdata.rendered)
    "guestinfo.userdata.encoding" = "base64"
  }
  vapp {
    properties = {
      hostname    = var.vm_name
      instance-id = "id-ovf-${var.vm_name}"
      user-data   = base64encode(data.template_file.kickstart.rendered)
    }
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
    linked_clone  = var.vm_linked_clone
  }
}
