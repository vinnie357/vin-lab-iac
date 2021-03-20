# requires base,atc
# declaration content
cat > /config/do1.json <<EOF
${DO1_Document}
EOF
cat > /config/do2.json <<EOF
${DO2_Document}
EOF

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
if [ $deviceId == 1 ] && [[ "$doStatus" = *"online"* ]]; then
    echo "running do for 01 in:$deviceId"
    runDO do1.json
elif [[ "$doStatus" = *"online"* ]]; then
    echo "running do for 02 in:$deviceId"
    runDO do2.json
else
    echo "DO not online status: $doStatus"
fi
