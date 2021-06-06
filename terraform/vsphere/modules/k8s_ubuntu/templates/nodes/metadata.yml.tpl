local-hostname: ${HOST}
instance-id: ${HOST}
network:
  version: 2
  ethernets:
    ens192:
      dhcp4: true #true to use dhcp
