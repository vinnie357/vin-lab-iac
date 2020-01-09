# ssh keys
Add ssh key to virtual machines		
From GCP console, go to virtual machine, click Edit
		Scroll down to SSH section
		Add the following to the key area (all one line!):
ssh-rsa key-goes-here-with-a-space-afterwards-with-username admin
Click Save
Connect via SSH


firewall rule for the APP
firewall rule for mgmt

networks interfaces
 network
 subnetwork
 accessconfigs
 
 network
 subnetwork
 accessconfigs  
 
 network
 subnetwork


public ip if enabled
 app NAT
 mgmt NAT


bigip config
 name
 type
 properties
 canipforward
 disks:
   boot
 machine type
 network interfaces
   items mgmt
   items appfw
 zone
 ntp servers
 time zone
 startup-scripts
 
outputs
 puplic ip
 private ip
region
mgmt url
app address


# onboarding logs
google_metadata_script_runner --script-type startup --debug 
cat /var/log/messages
cat /var/log/startup-script.log

https://support.f5.com/csp/article/K23449665

use this for as3? but there may be some issues waiting/timing

variable "bigip_password" {
  type = string
}
variable "tenant" {
  type = string
}
variable "vip_address" {
  type = string
}
variable "bigip_address" {
  type = string
}
provider "bigip" {
    address = "${var.bigip_address}"
    username = "admin"
    password = "${var.bigip_password}"
}
data "template_file" "init" {
  template = "${file("as3.tpl")}"
  vars = {
    UUID = "uuid()"
    TENANT = "${var.tenant}"
    VIP_ADDRESS = "${var.vip_address}"
  }
}
resource "bigip_as3"  "as3-example" {
     as3_json = "${data.template_file.init.rendered}"
     tenant_name = "${var.tenant}"
}

# as3 troubleshooting
bigstart status restnoded
bigstart restart restnoded
bigstart status restnoded
curl -u $CREDS localhost:8100$as3CheckUrl

curl -s -u $CREDS -H "Content-Type: Application/json" -H 'Expect:' -X POST http://localhost:8100$as3Url?async=true -d @/config/as3.json
curl -s -u $CREDS http://localhost:8100/mgmt/shared/appsvcs/task/$task | jq -r '.results[].message'

task=$(curl -s -u $CREDS -H "Content-Type: Application/json" -H 'Expect:' -X POST http://localhost:8100$as3Url?async=true -d @/config/as3.json | jq -r .id)

status=$(curl -s -u $CREDS http://localhost:8100/mgmt/shared/appsvcs/task/$task | jq -r '.results[].message')
echo "as3 post status: $status"