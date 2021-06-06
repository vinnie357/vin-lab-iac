sudo su -
echo "192.168.3.74 k8s2-master-0-dev.vin-lab.com" >> /etc/hosts

kubeadm join \
k8s2-master-0-dev.vin-lab.com:6443 \
--token ${token} \
--discovery-token-ca-cert-hash ${certHash}
