# k8s ubuntu
- ubuntu20.04
- containerd


## remote admin default creds
### collect creds
```bash
ssh user@k8s2-master-0-dev.vin-lab.com
sudo su -
cat /etc/kubernetes/admin.conf
```
### setup creds
```bash
sudo su -
echo "192.168.3.74 k8s2-master-0-dev.vin-lab.com" >> /etc/hosts
exit
mkdir -p $HOME/.kube
tee $HOME/.kube/myconfig <<EOF
-input from cat /etc/kubernetes/admin.conf -
EOF
sudo chown $(id -u):$(id -g) $HOME/.kube/myconfig

export KUBECONFIG=$HOME/.kube/myconfig

```

### optional auto complete
```bash
sudo apt-get install bash-completion -y
echo "alias k=kubectl" >> $HOME/.bashrc
echo 'source <(kubectl completion bash)' >> $HOME/.bashrc
echo "source <(kubectl completion bash | sed 's|__start_kubectl kubectl|__start_kubectl k|g')" >> $HOME/.bashrc
# start a new shell
bash
```
