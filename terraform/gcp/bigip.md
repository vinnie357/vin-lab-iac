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

# as3 tf provider
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
# do troubleshooting
```bash
admin_username='admin'
admin_password='mypassword'
CREDS="$admin_username:$admin_password"
# do
doUrl="/mgmt/shared/declarative-onboarding"
doCheckUrl="/mgmt/shared/declarative-onboarding/info"
doTaskUrl="mgmt/shared/declarative-onboarding/task"
# as3
as3Url="/mgmt/shared/appsvcs/declare"
as3CheckUrl="/mgmt/shared/appsvcs/info"

# do
restcurl -u $CREDS $doTaskUrl | jq .


task=$(curl -s -u $CREDS -H "Content-Type: Application/json" -H 'Expect:' -X POST http://localhost:8100/mgmt/shared/declarative-onboarding -d @/config/do1.json | jq -r .id)
while true
do
   status=$(restcurl -u $CREDS $doTaskUrl/$task | jq -r .result.status)
   echo " $task status: $status "
   sleep 30
done
restcurl -u $CREDS $doTaskUrl/$task | jq. result.status

# as3
task=$(curl -s -u $CREDS -H "Content-Type: Application/json" -H 'Expect:' -X POST http://localhost:8100$as3Url?async=true -d @/config/as3.json | jq -r .id)
while true
do
    status=$(curl -s -u $CREDS http://localhost:8100/mgmt/shared/appsvcs/task/$task | jq -r '.results[].message')
    echo " $task status: $status "
    sleep 30
done
restcurl -s -u $CREDS http://localhost:8100/mgmt/shared/appsvcs/task/
```
# work around check
as3 responds while DO is provisioning:
 ad3471d1-a8c1-4d66-baf3-bf000167b695 status: GET http://admin:XXXXXX@localhost:8100/mgmt/tm/sys/provision query target BIG-IP provisioning response=400 body={"code":400,"message":"remoteSender:Unknown, method:GET ","referer":"Unknown","restOperationId":5610485,"kind":":resterrorresponse"}


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

rm /var/log/startup-script.log
google_metadata_script_runner --script-type startup --debug 


# gcp routes/mtu
## vlan selfip
modify /net vlan external mtu 1460
create /net self 10.1.10.5/32 vlan external [change to match your environment]
## routes
create /net route ext_gw_int interface external network 10.1.10.1/32
create /net route ext_rt network 10.1.10.0/24 gw 10.1.10.1
create /sys management-route default gateway 10.1.1.1
create /net route default gw 10.1.10.1

```bash
function error_exit {
echo  "${PROGNAME}: ${1:-"Unknown Error"}" 1>&2
exit 1
}
MGMTADDRESS=$(curl -s -f --retry 20 'http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip' -H 'Metadata-Flavor: Google')
MGMTMASK=$(curl -s -f --retry 20 'http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/subnetmask' -H 'Metadata-Flavor: Google')
MGMTGATEWAY=$(curl -s -f --retry 20 'http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/gateway' -H 'Metadata-Flavor: Google')

INT2ADDRESS=$(curl -s -f --retry 20 'http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/1/ip' -H 'Metadata-Flavor: Google')
INT2MASK=$(curl -s -f --retry 20 'http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/1/subnetmask' -H 'Metadata-Flavor: Google')
INT2GATEWAY=$(curl -s -f --retry 20 'http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/1/gateway' -H 'Metadata-Flavor: Google')

INT3ADDRESS=$(curl -s -f --retry 20 'http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/2/ip' -H 'Metadata-Flavor: Google')
INT3MASK=$(curl -s -f --retry 20 'http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/2/subnetmask' -H 'Metadata-Flavor: Google')
INT3GATEWAY=$(curl -s -f --retry 20 'http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/2/gateway' -H 'Metadata-Flavor: Google')

MGMTNETWORK=$(/bin/ipcalc -n ${MGMTADDRESS} ${MGMTMASK} | cut -d= -f2)
INT2NETWORK=$(/bin/ipcalc -n ${INT2ADDRESS} ${INT2MASK} | cut -d= -f2)
INT3NETWORK=$(/bin/ipcalc -n ${INT3ADDRESS} ${INT3MASK} | cut -d= -f2)
# mgmt
echo " mgmt"
echo "$MGMTADDRESS,$MGMTMASK,$MGMTGATEWAY"
echo "external"
echo "$INT2ADDRESS,$INT2MASK,$INT2GATEWAY"
echo "internal"
echo "$INT3ADDRESS,$INT3MASK,$INT3GATEWAY"
echo "cidr"
echo "$MGMTNETWORK"
echo "$INT2NETWORK"
echo "$INT3NETWORK"

tmsh+=(
"tmsh modify sys global-settings mgmt-dhcp disabled"
"tmsh delete sys management-route all"
"tmsh delete sys management-ip all"
"tmsh create sys management-ip ${MGMTADDRESS}/32"
"tmsh create sys management-route mgmt_gw network ${MGMTGATEWAY}/32 type interface"
"tmsh create sys management-route mgmt_net network ${MGMTNETWORK}/${MGMTMASK} gateway ${MGMTGATEWAY}"
"tmsh create sys management-route default gateway ${MGMTGATEWAY}"
"tmsh create net vlan external interfaces add { 1.1 } mtu 1460"
"tmsh create net self self_external address ${INT2ADDRESS}/32 vlan external"
#"tmsh modify net self external-self address ${INT2ADDRESS}/32 vlan external"
"tmsh create net route ext_gw_interface network ${INT2GATEWAY}/32 interface external"
"tmsh create net route ext_rt network ${INT2NETWORK}/${INT2MASK} gw ${INT2GATEWAY}"
"tmsh create net route default gw ${INT2GATEWAY}"
"tmsh create net vlan internal interfaces add { 1.2 } mtu 1460"
"tmsh create net self internal-self address ${INT3ADDRESS}/32 vlan internal"
"tmsh create net route int_gw_interface network ${INT3GATEWAY}/32 interface internal"
"tmsh create net route int_rt network ${INT3NETWORK}/${INT3MASK} gw ${INT3GATEWAY}"
'tmsh save /sys config'
)
for CMD in "${tmsh[@]}"
do
   if $CMD;then
       echo "command $CMD successfully executed."
   else
       error_exit "$LINENO: An error has occurred while executing $CMD. Aborting"
   fi
done 

```

# modify DO with API call values ??
sed -i "s/internal-self-address/$INT3ADDRESS/g" /config/do1.json
sed -i "s/internal-self-address/$INT3ADDRESS/g" /config/do2.json
sed -i "s/external-self-address/$INT2ADDRESS/g" /config/do1.json
sed -i "s/external-self-address/$INT2ADDRESS/g" /config/do2.json