# vin-lab.com
## infrastructure as code
- terraform
- ansible
### requirements
- docker

### licensing options
- bigiq
- payg
- byol

Per Provider Overview: 

<!-- ![alt text][overview] -->

[overview]: images/vinlab-overview.png "overview"
---
# desired state per provider
- edge
    - high avaliabilty
    - firewall
    - ipi
    - dos
    - decryption
- internal
    - high avaliabilty
    - load balancing
    - waf
    - bot detection
    - access control
    - service discovery
    - api protection
    - api gateway
- services
    - kubernetes
    - legacy application servers
    - gitlab
    - jenkins for infrastructure
    - jenkins for applications
    - vault
---
workspace: 

<!-- ![alt text][workspace] -->

[workspace]: images/vinlab-on-prem.png "workspace"

# desired state workspace
- workstations
    - docker
        - linux
        - windows
- scm
    - git any flavor
- secrets
    - cloud kvm
    - hashicorp vault
- pipelines
    - same docker as workstations
    - builds to prod
# Ansible
```bash
## check inventory
ansible-inventory --list -i inventory.vmware.yml --vault-password-file scripts/.vault_pass.sh

# test play with inventory
ansible-playbook playbooks/test-inventory.yaml -i vinlab.vmware.yaml --vault-password-file scripts/.vault_pass.sh

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
```
# terraform
```bash
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

### apply specific resource
terraform apply -target module.vsphere.module.awx

### destroy specific resource
terraform destroy -target module.vsphere.module.awx

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
```
# https://cloud-images.ubuntu.com/releases/
#https://github.com/linoproject/terraform
# ubuntu to template vmware
failed guest customization on ubuntu and vmware 6.5
https://kb.vmware.com/s/article/56409 

https://jimangel.io/post/create-a-vm-template-ubuntu-18.04/
https://bugs.launchpad.net/ubuntu/+source/open-vm-tools/+bug/1793715
Workaround:

1. set cloud-init or perl scripts as the customization engine
   1) if you want to set cloud-init as the customization engine by:
      Set “disable_vmware_customization: false" in "/etc/cloud.cfg"

   2) if you want to set perl script as customization engine, you should disable or remove
      cloud-init

      Disable cloud-init service by running this command:
      sudo touch /etc/cloud/cloud-init.disabled

      Remove cloud-init package and purge the config files by running these commands:
      sudo apt-get purge cloud-init

2. Open the /usr/lib/tmpfiles.d/tmp.conf file.
   Go to the line 11 and add the prefix #.

   or example:
   #D /tmp 1777 root root -

3. If you have open-vm-tools installed, open the /lib/systemd/system/open-vm-tools.service file.
   Add “After=dbus.service” under [Unit].

```bash
disable_vmware_customization: false /etc/cloud.cfg
/usr/lib/tmpfiles.d/tmp.conf
#D /tmp 1777 root root -
/lib/systemd/system/open-vm-tools.service
After=dbus.service under [Unit]
```

```bash
#!/bin/bash
sudo apt -y update
sudo apt -y upgrade
sudo apt -y install open-vm-tools
#Stop services for cleanup
sudo service rsyslog stop

#clear audit logs
if [ -f /var/log/wtmp ]; then
    truncate -s0 /var/log/wtmp
fi
if [ -f /var/log/lastlog ]; then
    truncate -s0 /var/log/lastlog
fi

#cleanup /tmp directories
rm -rf /tmp/*
rm -rf /var/tmp/*

#cleanup current ssh keys
rm -f /etc/ssh/ssh_host_*

#add check for ssh keys on reboot...regenerate if neccessary
cat << 'EOL' | sudo tee /etc/rc.local
#!/bin/sh -e
#
# rc.local
#
# This script is executed at the end of each multiuser runlevel.
# Make sure that the script will "" on success or any other
# value on error.
#
# In order to enable or disable this script just change the execution
# bits.
#
# By default this script does nothing.
# dynamically create hostname (optional)
#if hostname | grep localhost; then
#    hostnamectl set-hostname "$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 13 ; echo '')"
#fi
test -f /etc/ssh/ssh_host_dsa_key || dpkg-reconfigure openssh-server
exit 0
EOL

# make sure the script is executable
chmod +x /etc/rc.local

#reset hostname
# prevent cloudconfig from preserving the original hostname
sed -i 's/preserve_hostname: false/preserve_hostname: true/g' /etc/cloud/cloud.cfg
truncate -s0 /etc/hostname
hostnamectl set-hostname localhost

#cleanup apt
apt clean

# set dhcp to use mac - this is a little bit of a hack but I need this to be placed under the active nic settings
# also look in /etc/netplan for other config files
sed -i 's/optional: true/dhcp-identifier: mac/g' /etc/netplan/50-cloud-init.yaml

# cleans out all of the cloud-init cache / logs - this is mainly cleaning out networking info
sudo cloud-init clean --logs

#cleanup shell history
cat /dev/null > ~/.bash_history && history -c
history -w

#shutdown
shutdown -h now
```

# bigip image builder:
https://github.com/f5devcentral/f5-bigip-image-generator

#  BIG-IP vmware ova to template
https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/bigip-ve-setup-vmware-esxi-13-1-0/3.html
Login and delete the REST ID, SSH keys, etc. per the article : https://support.f5.com/csp/article/K44134742 

