#!/bin/bash

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

exec 1>$LOG_FILE 2>&1
#
startTime=$(date +%s)
echo "timestamp start: $(date)"
function timer () {
    echo "Time Elapsed: $(( ${1} / 3600 ))h $(( (${1} / 60) % 60 ))m $(( ${1} % 60 ))s"
}
#
# get cloud libs for gce
mkdir  -p /config/cloud/gce
echo  'Y2xpIHNjcmlwdCAvQ29tbW9uL3ZlcmlmeUhhc2ggewpwcm9jIHNjcmlwdDo6cnVuIHt9IHsKICAgICAgICBpZiB7W2NhdGNoIHsKICAgICAgICAgICAgc2V0IGhhc2hlcyhmNS1jbG91ZC1saWJzLnRhci5neikgYWRjZmEwNmMxOGQyNmMwOTIyYWQxNDFhZDMxYjliNjIxZjNlMTcxM2EyMWZiODE5ZjBiM2I0MjUxMTI5NjQ5NjcxNzI3MTAwMzVmOTdkMGZiOWRmY2RlZDgxMGFlMzI4MGY0NjZkNGI1MWJmNWExMDlhZTg0YmMzNTQyMTcwNjEKICAgICAgICAgICAgc2V0IGhhc2hlcyhmNS1jbG91ZC1saWJzLWF3cy50YXIuZ3opIDJiOTM0MzA3NDc3ZmFmNzcyZTE1NThhYjM2MzY3MTY5ODEyMTVkNmIxNWYyYTE4NDc1MDQ3MzkxMWQxZDM4YmZiZDZhMmRjNzk2MTRiMWQxNTc1ZGNlOGYzODI0ZWQ4MDVkYWEzZDljYTQ4YzdlOTRjNjY5MmYwM2I5ZTRlZDdhCiAgICAgICAgICAgIHNldCBoYXNoZXMoZjUtY2xvdWQtbGlicy1henVyZS50YXIuZ3opIDNlY2Q4ZjM3MzcxNGE3NGUyMzlmOGJmNmIyNTFiYzIxMmI4YWVlMWMwMzFkM2U5YzA2ZGEzMDRiMDFlZjZhNzE1ZTA0MTUzMjhmNTUyM2JkM2ExYmVhOGVlYjg1M2IyNDAxYjc0ZjkwNGJmODhiN2FiY2Q0OGQ0NTg0YTAwZGJkCiAgICAgICAgICAgIHNldCBoYXNoZXMoZjUtY2xvdWQtbGlicy1nY2UudGFyLmd6KSBhNWNmYWVkMWZlMzNkYTY3N2IzZjEwZGMxYTdjYTgyZjU3MzlmZjI0ZTQ1ZTkxYjNhOGY3YjA2ZDZiMmUyODBlNWYxZWFmNWZlMmQzMzAwOWIyY2M2N2MxMGYyZDkwNmFhYjI2Zjk0MmQ1OTFiNjhmYThhN2ZkZGZkNTRhMGVmZQogICAgICAgICAgICBzZXQgaGFzaGVzKGY1LWNsb3VkLWxpYnMtb3BlbnN0YWNrLnRhci5neikgNWM4M2ZlNmE5M2E2ZmNlYjVhMmU4NDM3YjVlZDhjYzlmYWY0YzE2MjFiZmM5ZTZhMDc3OWY2YzIxMzdiNDVlYWI4YWUwZTdlZDc0NWM4Y2Y4MjFiOTM3MTI0NWNhMjk3NDljYTBiN2U1NjYzOTQ5ZDc3NDk2Yjg3MjhmNGIwZjkKICAgICAgICAgICAgc2V0IGhhc2hlcyhmNS1jbG91ZC1saWJzLWNvbnN1bC50YXIuZ3opIGEzMmFhYjM5NzA3M2RmOTJjYmJiYTUwNjdlNTgyM2U5YjVmYWZjYTg2MmEyNThiNjBiNmI0MGFhMDk3NWMzOTg5ZDFlMTEwZjcwNjE3N2IyZmZiZTRkZGU2NTMwNWEyNjBhNTg1NjU5NGNlN2FkNGVmMGM0N2I2OTRhZTRhNTEzCiAgICAgICAgICAgIHNldCBoYXNoZXMoYXNtLXBvbGljeS1saW51eC50YXIuZ3opIDYzYjVjMmE1MWNhMDljNDNiZDg5YWYzNzczYmJhYjg3YzcxYTZlN2Y2YWQ5NDEwYjIyOWI0ZTBhMWM0ODNkNDZmMWE5ZmZmMzlkOTk0NDA0MWIwMmVlOTI2MDcyNDAyNzQxNGRlNTkyZTk5ZjRjMjQ3NTQxNTMyM2UxOGE3MmUwCiAgICAgICAgICAgIHNldCBoYXNoZXMoZjUuaHR0cC52MS4yLjByYzQudG1wbCkgNDdjMTlhODNlYmZjN2JkMWU5ZTljMzVmMzQyNDk0NWVmODY5NGFhNDM3ZWVkZDE3YjZhMzg3Nzg4ZDRkYjEzOTZmZWZlNDQ1MTk5YjQ5NzA2NGQ3Njk2N2IwZDUwMjM4MTU0MTkwY2EwYmQ3Mzk0MTI5OGZjMjU3ZGY0ZGMwMzQKICAgICAgICAgICAgc2V0IGhhc2hlcyhmNS5odHRwLnYxLjIuMHJjNi50bXBsKSA4MTFiMTRiZmZhYWI1ZWQwMzY1ZjAxMDZiYjVjZTVlNGVjMjIzODU2NTVlYTNhYzA0ZGUyYTM5YmQ5OTQ0ZjUxZTM3MTQ2MTlkYWU3Y2E0MzY2MmM5NTZiNTIxMjIyODg1OGYwNTkyNjcyYTI1NzlkNGE4Nzc2OTE4NmUyY2JmZQogICAgICAgICAgICBzZXQgaGFzaGVzKGY1Lmh0dHAudjEuMi4wcmM3LnRtcGwpIDIxZjQxMzM0MmU5YTdhMjgxYTBmMGUxMzAxZTc0NWFhODZhZjIxYTY5N2QyZTZmZGMyMWRkMjc5NzM0OTM2NjMxZTkyZjM0YmYxYzJkMjUwNGMyMDFmNTZjY2Q3NWM1YzEzYmFhMmZlNzY1MzIxMzY4OWVjM2M5ZTI3ZGZmNzdkCiAgICAgICAgICAgIHNldCBoYXNoZXMoZjUuYXdzX2FkdmFuY2VkX2hhLnYxLjMuMHJjMS50bXBsKSA5ZTU1MTQ5YzAxMGMxZDM5NWFiZGFlM2MzZDJjYjgzZWMxM2QzMWVkMzk0MjQ2OTVlODg2ODBjZjNlZDVhMDEzZDYyNmIzMjY3MTFkM2Q0MGVmMmRmNDZiNzJkNDE0YjRjYjhlNGY0NDVlYTA3MzhkY2JkMjVjNGM4NDNhYzM5ZAogICAgICAgICAgICBzZXQgaGFzaGVzKGY1LmF3c19hZHZhbmNlZF9oYS52MS40LjByYzEudG1wbCkgZGUwNjg0NTUyNTc0MTJhOTQ5ZjFlYWRjY2FlZTg1MDYzNDdlMDRmZDY5YmZiNjQ1MDAxYjc2ZjIwMDEyNzY2OGU0YTA2YmUyYmJiOTRlMTBmZWZjMjE1Y2ZjMzY2NWIwNzk0NWU2ZDczM2NiZTFhNGZhMWI4OGU4ODE1OTAzOTYKICAgICAgICAgICAgc2V0IGhhc2hlcyhmNS5hd3NfYWR2YW5jZWRfaGEudjEuNC4wcmMyLnRtcGwpIDZhYjBiZmZjNDI2ZGY3ZDMxOTEzZjlhNDc0YjFhMDc4NjA0MzVlMzY2YjA3ZDc3YjMyMDY0YWNmYjI5NTJjMWYyMDdiZWFlZDc3MDEzYTE1ZTQ0ZDgwZDc0ZjMyNTNlN2NmOWZiYmUxMmE5MGVjNzEyOGRlNmZhY2QwOTdkNjhmCiAgICAgICAgICAgIHNldCBoYXNoZXMoZjUuYXdzX2FkdmFuY2VkX2hhLnYxLjQuMHJjMy50bXBsKSAyZjIzMzliNGJjM2EyM2M5Y2ZkNDJhYWUyYTZkZTM5YmEwNjU4MzY2ZjI1OTg1ZGUyZWE1MzQxMGE3NDVmMGYxOGVlZGM0OTFiMjBmNGE4ZGJhOGRiNDg5NzAwOTZlMmVmZGNhN2I4ZWZmZmExYTgzYTc4ZTVhYWRmMjE4YjEzNAogICAgICAgICAgICBzZXQgaGFzaGVzKGY1LmF3c19hZHZhbmNlZF9oYS52MS40LjByYzQudG1wbCkgMjQxOGFjOGIxZjE4ODRjNWMwOTZjYmFjNmE5NGQ0MDU5YWFhZjA1OTI3YTZhNDUwOGZkMWYyNWI4Y2M2MDc3NDk4ODM5ZmJkZGE4MTc2ZDJjZjJkMjc0YTI3ZTZhMWRhZTJhMWUzYTBhOTk5MWJjNjVmYzc0ZmMwZDAyY2U5NjMKICAgICAgICAgICAgc2V0IGhhc2hlcyhmNS5hd3NfYWR2YW5jZWRfaGEudjEuNC4wcmM1LnRtcGwpIDVlNTgyMTg3YWUxYTYzMjNlMDk1ZDQxZWRkZDQxMTUxZDZiZDM4ZWI4M2M2MzQ0MTBkNDUyN2EzZDBlMjQ2YThmYzYyNjg1YWIwODQ5ZGUyYWRlNjJiMDI3NWY1MTI2NGQyZGVhY2NiYzE2Yjc3MzQxN2Y4NDdhNGExZWE5YmM0CiAgICAgICAgICAgIHNldCBoYXNoZXMoYXNtLXBvbGljeS50YXIuZ3opIDJkMzllYzYwZDAwNmQwNWQ4YTE1NjdhMWQ4YWFlNzIyNDE5ZThiMDYyYWQ3N2Q2ZDlhMzE2NTI5NzFlNWU2N2JjNDA0M2Q4MTY3MWJhMmE4YjEyZGQyMjllYTQ2ZDIwNTE0NGY3NTM3NGVkNGNhZTU4Y2VmYThmOWFiNjUzM2U2CiAgICAgICAgICAgIHNldCBoYXNoZXMoZGVwbG95X3dhZi5zaCkgMWEzYTNjNjI3NGFiMDhhN2RjMmNiNzNhZWRjOGQyYjJhMjNjZDllMGViMDZhMmUxNTM0YjM2MzJmMjUwZjFkODk3MDU2ZjIxOWQ1YjM1ZDNlZWQxMjA3MDI2ZTg5OTg5Zjc1NDg0MGZkOTI5NjljNTE1YWU0ZDgyOTIxNGZiNzQKICAgICAgICAgICAgc2V0IGhhc2hlcyhmNS5wb2xpY3lfY3JlYXRvci50bXBsKSAwNjUzOWUwOGQxMTVlZmFmZTU1YWE1MDdlY2I0ZTQ0M2U4M2JkYjFmNTgyNWE5NTE0OTU0ZWY2Y2E1NmQyNDBlZDAwYzdiNWQ2N2JkOGY2N2I4MTVlZTlkZDQ2NDUxOTg0NzAxZDA1OGM4OWRhZTI0MzRjODk3MTVkMzc1YTYyMAogICAgICAgICAgICBzZXQgaGFzaGVzKGY1LnNlcnZpY2VfZGlzY292ZXJ5LnRtcGwpIDQ4MTFhOTUzNzJkMWRiZGJiNGY2MmY4YmNjNDhkNGJjOTE5ZmE0OTJjZGEwMTJjODFlM2EyZmU2M2Q3OTY2Y2MzNmJhODY3N2VkMDQ5YTgxNGE5MzA0NzMyMzRmMzAwZDNmOGJjZWQyYjBkYjYzMTc2ZDUyYWM5OTY0MGNlODFiCiAgICAgICAgICAgIHNldCBoYXNoZXMoZjUuY2xvdWRfbG9nZ2VyLnYxLjAuMC50bXBsKSA2NGEwZWQzYjVlMzJhMDM3YmE0ZTcxZDQ2MDM4NWZlOGI1ZTFhZWNjMjdkYzBlODUxNGI1MTE4NjM5NTJlNDE5YTg5ZjRhMmE0MzMyNmFiYjU0M2JiYTliYzM0Mzc2YWZhMTE0Y2VkYTk1MGQyYzNiZDA4ZGFiNzM1ZmY1YWQyMAogICAgICAgICAgICBzZXQgaGFzaGVzKGY1LWFwcHN2Y3MtMy41LjEtNS5ub2FyY2gucnBtKSBiYTcxYzZlMWM1MmQwYzcwNzdjZGIyNWE1ODcwOWI4ZmI3YzM3YjM0NDE4YTgzMzhiYmY2NzY2ODMzOTY3NmQyMDhjMWE0ZmVmNGU1NDcwYzE1MmFhYzg0MDIwYjRjY2I4MDc0Y2UzODdkZTI0YmUzMzk3MTEyNTZjMGZhNzhjOAoKICAgICAgICAgICAgc2V0IGZpbGVfcGF0aCBbbGluZGV4ICR0bXNoOjphcmd2IDFdCiAgICAgICAgICAgIHNldCBmaWxlX25hbWUgW2ZpbGUgdGFpbCAkZmlsZV9wYXRoXQoKICAgICAgICAgICAgaWYgeyFbaW5mbyBleGlzdHMgaGFzaGVzKCRmaWxlX25hbWUpXX0gewogICAgICAgICAgICAgICAgdG1zaDo6bG9nIGVyciAiTm8gaGFzaCBmb3VuZCBmb3IgJGZpbGVfbmFtZSIKICAgICAgICAgICAgICAgIGV4aXQgMQogICAgICAgICAgICB9CgogICAgICAgICAgICBzZXQgZXhwZWN0ZWRfaGFzaCAkaGFzaGVzKCRmaWxlX25hbWUpCiAgICAgICAgICAgIHNldCBjb21wdXRlZF9oYXNoIFtsaW5kZXggW2V4ZWMgL3Vzci9iaW4vb3BlbnNzbCBkZ3N0IC1yIC1zaGE1MTIgJGZpbGVfcGF0aF0gMF0KICAgICAgICAgICAgaWYgeyAkZXhwZWN0ZWRfaGFzaCBlcSAkY29tcHV0ZWRfaGFzaCB9IHsKICAgICAgICAgICAgICAgIGV4aXQgMAogICAgICAgICAgICB9CiAgICAgICAgICAgIHRtc2g6OmxvZyBlcnIgIkhhc2ggZG9lcyBub3QgbWF0Y2ggZm9yICRmaWxlX3BhdGgiCiAgICAgICAgICAgIGV4aXQgMQogICAgICAgIH1dfSB7CiAgICAgICAgICAgIHRtc2g6OmxvZyBlcnIge1VuZXhwZWN0ZWQgZXJyb3IgaW4gdmVyaWZ5SGFzaH0KICAgICAgICAgICAgZXhpdCAxCiAgICAgICAgfQogICAgfQogICAgc2NyaXB0LXNpZ25hdHVyZSBkVUpYamhPMmNpWVZNbHJwaGMxMGZxWTEwTHBScEtlRXZlRDdQYXhBYlB2VWtNL1lsNHhJUHdlYnlPTktFRFhWNUFkTXNxUlEyL05FQkUvSEo3TWQ2RDZxd3ZFMmRBZCtkN1Rka2xYZ29IajFwS0RJNEhnaFJiS3RqMVlwWkNJZ2cweGZjb0psVTdzRXlIaFJZRUs1M2JHLy9ENWFLVjVVbnZTOThPTEV1b2lLQU9tNjVXdzJGWjFqeWJQaUFhNE1NNlRzMzB0ekNDRmZFK2t3VnlKSytQR0Y4Zks1YVR1aktnNmFXekJjVkl1eFY2MmJNWnZYclR0R1JZdWFXdXc0RHloeGdDZ2xuWkVpUTRyVTE5dHhjVkd2MGRGZE93eFdNaU03UkJxMUR0V2FVcW5RSlNOcW5pTnl5MUpCK0RzekRycEtuT2xyUVB3YmtxNmhsZDBGdmc9PQogICAgc2lnbmluZy1rZXkgL0NvbW1vbi9mNS1pcnVsZQp9' | base64 -d > /config/verifyHash
cat  <<EOF > /config/installCloudLibs.sh
#!/bin/bash
echo  about to execute
checks=0
while [ $checks -lt 120 ]; do echo checking mcpd
    tmsh -a show sys mcp-state field-fmt | grep -q running
   if [ $? == 0 ]; then
       echo mcpd ready
       break
   fi
   echo mcpd not ready yet
   let checks=checks+1
   sleep 10
