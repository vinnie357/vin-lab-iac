#cloud-config
packages:
  - jq
  - apt-transport-https
  - lsb-release
  - ca-certificates
  - wget
write_files:
  - path: /setup.sh
    permissions: 0744
    owner: root
    content: |
        #!/usr/bin/env bash
        #https://computingforgeeks.com/deploy-kubernetes-cluster-on-ubuntu-with-kubeadm/
        set -e
        # startup
        # logging
        LOG_FILE="/var/log/startup.log"
        if [ ! -e $LOG_FILE ]
        then
          touch $LOG_FILE
          exec &>>$LOG_FILE
        else
          #if file exists, exit as only want to run once
          exit
        fi
        exec 1>$LOG_FILE 2>&1

        echo "==== starting ===="
        # add repos
        apt update
        apt -y install curl apt-transport-https
        curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg |  apt-key add -
        echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" |  tee /etc/apt/sources.list.d/kubernetes.list
        # get packages
        apt update
        apt -y install vim git curl wget kubelet kubeadm kubectl
        apt-mark hold kubelet kubeadm kubectl
        # disable swap
        sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
        swapoff -a
        # configure systemctl
        modprobe overlay
        modprobe br_netfilter

        tee /etc/sysctl.d/kubernetes.conf<<EOF
        net.bridge.bridge-nf-call-ip6tables = 1
        net.bridge.bridge-nf-call-iptables = 1
        net.ipv4.ip_forward = 1
        EOF

        sysctl --system

        ## install containerd
        echo "==== install containerd ===="
        # Configure persistent loading of modules
        tee /etc/modules-load.d/containerd.conf <<EOF
        overlay
        br_netfilter
        EOF

        # Load at runtime
        modprobe overlay
        modprobe br_netfilter

        # Ensure sysctl params are set
        #  tee /etc/sysctl.d/kubernetes.conf<<EOF
        # net.bridge.bridge-nf-call-ip6tables = 1
        # net.bridge.bridge-nf-call-iptables = 1
        # net.ipv4.ip_forward = 1
        # EOF

        cat /etc/sysctl.d/kubernetes.conf | grep "net.bridge"
        cat /etc/sysctl.d/kubernetes.conf | grep "net.ipv4"

        # Reload configs
        sysctl --system

        # Install required packages
        apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates


        # Add Docker repo
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg |  apt-key add -
        add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

        # Install containerd
        apt update
        apt install -y containerd.io

        # Configure containerd and start service
        mkdir -p /etc/containerd

        containerd config default | tee /etc/containerd/config.toml

        # restart containerd
        systemctl restart containerd
        systemctl enable containerd

        # hosts
        echo "$(ip -4 addr show ens192 | grep -oP '(?<=inet\s)\d+(\.\d+){3}') ${HOST}.${dnsDomain}" >> /etc/hosts
        # register dns
        echo "server ${DNS_SERVER}
        update add ${HOST}.${dnsDomain} 60 A $(ip -4 addr show ens192 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
        send" | nsupdate
        # tee /dns.txt <<EOF
        # server ${DNS_SERVER}
        # update add ${HOST}.${dnsDomain}. 600 a $(ip -4 addr show ens192 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
        # EOF
        # nsupdate /dns.txt

        # wait for control node
        echo "waiting for control node"
        sleep 120
        # get join command
        host=${HOST}
        secretName="$(echo "$${host/-node-[0-9]/-master-0}")"
        vaultUrl="${vaultUrl}"
        vaultToken="${vaultToken}"
        secretData=$(
        curl -s \
        --header "X-Vault-Token: $vaultToken" \
        --request GET \
        $vaultUrl/v1/secret/data/$secretName
        )

        echo "set host"
        echo $secretData | jq -r .data.data.dns >> /etc/hosts
        echo "do join command"

        echo $secretData | jq -r .data.data.joinCommand | base64 -d | bash

        echo "==== done ===="
runcmd:
    - bash /setup.sh
    # - curl -sSL https://raw.githubusercontent.com/hashicorp/f5-terraform-consul-sd-webinar/master/scripts/consul.sh | sh - #Install consul
