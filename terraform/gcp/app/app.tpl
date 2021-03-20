#!/bin/bash
# logging
LOG_FILE="/var/log/startup-script.log"
if [ ! -e $LOG_FILE ]
then
     sudo touch $LOG_FILE
     exec &>>$LOG_FILE
else
    #if file exists, exit as only want to run once
    exit
fi

exec 1>$LOG_FILE 2>&1
#
# sudo apt-get update -y
# sudo apt-get install -y docker.io
# f5 demo app
docker run -d -p ${port}:80 --net=host --restart unless-stopped -e F5DEMO_APP=website -e F5DEMO_NODENAME='F5 GCP' -e F5DEMO_COLOR=ffd734 -e F5DEMO_NODENAME_SSL='F5 GCP (SSL)' -e F5DEMO_COLOR_SSL=a0bf37 chen23/f5-demo-app:ssl
# juice shop
docker run -d --restart always  -p 3000:3000 bkimminich/juice-shop
