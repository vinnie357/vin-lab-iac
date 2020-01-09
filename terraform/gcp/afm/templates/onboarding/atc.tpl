# requires base
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
    doStatus=$(restcurl -u $CREDS -X GET $doCheckUrl | jq -r .[].result.status)
    if [[ $doStatus == "OK" ]]; then
        version=$(restcurl -u $CREDS -X GET $doCheckUrl | jq -r .[].version)
        echo "Declarative Onboarding $version online "
        break
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
    as3Status=$(curl -i -u $CREDS http://localhost:8100$as3CheckUrl | grep HTTP | awk '{print $2}')
    if [[ $as3Status == "200" ]]; then
        version=$(restcurl -u $CREDS -X GET $as3CheckUrl | jq -r .version)
        echo "As3 $version online "
        break
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
doStatus=$(checkDO)
echo "$doStatus"
as3Status=$(checkAS3)
echo "$as3Status"
# tsStatus=$(checkTS)
# echo "$tsStatus"