```bash
rm -f /config/f5-rest-device-id
rm -f /config/ssh/ssh_host_* 
rm -f /shared/ssh/ssh_host_*
rm -f /config/bigip.license
echo "root:default" | chpasswd
echo "admin:admin" | chpasswd
cat > /root/.ssh/authorized_keys <<EOF 
ssh-rsa ABGHS YOUR PUBLIC KEY HERE
EOF
shutdown -h now
```

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

## centos8 template edits
- create your user and add ssh key
- centos/youraccount
### disable virtulization
```bash
systemctl disable libvirtd.service                                                                                                                                       
```
add ssh authorized keys
```bash
sudo cat >> ~/.ssh/authorized_keys <<EOF
ssh-rsa cdsfaszdfdsfafasd
EOF
```
### ansible
https://computingforgeeks.com/how-to-install-and-configure-ansible-on-rhel-8-centos-8/
```bash
sudo dnf install  --enablerepo epel-playground  ansible -y
```
### docker
https://pocketadmin.tech/en/centos-8-install-docker/
```bash
dnf install https://download.docker.com/linux/centos/7/x86_64/stable/Packages/containerd.io-1.2.6-3.3.el7.x86_64.rpm -y
```
### python
https://linuxconfig.org/how-to-install-pip-in-redhat-8
```bash
dnf install python3-pip -y
ln -sf python3 /usr/bin/python &&
ln -sf pip3 /usr/bin/pip
pip install docker
pip install docker-compose
```
### nodejs
https://github.com/nodesource/distributions/issues/845
https://linuxconfig.org/how-to-install-node-js-on-redhat-8-linux
```bash
sudo dnf module install nodejs -y
```
### awx
/root/.awx/awxcompose/

# playbooks
```bash
## AWX
ansible-playbook -i vinlab.vmware.yml --vault-password-file scripts/.vault_pass.sh playbooks/awx.yaml
## K8S
ansible-playbook -i vinlab.vmware.yml --vault-password-file scripts/.vault_pass.sh playbooks/k8s/main.yaml
## controller
ansible-playbook -i vinlab.vmware.yml --vault-password-file scripts/.vault_pass.sh playbooks/nginx/controller/main.yaml
## AFM
ansible-playbook -i vinlab.vmware.yml --vault-password-file scripts/.vault_pass.sh playbooks/afm.yaml
## ASM
ansible-playbook -i vinlab.vmware.yml --vault-password-file scripts/.vault_pass.sh playbooks/asm.yaml
## nfs
ansible-playbook -i vinlab.vmware.yml --vault-password-file scripts/.vault_pass.sh playbooks/nfs/main.yaml
```


# kubespray
```bash
## missing
### user config
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
### auto complete
centos:
sudo yum install bash-completion -y
echo 'source <(kubectl completion bash)' >>~/.bashrc
kubectl completion bash >/etc/bash_completion.d/kubectl
echo 'alias k=kubectl' >>~/.bashrc
echo 'complete -F __start_kubectl k' >>~/.bashrc
### nfs utils
sudo yum install nfs-utils -y
```
### helm3
```bash
# helm3
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

helm repo add  stable https://kubernetes-charts.storage.googleapis.com/
helm repo update
### nfs provisoner

helm install --namespace kube-system --name-template nfs-test stable/nfs-client-provisioner \
  --set nfs.server=192.168.60.20 \
  --set nfs.path=/volume2/k8s/test

test from client:

sudo mkdir /mnt/test
sudo mount -t nfs -vvvv 192.168.3.53:/mnt/k8s/dev /mnt/test
sudo touch /mnt/test/file.txt
sudo touch /mnt/test/file1.txt

patch to be default:
kubectl patch storageclass nfs-client -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

test pvc with grafana:
helm install --namespace default --name-template grafana stable/grafana --set persistence.enabled=true --set persistence.type=pvc --set persistence.size=1Gi --set persistence.storageClassName=nfs-client
kubectl get pvc
```
## 1.16
## work around for api change in 1.16
```bash
/etc/kubernetes/manifests/kube-apiserver.yaml

spec:
    ...
    - --runtime-config=apps/v1beta1=true,apps/v1beta2=true,extensions/v1beta1/daemonsets=true,extensions/v1beta1/deployments=true,extensions/v1beta1/replicasets=true,extensions/v1beta1/networkpolicies=true,extensions/v1beta1/podsecuritypolicies=true
    - 
kubectl -n kube-system delete pod kube-apiserver-whatever kube-controller-manager-whatever
kubectl -n kube-system delete pod kube-apiserver-k8s-1-dev kube-controller-manager-k8s-1-dev
```
# GCE
```bash
# machine type
image name
gcloud compute images list --project f5-7626-networks-public | grep payg | grep 15-0-1-1-0-0-3
gcloud compute images list --project f5-7626-networks-public | grep byol | grep 15-0-1-1-0-0-3
```
# vault helm
https://www.terraform.io/docs/providers/helm/index.html

https://www.hashicorp.com/blog/announcing-the-vault-helm-chart/

https://github.com/hashicorp/vault-helm

# setup lab
first run:
```bash
make dev
terraform init
cd ..
. .env_vars_helper.sh
cd ansible/
. scripts/.vault.setup.sh
cd ../terraform/
exit
make test
```

after:
```bash
make shell
terraform plan
terraform apply
```

----

# manual ansible in tf container
ansible-playbook --vault-password-file scripts/.vault_pass.sh playbooks/asm.yaml