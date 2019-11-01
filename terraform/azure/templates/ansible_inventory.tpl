[azure_ubuntu_systems]
${azure_ubuntu_data}

[F5_systems]
#Must be in the form of <public IP> vs_ip=<private ip of the F5>
${azure_F5_public_ip} vs_ip=${azure_F5_private_ip}

[azure_ubuntu_systems:vars]
ansible_python_interpreter=/usr/bin/python3
ansible_user=azureuser

[F5_systems:vars]
ansible_user=azureuser
