#https://pkg.go.dev/k8s.io/kubernetes/cmd/kubeadm/app/apis/kubeadm/v1beta2
apiVersion: kubeadm.k8s.io/v1beta2
kind: ClusterConfiguration
controlPlaneEndpoint: ${HOST}.${dnsDomain}
apiServer:
  extraArgs:
    advertise-address: $(ip -4 addr show ens192 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
    service-account-signing-key-file: /etc/kubernetes/pki/sa.key
    service-account-issuer: api
    service-account-api-audiences: api
networking:
  podSubnet: "${podCidr}" # --pod-network-cidr