done 
echo  loading verifyHash script
if ! tmsh load sys config merge file /config/verifyHash; then
   echo cannot validate signature of /config/verifyHash
   exit
fi 
echo  loaded verifyHash
filesToVerify="/config/cloud/f5-cloud-libs.tar.gz /config/cloud/f5-cloud-libs-gce.tar.gz /config/cloud/f5.service_discovery.tmpl"
#declare  -a filesToVerify=('/config/cloud/f5-cloud-libs.tar.gz' '/config/cloud/f5-cloud-libs-gce.tar.gz' '/config/cloud/f5.service_discovery.tmpl')
for fileToVerify in $filesToVerify
do
   echo verifying "$fileToVerify"
   if ! tmsh run cli script verifyHash "$fileToVerify"; then
       echo "$fileToVerify" is not valid
       exit 1
   fi
   echo verified "$fileToVerify"
done 
mkdir  -p /config/cloud/gce/node_modules/@f5devcentral
echo  expanding f5-cloud-libs.tar.gz\n
tar xvfz /config/cloud/f5-cloud-libs.tar.gz -C /config/cloud/gce/node_modules/@f5devcentral
echo  expanding f5-cloud-libs-gce.tar.gz
tar xvfz /config/cloud/f5-cloud-libs-gce.tar.gz -C /config/cloud/gce/node_modules/@f5devcentral
echo  cloud libs install complete
touch /config/cloud/cloudLibsReady
EOF
# CHECK TO SEE NETWORK IS READY
count=0
while true
do
  STATUS=$(curl -s -k -I example.com | grep HTTP)
  if [[ $STATUS == *"200"* ]]; then
    echo "internet access check passed"
    break
  elif [ $count -le 6 ]; then
    echo "Status code: $STATUS  Not done yet..."
    count=$[$count+1]
  else
    echo "GIVE UP..."
    break
  fi
  sleep 10
