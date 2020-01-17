# vin-lab.com
## infrastructure as code
- terraform
- ansible
### requirements
- docker
- vcenter
- big-iq

# Ansible
# check inventory
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

## centos8 template edits
### create your user and add ssh key
centos/youraccount
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



# kubespray
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
### helm3
helm3
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

## 1.16
## work around for api change in 1.16
/etc/kubernetes/manifests/kube-apiserver.yaml

spec:
    ...
    - --runtime-config=apps/v1beta1=true,apps/v1beta2=true,extensions/v1beta1/daemonsets=true,extensions/v1beta1/deployments=true,extensions/v1beta1/replicasets=true,extensions/v1beta1/networkpolicies=true,extensions/v1beta1/podsecuritypolicies=true
    - 
kubectl -n kube-system delete pod kube-apiserver-whatever kube-controller-manager-whatever
kubectl -n kube-system delete pod kube-apiserver-k8s-1-dev kube-controller-manager-k8s-1-dev

# GCE
machine type
image name
gcloud compute images list --project f5-7626-networks-public | grep payg | grep 15-0-1-1-0-0-3
gcloud compute images list --project f5-7626-networks-public | grep byol | grep 15-0-1-1-0-0-3

# vault helm
https://www.terraform.io/docs/providers/helm/index.html
https://www.hashicorp.com/blog/announcing-the-vault-helm-chart/
https://github.com/hashicorp/vault-helm

