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

exec 1>$LOG_FILE 2>&1

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
cp /home/admin/.ssh/authorized_keys /home/xadmin/.ssh/authorized_keys
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
doTaskUrl="/shared/declarative-onboarding/task"
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
CNT=0
while true
do
  STATUS=$(curl -s -k -I example.com | grep HTTP)
  if [[ $STATUS == *"200"* ]]; then
    echo "Got 200! VE is Ready!"
    break
  elif [ $CNT -le 6 ]; then
    echo "Status code: $STATUS  Not done yet..."
    CNT=$[$CNT+1]
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
    result=$(/usr/bin/curl -Lsk  $file -o /var/config/rest/downloads/$name)
    done
done

# install atc tools
rpms=$(find $rpmFilePath -name "*.rpm" -type f)
for rpm in $rpms
do
  filename=$(basename $rpm)
  echo "installing $filename"
  postBody="{\"operation\":\"INSTALL\",\"packageFilePath\":\"$rpmFilePath/$filename\"}"
  install=$(restcurl -u $CREDS -X POST -d $postBody $rpmInstallUrl | jq -r .id )
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
            debug=$(restcurl -u $CREDS $rpmInstallUrl/$install | jq .)
            echo "failed $filename task: $install error: $debug"
            break
            ;;
        esac
    sleep 2
    done
done
function checkDO() {
    # Check DO Ready
    CNT=0
    while [ $CNT -le 4 ]
    do
    #doStatus=$(curl -i -u $CREDS http://localhost:8100$doCheckUrl | grep HTTP | awk '{print $2}')
    doStatus=$(restcurl -u $CREDS -X GET $doCheckUrl | jq .code)
    if [ $? == 1 ]; then
        doStatus=$(restcurl -u $CREDS -X GET $doCheckUrl | jq -r .result.code)
    fi
    if [ $? == 1 ]; then
        doStatus=$(restcurl -u $CREDS -X GET $doCheckUrl | jq -r .[].result.code)
    fi
    echo "status $doStatus"
    if [[ $doStatus == "200" ]]; then
        #version=$(restcurl -u $CREDS -X GET $doCheckUrl | jq -r .version)
        version=$(restcurl -u $CREDS -X GET $doCheckUrl | jq -r .[].version)
        echo "Declarative Onboarding $version online "
        break
    elif [[ $doStatus == "404" ]]; then
        echo "DO Status $doStatus"
        bigstart restart restnoded
        sleep 30
        bigstart status restnoded | grep running
        status=$?
        echo "restnoded:$status"
    else
        echo "DO Status $doStatus"
        CNT=$[$CNT+1]
    fi
    sleep 10
    done
}
function checkAS3() {
    # Check AS3 Ready
    CNT=0
    while [ $CNT -le 4 ]
    do
    #as3Status=$(curl -i -u $CREDS http://localhost:8100$as3CheckUrl | grep HTTP | awk '{print $2}')
    as3Status=$(restcurl -u $CREDS -X GET $as3CheckUrl | jq -r .code)
    if [[ $as3Status == "200" ]]; then
        version=$(restcurl -u $CREDS -X GET $as3CheckUrl | jq -r .version)
        echo "As3 $version online "
        break
    elif [[ $as3Status == "404" ]]; then
        echo "AS3 Status $as3Status"
        bigstart restart restnoded
        sleep 10
        bigstart status restnoded | grep running
        status=$?
        echo "restnoded:$status"
    else
        echo "AS3 Status $as3Status"
        CNT=$[$CNT+1]
    fi
    sleep 10
    done
}
function checkTS() {
    # Check TS Ready
    CNT=0
    while [ $CNT -le 4 ]
    do
    tsStatus=$(curl -i -u $CREDS http://localhost:8100$tsCheckUrl | grep HTTP | awk '{print $2}')
    if [[ $tsStatus == "200" ]]; then
        version=$(restcurl -u $CREDS -X GET $tsCheckUrl | jq -r .version)
        echo "Telemetry Streaming $version online "
        break
    else
        echo "TS Status $tsStatus"
        CNT=$[$CNT+1]
    fi
    sleep 10
    done
}
# tsStatus=$(checkTS)
# echo "$tsStatus"
function waitDO() {
        CNT=0
        while [ $CNT -le 4 ]
            do
            status=$(restcurl -u $CREDS /mgmt/shared/declarative-onboarding/task/$task | jq -r .result.status)
            echo "waiting... $task status: $status"
            if [ $status == "FINISHED" ]; then
                echo "FINISHED"
                break
            elif [ $status == "RUNNING" ]; then
                echo "Status: $status  Still Waiting..."
                sleep 30
                CNT=$[$CNT+1]
            elif [ $status == "OK" ]; then
                echo "OK"
                break
            else
                echo "OTHER"
                break
            fi
        done
}
function runDO() {
    CNT=0
    while [ $CNT -le 10 ]
        do 
        # make task
        task=$(curl -s -u $CREDS -H "Content-Type: Application/json" -H 'Expect:' -X POST http://localhost:8100/mgmt/shared/declarative-onboarding -d @/config/$1 | jq -r .id)
        echo "starting task: $task"
        sleep 1
        # check task code
        code=$(restcurl -u $CREDS /mgmt/shared/declarative-onboarding/task/$task | jq -r .code)
        sleep 1
        if  [ "$code" == "null" ] || [ -z "$code" ]; then
            sleep 1
            status=$(restcurl -u $CREDS /mgmt/shared/declarative-onboarding/task/$task | jq -r .result.status)
            sleep 1
            #FINISHED,STARTED,RUNNING,ROLLING_BACK,FAILED,ERROR,NULL
            case $status in 
            FINISHED)
                # finished
                echo " $task status: $status "
                bigstart start dhclient
                break
                ;;
            STARTED)
                # started
                echo " $filename status: $status "
                sleep 20
                ;;
            RUNNING)
                # running
                echo "DO status: $status $task"
                CNT=$[$CNT+1]
                sleep 60
                status=$(restcurl -u $CREDS /mgmt/shared/declarative-onboarding/task/$task | jq -r .result.status)
                if [ $status == "FINISHED" ]; then
                    echo "do done for $task for $1"
                    break
                elif [ $status == "RUNNING" ]; then
                    echo "Status: $status  Not done yet..."
                    sleep 60
                    waitStatus=$(waitDO)
                    if [ $waitStatus == "FINISHED" ]; then
                        break
                    else
                        echo "wait result: $waitStatus"
                    fi
                elif [ $status == "OK" ]; then
                    echo "Done Status code: $status  No change $task"
                    break
                else
                    echo "other $status"
                    CNT=$[$CNT+1]
                fi 
                ;;
            FAILED)
                # failed
                error=$(restcurl -u $CREDS /mgmt/shared/declarative-onboarding/task/$task | jq -r .result.status)
                echo "failed $task, $error"
                CNT=$[$CNT+1]
                ;;
            ERROR)
                # error
                error=$(restcurl -u $CREDS /mgmt/shared/declarative-onboarding/task/$task | jq -r .result.status)
                echo "Error $task, $error"
                CNT=$[$CNT+1]
                ;;
            OK)
                # complete no change
                echo "Complete no change status: $status"
                break
                ;;
            *)
                # other
                echo "other: $status"
                debug=$(restcurl -u $CREDS /mgmt/shared/declarative-onboarding/task/$task | jq .)
                echo "debug: $debug"
                error=$(restcurl -u $CREDS /mgmt/shared/declarative-onboarding/task/$task | jq -r .result.status)
                echo "Other $task, $error"
                CNT=$[$CNT+1]
                sleep 60
                ;;
            esac
        else
            echo "DO code: $code"
            CNT=$[$CNT+1]
        fi
    done
}
# run DO
CNT=0
while true
    do
        doStatus=$(checkDO)
    if [ $deviceId == 1 ] && [[ "$doStatus" = *"online"* ]]; then 
        echo "running do for 01 in:$deviceId"
        bigstart stop dhclient
        runDO do1.json
    elif [ $deviceId == 2 ] && [[ "$doStatus" = *"online"* ]]; then 
        echo "running do for 02 in:$deviceId"
        bigstart stop dhclient
        runDO do2.json
    elif [ $CNT -le 6 ]; then
        echo "Status code: $doStatus  DO not ready yet..."
        CNT=$[$CNT+1]
        sleep 30
    else
        echo "DO not online status: $doStatus"
        break
    fi
