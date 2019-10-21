# vin-lab.com
## ansible infrastructure as code
### requirements
- docker
- vcenter
- big-iq

# Ansible

# ansible playbooks
make ansible ARGS="item.yaml"

## shell
make ansibleShell
## run
ansible-playbook playbooks/deploy.yaml --vault-password-file scripts/.vault_pass.sh --extra-vars "@context/item.yaml"
## awx
ansible-playbook playbooks/deploy.yaml --vault-password-file scripts/.vault_pass.sh --extra-vars "@context/awx.yaml"
## afm
ansible-playbook playbooks/deploy.yaml --vault-password-file scripts/.vault_pass.sh --extra-vars "@context/afm.yaml"

# terraform
## shell
make terraformShell

## run
make deploy

make init
make plan
make apply

## that new new

### specific env
terraform apply -target module.vsphere -var-file="creds.tfvars"



# vars
parent
-provider
--virtualmachine/container

#global
TF_VAR_

## defined pickup
jkfndsanf.tfvars

## auto pickup
sec.auto.tfvars
terraform.tfvars

# terrform structure
variables.tf
things.tf


# vmware ova to template
https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/bigip-ve-setup-vmware-esxi-13-1-0/3.html
## OVA to OVF instructions
Use tar to uncompact your OVA
```bash
tar -xf <path/name_of_ova_file.ova>
```
You should now have 5 files with format: <name_of_ova_file.ovf, .cert, .mf, disk1.vmdk, and disk2.vmdk>

Modify the .ovf file and add the following properties to <ProductSection>:
```bash
<Category>Network properties</Category>  
  <Property ovf:key="net.mgmt.addr" ovf:type="string" ovf:value="" ovf:userConfigurable="true">
    <Label>mgmt-addr</Label>
    <Description>F5 BIG-IP VE's management address in the format of "IP/prefix"</Description>
  </Property>
  <Property ovf:key="net.mgmt.gw" ovf:type="string" ovf:value="" ovf:userConfigurable="true">
    <Label>mgmt-gw</Label>
    <Description>F5 BIG-IP VE's management default gateway</Description>
  </Property>
<Category>User properties</Category>
  <Property ovf:key="user.root.pwd" ovf:type="string" ovf:value="" ovf:userConfigurable="true">
    <Label>root-pwd</Label>
    <Description>F5 BIG-IP VE's SHA-512 shadow or plain-text password for "root" user</Description>
  </Property>
  <Property ovf:key="user.admin.pwd" ovf:type="string" ovf:value="" ovf:userConfigurable="true">
    <Label>admin-pwd</Label>
    <Description>F5 BIG-IP VE's SHA-512 shadow or plain-text password for "admin" user</Description>
  </Property>
```
## or use the cot tool to edit the ova
modify ovas for custom IPs
https://devcentral.f5.com/articles/ve-on-vmware-part-1-custom-properties-29787
Common OVF Tool
https://cot.readthedocs.io/en/latest/introduction.html
example: 
```bash
cot edit-properties source-filename.ova -p net.mgmt.addr=""+string -p net.mgmt.gw=""+string -p user.root.pwd=""+string -p user.admin.pwd=""+string -u -o destination-filename.ova

pip install cot
cot edit-properties BIGIP-13.1.1.3-0.0.1.ALL-scsi.ova -p net.mgmt.addr=""+string -p net.mgmt.gw=""+string -p user.root.pwd=""+password -p user.admin.pwd=""+password -u -o vcenter-BIGIP-13.1.1.3-0.0.1.ALL-scsi.ova
```

## upload to vcenter
### download ovf tool
https://code.vmware.com/web/tool/4.3.0/ovf

### upload
```cmd
.\ovftool.exe `
--acceptAllEulas `
--allowAllExtraConfig `
--name=bigip13.1 `
--datastore=<datastorename> `
--net:"Internal"="VM Network" `
--net:"External"="VM Network" `
--net:"HA"="VM Network" `
--net:"Management"="VM Network" `
--vmFolder=<bigip_templates> `
--importAsTemplate `
C:\iso\vcenter-BIGIP-13.1.1.3-0.0.1.ALL-scsi.ova `
'vi://admin@vinlab.com@vcenter.vin-lab.com/<datacenter>/host/<clustername>/'
```

### reset vapp options
```bash
rm /shared/vadc/.ve_cust_done
shutdown -r now
```

#### noteable issues
if your bigip image name is not an FQDN the vapp options may not load