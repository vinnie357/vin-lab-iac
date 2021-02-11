#!/bin/bash
echo "---installing terraform---"
terraformVersion="0.12.29"
sudo wget https://releases.hashicorp.com/terraform/$terraformVersion/terraform_"$terraformVersion"_linux_amd64.zip
sudo unzip ./terraform_"$terraformVersion"_linux_amd64.zip -d /usr/local/bin/
sudo rm ./terraform_"$terraformVersion"_linux_amd64.zip
echo "---terraform done---"