done
function runAS3 () {
    CNT=0
    while [ $CNT -le 10 ]
        do
        echo "running as3"
        task=$(curl -s -u $CREDS -H "Content-Type: Application/json" -H 'Expect:' -X POST http://localhost:8100$as3Url?async=true -d @/config/as3.json | jq -r .id)
        status=$(curl -s -u $CREDS http://localhost:8100/mgmt/shared/appsvcs/task/$task | jq -r '.results[].message')
        case $status in
        no*change)
            # finished
            echo " $task status: $status "
            break
            ;;
        in*progress)
            # in progress
            echo "Running: $task status: $status "
            sleep 60
            status=$(curl -s -u $CREDS http://localhost:8100/mgmt/shared/appsvcs/task/$task | jq -r '.results[].message')
            if [[ $status == * ]]; then
                echo "status: $status"
                break
            fi
            ;;
        Error*)
            # error
            echo "Error: $task status: $status "
            ;;
        
        *)
            # other
            echo "status: $status"
            debug=$(curl -s -u $CREDS http://localhost:8100/mgmt/shared/appsvcs/task/$task | jq .)
            echo "debug: $debug"
            error=$(curl -s -u $CREDS http://localhost:8100/mgmt/shared/appsvcs/task/$task | jq -r '.results[].message')
            echo "Other: $task, $error"
            CNT=$[$CNT+1]
            ;;
        esac
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
# run as3
CNT=0
while true
do
    as3Status=$(checkAS3)
    echo "AS3 check status: $as3Status"
    if [[ $as3Status == *"online"* ]]; then
        echo "running as3"
        runAS3
        break
    elif [ $CNT -le 6 ]; then
        echo "Status code: $as3Status  As3 not ready yet..."
        CNT=$[$CNT+1]
    else
        echo "Status $as3Status"
        break
    fi
done

# remove declarations
# rm -f /config/do1.json
# rm -f /config/do2.json
# rm -f /config/as3.json