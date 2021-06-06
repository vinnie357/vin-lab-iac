systemctl enable kubelet

kubeadm config images pull

# hosts
tee /etc/hosts <<EOF
$(ip -4 addr show ens192 | grep -oP '(?<=inet\s)\d+(\.\d+){3}') ${HOST}.${dnsDomain}
EOF
# register dns
tee /dns.txt <<EOF
update add ${HOST}.${dnsDomain}. 600 a $(ip -4 addr show ens192 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
EOF
nsupdate /dns.txt

sudo kubeadm init \
  --pod-network-cidr=${podCidr} \
  --control-plane-endpoint=${HOST}.${dnsDomain}

# sudo kubeadm init \
#   --pod-network-cidr=10.10.0.0/16 \
#   --control-plane-endpoint=k8s2-master-0-dev.vin-lab.com

kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