done

curl -s -f --retry 20 -o /config/cloud/f5-cloud-libs.tar.gz https://cdn.f5.com/product/cloudsolutions/f5-cloud-libs/v4.12.0/f5-cloud-libs.tar.gz
curl -s -f --retry 20 -o /config/cloud/f5-cloud-libs-gce.tar.gz https://cdn.f5.com/product/cloudsolutions/f5-cloud-libs-gce/v2.4.0/f5-cloud-libs-gce.tar.gz
curl -s -f --retry 20 -o /config/cloud/f5.service_discovery.tmpl https://cdn.f5.com/product/cloudsolutions/iapps/common/f5-service-discovery/v2.3.2/f5.service_discovery.tmpl

chmod 755 /config/verifyHash
chmod 755 /config/installCloudLibs.sh
mkdir  -p /var/log/cloud/google
touch /config/cloud/gce/FIRST_BOOT_COMPLETE
nohup /config/installCloudLibs.sh >> /var/log/cloud/google/install.log < /dev/null
#
# end get cloud libs for gce
#
# get device id for do
deviceId=$(curl -s -f --retry 20 'http://metadata.google.internal/computeMetadata/v1/instance/attributes/deviceId' -H 'Metadata-Flavor: Google')
#
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

function delay () {
# $1 count #2 item
count=0
while [[ $count  -lt $1 ]]; do 
    echo "still working... $2"
    sleep 1
    count=$[$count+1]
done
}
#
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
cp /home/admin/.ssh/authorized_keys /home/$admin_username/.ssh/authorized_keys
echo " admin account changed"
# change admin password only
# echo "change admin password"
# echo "admin:$admin_password" | chpasswd
# echo "changed admin password"
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
doTaskUrl="/mgmt/shared/declarative-onboarding/task"
# as3
as3Url="/mgmt/shared/appsvcs/declare"
as3CheckUrl="/mgmt/shared/appsvcs/info"
# ts
tsUrl="/mgmt/shared/telemetry/declare"
tsCheckUrl="/mgmt/shared/telemetry/info" 
# declaration content
cat > /config/do1.json <<EOF
${DO1_Document}
EOF
cat > /config/do2.json <<EOF
${DO2_Document}
EOF
cat > /config/as3.json <<EOF
${AS3_Document}
EOF

