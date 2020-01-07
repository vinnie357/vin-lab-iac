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
