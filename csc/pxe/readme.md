# https://hub.docker.com/r/linuxserver/netbootxyz

https://www.technorabilia.com/dockerized-netboot-xyz-on-synology-nas-and-router/

## unifi
DHCP and pointers for pxe
```
Unifi Security Gateway (with the controller)
Networks -> LAN (or the network you want to boot from) -> ADVANCED DHCP OPTIONS

tick Enable network boot
Server- YOURSERVERIP
Filename- netboot.xyz.kpxe
```
## synology
source for isos?

create folder for netbootxyz storage

add docker

pull linuxserver-netbootxyz:latest

add ports:
web interface             3000 tcp
pxe                       69 UDP
nginx file server browser 80 tcp