DO_URL_POST="/mgmt/shared/declarative-onboarding"
AS3_URL_POST="/mgmt/shared/appsvcs/declare"
#
# BIG-IPS ONBOARD SCRIPT
#
# CHECK TO SEE NETWORK IS READY
count=0
while true
do
  STATUS=$(curl -s -k -I example.com | grep HTTP)
  if [[ $STATUS == *"200"* ]]; then
    echo "internet access check passed"
    break
  elif [ $count -le 6 ]; then
    echo "Status code: $STATUS  Not done yet..."
    count=$[$count+1]
  else
    echo "GIVE UP..."
    break
  fi
  sleep 10
done
# download latest atc tools

for tool in $atc
do
    
    echo "downloading $tool"
    files=$(/usr/bin/curl -sk --interface mgmt https://api.github.com/repos/F5Networks/$tool/releases/latest | jq -r '.assets[] | select(.name | contains (".rpm")) | .browser_download_url')
    for file in $files
    do
    echo "download: $file"
    name=$(basename $file )
    # make download dir
    mkdir -p /var/config/rest/downloads
    result=$(/usr/bin/curl -Lsk  $file -o /var/config/rest/downloads/$name)
    done
done

# install atc tools
rpms=$(find $rpmFilePath -name "*.rpm" -type f)
for rpm in $rpms
do
  filename=$(basename $rpm)
  echo "installing $filename"
  if [ -f $rpmFilePath/$filename ]; then
     postBody="{\"operation\":\"INSTALL\",\"packageFilePath\":\"$rpmFilePath/$filename\"}"
     while true
     do
        iappApiStatus=$(curl -i -u $CREDS  http://localhost:8100$rpmInstallUrl | grep HTTP | awk '{print $2}')
        case $iappApiStatus in 
            404)
                echo "api not ready status: $iappApiStatus"
                sleep 2
                ;;
            200)
                echo "api ready starting install task $filename"
                install=$(restcurl -u $CREDS -X POST -d $postBody $rpmInstallUrl | jq -r .id )
                break
                ;;
              *)
                echo "other error status: $iappApiStatus"
                debug=$(restcurl -u $CREDS $rpmInstallUrl)
                echo "ipp install debug: $debug"
                ;;
        esac
    done
  else
    echo " file: $filename not found"
  fi 
  while true
  do
    status=$(restcurl -u $CREDS $rpmInstallUrl/$install | jq -r .status)
    case $status in 
        FINISHED)
            # finished
            echo " rpm: $filename task: $install status: $status"
            break
            ;;
        STARTED)
            # started
            echo " rpm: $filename task: $install status: $status"
            ;;
        RUNNING)
            # running
            echo " rpm: $filename task: $install status: $status"
            ;;
        FAILED)
            # failed
            error=$(restcurl -u $CREDS $rpmInstallUrl/$install | jq .errorMessage)
            echo "failed $filename task: $install error: $error"
            break
            ;;
        *)
            # other
            debug=$(restcurl -u $CREDS $rpmInstallUrl/$install | jq . )
            echo "failed $filename task: $install error: $debug"
            ;;
        esac
    sleep 2
    done
