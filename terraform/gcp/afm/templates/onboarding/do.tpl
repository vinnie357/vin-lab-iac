# requires base,atc
# declaration content
cat > /config/do1.json <<EOF
${DO1_Document}
EOF
cat > /config/do2.json <<EOF
${DO2_Document}
EOF

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

PROJECTPREFIX=${projectPrefix}
bigip1url=$(echo "https://storage.googleapis.com/storage/v1/b/"$PROJECTPREFIX"bigip-storage/o/bigip-1?alt=media")
bigip2url=$(echo "https://storage.googleapis.com/storage/v1/b/"$PROJECTPREFIX"bigip-storage/o/bigip-2?alt=media")
token=$(curl -s -f --retry 20 'http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/token' -H 'Metadata-Flavor: Google' | jq -r .access_token )
bigip1ip=$(curl -s -f --retry 20 "$bigip1url" -H 'Metadata-Flavor: Google' -H "Authorization":"Bearer $token" )
bigip2ip=$(curl -s -f --retry 20 "$bigip2url" -H 'Metadata-Flavor: Google' -H "Authorization":"Bearer $token" )
echo "one: $bigip1ip"
echo "two: $bigip2ip"
# internal address on box one will increment
doReplaceOne=$(getPeerAddress $INT3ADDRESS 1)
doReplaceTwo=$(getPeerAddress $INT3ADDRESS -1)
echo " internal address: $INT3ADDRESS "
echo "sync_ip_01:$bigip1ip, sync_ip_02:$bigip2ip"
sed -i "s/-remote-peer-addr-/$bigip2ip/g" /config/do1.json
sed -i "s/-mgmt-gw-addr-/$MGMTGATEWAY/g" /config/do1.json
# internal address on box two will decrement
sed -i "s/-remote-peer-addr-/$bigip1ip/g" /config/do2.json
sed -i "s/-mgmt-gw-addr-/$MGMTGATEWAY/g" /config/do2.json
# end modify DO
# modify as3
sed -i "s/-external-virtual-address-/$INT2ADDRESS/g" /config/as3.json
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