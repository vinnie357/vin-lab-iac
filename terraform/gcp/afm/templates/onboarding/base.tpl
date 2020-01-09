#!/bin/bash
deviceId=$(curl -s -f --retry 20 'http://metadata.google.internal/computeMetadata/v1/instance/attributes/deviceId' -H 'Metadata-Flavor: Google')
# logging
LOG_FILE=${onboard_log}
if [ ! -e $LOG_FILE ]
then
     touch $LOG_FILE
     exec &>>$LOG_FILE
else
    #if file exists, exit as only want to run once
    exit
fi
#
exec 1>$LOG_FILE 2>&1
#
function mcpdWait () {
    echo  "wait for mcpd"
    checks=0
    while [[ "$checks" -lt 120 ]]; do 
        echo "checking mcpd"
        tmsh -a show sys mcp-state field-fmt | grep -q running
    if [ $? == 0 ]; then
        echo "mcpd ready"
        break
    fi
    echo "mcpd not ready yet"
    let checks=checks+1
    sleep 10
    done
}
# call mcpd wait
mcpdWait
#
# create admin account and password
echo "create admin account"
admin_username='${uname}'
admin_password='${upassword}'
# echo  -e "create cli transaction;
tmsh create auth user $admin_username password $admin_password shell bash partition-access add { all-partitions { role admin } };
# modify /sys db systemauth.primaryadminuser value $admin_username;
# submit cli transaction" | tmsh -q
tmsh list auth user $admin_username
tmsh save sys config
# copy ssh key
mkdir -p /home/$admin_username/.ssh/
cp /home/admin/.ssh/authorized_keys /home/xadmin/.ssh/authorized_keys
echo " admin account changed"
#
# vars
#
CREDS="$admin_username:$admin_password"
DO_URL='${DO_onboard_URL}'
DO_FN=$(basename "$DO_URL")
AS3_URL='${AS3_URL}'
AS3_FN=$(basename "$AS3_URL")
#atc="f5-declarative-onboarding f5-appsvcs-extension f5-telemetry-streaming"
atc="f5-declarative-onboarding f5-appsvcs-extension"
# constants
mgmt_port=`tmsh list sys httpd ssl-port | grep ssl-port | sed 's/ssl-port //;s/ //g'`
authUrl="/mgmt/shared/authn/login"
rpmInstallUrl="/mgmt/shared/iapp/package-management-tasks"
rpmFilePath="/var/config/rest/downloads"
# do
doUrl="/mgmt/shared/declarative-onboarding"
doCheckUrl="/mgmt/shared/declarative-onboarding/info"
doTaskUrl="/shared/declarative-onboarding/task"
# as3
as3Url="/mgmt/shared/appsvcs/declare"
as3CheckUrl="/mgmt/shared/appsvcs/info"
# ts
tsUrl="/mgmt/shared/telemetry/declare"
tsCheckUrl="/mgmt/shared/telemetry/info" 