done

function getDoStatus() {
    task=$1
    doStatusType=$(restcurl -u $CREDS -X GET $doTaskUrl/$task | jq -r type )
    if [ "$doStatusType" == "object" ]; then
        doStatus=$(restcurl -u $CREDS -X GET $doTaskUrl/$task | jq -r .result.status)
        echo $doStatus
    elif [ "$doStatusType" == "array" ]; then
        doStatus=$(restcurl -u $CREDS -X GET $doTaskUrl/$task | jq -r .[].result.status)
        echo $doStatus
    else
        echo "unknown type:$doStatusType"
    fi
}
function checkDO() {
    # Check DO Ready
    count=0
    while [ $count -le 4 ]
    do
    #doStatus=$(curl -i -u $CREDS http://localhost:8100$doCheckUrl | grep HTTP | awk '{print $2}')
    doStatusType=$(restcurl -u $CREDS -X GET $doCheckUrl | jq -r type )
    if [ "$doStatusType" == "object" ]; then
        doStatus=$(restcurl -u $CREDS -X GET $doCheckUrl | jq -r .code)
        if [ $? == 1 ]; then
            doStatus=$(restcurl -u $CREDS -X GET $doCheckUrl | jq -r .result.code)
        fi
    elif [ "$doStatusType" == "array" ]; then
        doStatus=$(restcurl -u $CREDS -X GET $doCheckUrl | jq -r .[].result.code)
    else
        echo "unknown type:$doStatusType"
    fi
    echo "status $doStatus"
    if [[ $doStatus == "200" ]]; then
        #version=$(restcurl -u $CREDS -X GET $doCheckUrl | jq -r .version)
        version=$(restcurl -u $CREDS -X GET $doCheckUrl | jq -r .[].version)
        echo "Declarative Onboarding $version online "
        break
    elif [[ $doStatus == "404" ]]; then
        echo "DO Status: $doStatus"
        bigstart restart restnoded
        sleep 60
        bigstart status restnoded | grep running
        status=$?
        echo "restnoded:$status"
    else
        echo "DO Status $doStatus"
        count=$[$count+1]
    fi
    sleep 10
    done
}
function checkAS3() {
    # Check AS3 Ready
    count=0
    while [ $count -le 4 ]
    do
    #as3Status=$(curl -i -u $CREDS http://localhost:8100$as3CheckUrl | grep HTTP | awk '{print $2}')
    as3Status=$(restcurl -u $CREDS -X GET $as3CheckUrl | jq -r .code)
    if  [ "$as3Status" == "null" ] || [ -z "$as3Status" ]; then
        type=$(restcurl -u $CREDS -X GET $as3CheckUrl | jq -r type )
        if [ "$type" == "object" ]; then
            as3Status="200"
        fi
    fi
    if [[ $as3Status == "200" ]]; then
        version=$(restcurl -u $CREDS -X GET $as3CheckUrl | jq -r .version)
        echo "As3 $version online "
        break
    elif [[ $as3Status == "404" ]]; then
        echo "AS3 Status $as3Status"
        bigstart restart restnoded
        sleep 60
        bigstart status restnoded | grep running
        status=$?
        echo "restnoded:$status"
    else
        echo "AS3 Status $as3Status"
        count=$[$count+1]
    fi
    sleep 10
    done
}
function checkTS() {
    # Check TS Ready
    count=0
    while [ $count -le 4 ]
    do
    tsStatus=$(curl -i -u $CREDS http://localhost:8100$tsCheckUrl | grep HTTP | awk '{print $2}')
    if [[ $tsStatus == "200" ]]; then
        version=$(restcurl -u $CREDS -X GET $tsCheckUrl | jq -r .version)
        echo "Telemetry Streaming $version online "
        break
    else
        echo "TS Status $tsStatus"
        count=$[$count+1]
    fi
    sleep 10
    done
}
#
# start network
MGMTADDRESS=$(curl -s -f --retry 20 'http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip' -H 'Metadata-Flavor: Google')
MGMTMASK=$(curl -s -f --retry 20 'http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/subnetmask' -H 'Metadata-Flavor: Google')
MGMTGATEWAY=$(curl -s -f --retry 20 'http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/gateway' -H 'Metadata-Flavor: Google')

INT2ADDRESS=$(curl -s -f --retry 20 'http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/1/ip' -H 'Metadata-Flavor: Google')
INT2MASK=$(curl -s -f --retry 20 'http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/1/subnetmask' -H 'Metadata-Flavor: Google')
INT2GATEWAY=$(curl -s -f --retry 20 'http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/1/gateway' -H 'Metadata-Flavor: Google')

INT3ADDRESS=$(curl -s -f --retry 20 'http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/2/ip' -H 'Metadata-Flavor: Google')
INT3MASK=$(curl -s -f --retry 20 'http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/2/subnetmask' -H 'Metadata-Flavor: Google')
INT3GATEWAY=$(curl -s -f --retry 20 'http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/2/gateway' -H 'Metadata-Flavor: Google')

MGMTNETWORK=$(/bin/ipcalc -n $MGMTADDRESS $MGMTMASK | cut -d= -f2)
INT2NETWORK=$(/bin/ipcalc -n $INT2ADDRESS $INT2MASK | cut -d= -f2)
INT3NETWORK=$(/bin/ipcalc -n $INT3ADDRESS $INT3MASK | cut -d= -f2)
# network data
echo " mgmt:$MGMTADDRESS,$MGMTMASK,$MGMTGATEWAY"
echo "external:$INT2ADDRESS,$INT2MASK,$INT2GATEWAY"
echo "internal: $INT3ADDRESS,$INT3MASK,$INT3GATEWAY"
echo "cidr: $MGMTNETWORK,$INT2NETWORK,$INT3NETWORK"

# mgmt
# mgmt reboot workaround
# https://support.f5.com/csp/article/K11948
# https://support.f5.com/csp/article/K47835034
# chmod +w /config/startup
# echo "/config/startup_script_sol11948.sh &" >> /config/startup
# cat  <<EOF > /config/startup_script_sol11948.sh
# #!/bin/bash
# exec &>>/var/log/mgmt-startup-script.log
# . /config/mgmt.sh
# done
# EOF
# chmod +x /config/startup_script_sol11948.sh
# cat  <<EOF > /config/mgmt.sh
# #!/bin/bash
# exec &>>/var/log/mgmt-startup-script.log
# echo  "wait for mcpd"
# checks=0
# while [[ "$checks" -lt 120 ]]; do 
#     echo "checking mcpd"
#     mcpd=$(tmsh -a show sys mcp-state field-fmt | grep running | awk '{print $2}')
#    if [ "$mcpd" == "running" ]; then
#        echo "mcpd ready"
#        tries=0
#        while [[ "$tries" -lt 60 ]]; do
#             gw="$(echo "$(ifconfig mgmt | grep 'inet' | cut -d: -f2 | awk '{print $2}' | cut -d"." -f1-3)")"".1"
#             ip route change default via $gw dev mgmt mtu 1460
#             mtu=$(ip route show | grep default | grep mgmt | awk '{ print $7}')
#         if [ $mtu == 1460 ]; then
#             ip route show | grep default
#             echo "mgmt route done"
#             exit
#         else
#             echo "not ready"
#             sleep 10
#             let tries=tries+1
#         fi
#        done
#    fi
#    echo "mcpd not ready yet: $mcpd"
#    let checks=checks+1
#    sleep 10
# done
# EOF
# chmod +x /config/mgmt.sh
# end management reboot workaround
echo "set management"
echo  -e "create cli transaction;
modify sys global-settings mgmt-dhcp disabled;
submit cli transaction" | tmsh -q
echo  -e "create cli transaction;
delete sys management-route default;
delete sys management-route dhclient_route1;
delete sys management-route dhclient_route2;
delete sys management-ip $MGMTADDRESS/32;
submit cli transaction" | tmsh -q
echo  -e "create cli transaction;
create sys management-ip $MGMTADDRESS/32;
create sys management-route mgmt_gw network $MGMTGATEWAY/32 type interface;
create sys management-route mgmt_net network $MGMTNETWORK/$MGMTMASK gateway $MGMTGATEWAY;
create sys management-route default gateway $MGMTGATEWAY mtu 1460;
submit cli transaction" | tmsh -q
# networks
echo "set tmm networks"
echo  -e "create cli transaction;
create net vlan external interfaces add { 1.1 } mtu 1460;
create net self external-self address $INT2ADDRESS/32 vlan external;
create net route ext_gw_interface network $INT2GATEWAY/32 interface external;
create net route ext_rt network $INT2NETWORK/$INT2MASK gw $INT2GATEWAY;
create net route default gw $INT2GATEWAY;
create net vlan internal interfaces add { 1.2 } mtu 1460;
create net self internal-self address $INT3ADDRESS/32 vlan internal allow-service default;
create net route int_gw_interface network $INT3GATEWAY/32 interface internal;
create net route int_rt network $INT3NETWORK/$INT3MASK gw $INT3GATEWAY;
submit cli transaction" | tmsh -q
tmsh save /sys config
echo "done creating tmsh networking"
# end network
#
# modify DO
function nextip(){
    IP=$1
    count=$2
    IP_HEX=$(printf '%.2X%.2X%.2X%.2X\n' `echo $IP | sed -e 's/\./ /g'`)
    NEXT_IP_HEX=$(printf %.8X `echo $(( 0x$IP_HEX + $count ))`)
    NEXT_IP=$(printf '%d.%d.%d.%d\n' `echo $NEXT_IP_HEX | sed -r 's/(..)/0x\1 /g'`)
    echo "$NEXT_IP"
}
function getPeerAddress() {
selfip=$1
count=$2
for i in $(seq 1 1); do
    IP=$(nextip $selfip $count)
    echo $IP
done
}

# internal address on box one will increment
doReplaceOne=$(getPeerAddress $INT3ADDRESS 1)
doReplaceTwo=$(getPeerAddress $INT3ADDRESS -1)
echo " internal address: $INT3ADDRESS "
echo "sync_ip_01:$doReplaceOne, sync_ip_02:$doReplaceTwo"
sed -i "s/-remote-peer-addr-/$doReplaceOne/g" /config/do1.json
sed -i "s/-mgmt-gw-addr-/$MGMTGATEWAY/g" /config/do1.json
# internal address on box two will decrement
sed -i "s/-remote-peer-addr-/$doReplaceTwo/g" /config/do2.json
sed -i "s/-mgmt-gw-addr-/$MGMTGATEWAY/g" /config/do2.json
# end modify DO
# modify as3
as3ReplacePool=$(getPeerAddress $INT2ADDRESS -1)
echo " virtual address $INT2ADDRESS "
sed -i "s/-external-virtual-address-/$INT2ADDRESS/g" /config/as3.json
sed -i "s/-internal-app-address-/$as3ReplacePool/g" /config/as3.json
# end modify as3
function runDO() {
    count=0
    while [ $count -le 4 ]
        do 
        # make task
        task=$(curl -s -u $CREDS -H "Content-Type: Application/json" -H 'Expect:' -X POST http://localhost:8100$doUrl -d @/config/$1 | jq -r .id)
        taskId=$(echo $task)
        echo "starting DO task: $taskId"
        sleep 1
        count=$[$count+1]
        # check task code
        while true
        do
            code=$(restcurl -u $CREDS /mgmt/shared/declarative-onboarding/task/$task | jq -r .code)
            sleep 1
            if  [ "$code" == "null" ] || [ -z "$code" ]; then
                status=$(restcurl -u $CREDS /mgmt/shared/declarative-onboarding/task/$task | jq -r .result.status)
                sleep 1
                # 200,202,422,400,404,500
                echo "DO: $task response:$code"
                sleep 1
                status=$(getDoStatus $taskId)
                sleep 1
                #FINISHED,STARTED,RUNNING,ROLLING_BACK,FAILED,ERROR,NULL
                case $status in 
                FINISHED)
                    # finished
                    echo " $taskId status: $status "
                    # bigstart start dhclient
                    break 2
                    ;;
                STARTED)
                    # started
                    echo " $filename status: $status "
                    sleep 30
                    ;;
                RUNNING)
                    # running
                    echo "DO Status: $status task: $taskId Not done yet..."
                    sleep 30
                    ;;
                FAILED)
                    # failed
                    error=$(getDoStatus $taskId)
                    echo "failed $taskId, $error"
                    #count=$[$count+1]
                    break
                    ;;
                ERROR)
                    # error
                    error=$(getDoStatus $taskId)
                    echo "Error $taskId, $error"
                    #count=$[$count+1]
                    break
                    ;;
                ROLLING_BACK)
                    # Rolling back
                    echo "Rolling back failed status: $status task: $taskId"
                    break
                    ;;
                OK)
                    # complete no change
                    echo "Complete no change status: $status task: $taskId"
                    break 2
                    ;;
                *)
                    # other
                    echo "other: $status"
                    debug=$(restcurl -u $CREDS $doTaskUrl/$taskId | jq .)
                    echo "debug: $debug"
                    error=$(getDoStatus $taskId)
                    echo "Other $taskId, $error"
                    # count=$[$count+1]
                    sleep 30
                    ;;
                esac
            else
                echo "DO status code: $code"
                debug=$(restcurl -u $CREDS $doTaskUrl/$taskId | jq .)
                echo "debug do code: $debug"
                # count=$[$count+1]
            fi
        done
    done
}
# run DO
count=0
while [ $count -le 4 ]
    do
        doStatus=$(checkDO)
        echo "DO check status: $doStatus"
    if [ $deviceId == 1 ] && [[ "$doStatus" = *"online"* ]]; then 
        echo "running do for id:$deviceId"
        bigstart stop dhclient
        runDO do1.json
        if [ "$?" == 0 ]; then
            echo "done with do"
            bigstart start dhclient
            results=$(restcurl -u $CREDS -X GET $doTaskUrl | jq '.[] | .id, .result')
            echo "do results: $results"
            break
        fi
    elif [ $deviceId == 2 ] && [[ "$doStatus" = *"online"* ]]; then 
        echo "running do for id:$deviceId"
        bigstart stop dhclient
        runDO do2.json
        if [ "$?" == 0 ]; then
            echo "done with do"
            bigstart start dhclient
            results=$(restcurl -u $CREDS -X GET $doTaskUrl | jq '.[] | .id, .result')
            echo "do results: $results"
            break
        fi
    elif [ $count -le 2 ]; then
        echo "Status code: $doStatus  DO not ready yet..."
        count=$[$count+1]
        sleep 30
    else
        echo "DO not online status: $doStatus"
        break
    fi
