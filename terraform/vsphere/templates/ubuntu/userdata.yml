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
runcmd:
    - bash /setup.sh
    # - curl -sSL https://raw.githubusercontent.com/hashicorp/f5-terraform-consul-sd-webinar/master/scripts/consul.sh | sh - #Install consul
