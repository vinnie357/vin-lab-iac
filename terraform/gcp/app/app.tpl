#!/bin/bash
apt-get update -y
apt-get install -y docker.io
docker run -d -p ${port}:80 --net=host --restart unless-stopped -e F5DEMO_APP=website -e F5DEMO_NODENAME='F5 GCP' -e F5DEMO_COLOR=ffd734 -e F5DEMO_NODENAME_SSL='F5 GCP (SSL)' -e F5DEMO_COLOR_SSL=a0bf37 chen23/f5-demo-app:ssl}