done
function runAS3 () {
    count=0
    while true
        do
            # make task
            task=$(curl -s -u $CREDS -H "Content-Type: Application/json" -H 'Expect:' -X POST http://localhost:8100$as3Url?async=true -d @/config/as3.json | jq -r .id)
            taskId=$(echo $task)
            echo "starting as3 task: $taskId"
            sleep 1
            count=$[$count+1]
            # check task code
        while true
        do
            status=$(curl -s -u $CREDS http://localhost:8100/mgmt/shared/appsvcs/task/$taskId | jq -r '.results[].message')
            case $status in
            *success*)
                # successful!
                echo " $taskId status: $status "
                break 3
                ;;
            no*change)
                # finished
                echo " $taskId status: $status "
                break 3
                ;;
            in*progress)
                # in progress
                echo "Running: $taskId status: $status "
                sleep 60
                ;;
            Error*)
                # error
                echo "Error: $taskId status: $status "
                ;;
            
            *)
            # other
            echo "status: $status"
            debug=$(curl -s -u $CREDS http://localhost:8100/mgmt/shared/appsvcs/task/$taskId | jq .)
            echo "debug: $debug"
            error=$(curl -s -u $CREDS http://localhost:8100/mgmt/shared/appsvcs/task/$taskId | jq -r '.results[].message')
            echo "Other: $taskId, $error"
            ;;
            esac
        done
    done
}

#
# create logging profiles
# https://github.com/mikeoleary/f5-sca-securitystack/blob/master/BIG-IP/tmsh/tier3/app/asm/15/deployapp1.sh
# network profile
echo "creating log profiles"
echo  -e 'create cli transaction;
create security log profile local_afm_log ip-intelligence { log-publisher local-db-publisher } network replace-all-with { local_afm_log { filter { log-acl-match-accept enabled log-acl-match-drop enabled log-acl-match-reject enabled log-geo-always enabled log-ip-errors enabled log-tcp-errors enabled log-tcp-events enabled log-translation-fields enabled } publisher local-db-publisher } };
submit cli transaction' | tmsh -q
#
# asm profile
echo  -e 'create cli transaction;
create security log profile local_sec_log application replace-all-with { local_sec_log { filter replace-all-with { log-challenge-failure-requests { values replace-all-with { enabled } } request-type { values replace-all-with { all } } } response-logging illegal } } bot-defense replace-all-with { local_sec_log { filter { log-alarm enabled log-block enabled log-browser enabled log-browser-verification-action enabled log-captcha enabled log-challenge-failure-request enabled log-device-id-collection-request enabled log-honey-pot-page enabled log-malicious-bot enabled log-mobile-application enabled log-none enabled log-rate-limit enabled log-redirect-to-pool enabled log-suspicious-browser enabled log-tcp-reset enabled log-trusted-bot enabled log-unknown enabled log-untrusted-bot enabled } local-publisher /Common/local-db-publisher } };
submit cli transaction' | tmsh -q
echo "done creating log profiles"

#  run as3
count=0
while [ $count -le 4 ]
do
    as3Status=$(checkAS3)
    echo "AS3 check status: $as3Status"
    if [[ $as3Status == *"online"* ]]; then
        echo "running as3"
        runAS3
        break
    elif [ $count -le 2 ]; then
        echo "Status code: $as3Status  As3 not ready yet..."
        count=$[$count+1]
    else
        echo "As3 API Status $as3Status"
        break
    fi
done
#
#
echo  -e 'create cli transaction;
modify sys management-route default mtu 1460
submit cli transaction' | tmsh -q
tmsh save sys config
echo "timestamp end: $(date)"
echo "setup complete $(timer "$(($(date +%s) - $startTime))")"
# remove declarations
# rm -f /config/do1.json
# rm -f /config/do2.json
# rm -f /config/as3.json