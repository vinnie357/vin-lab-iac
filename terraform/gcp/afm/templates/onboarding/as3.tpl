# requires base atc

# declaration content
cat > /config/as3.json <<EOF
${AS3_Document}
EOF

# call mcpd wait
mcpdWait
#

as3Status=$(checkAS3)
echo "$as3Status"

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

# create logging profiles
# https://github.com/mikeoleary/f5-sca-securitystack/blob/master/BIG-IP/tmsh/tier3/app/asm/15/deployapp1.sh
# network profile
echo "creating log profiles"
echo  -e 'create cli transaction;
tmsh create security log profile local_afm_log ip-intelligence { log-publisher local-db-publisher } network replace-all-with { local_afm_log { filter { log-acl-match-accept enabled log-acl-match-drop enabled log-acl-match-reject enabled log-geo-always enabled log-ip-errors enabled log-tcp-errors enabled log-tcp-events enabled log-translation-fields enabled } publisher local-db-publisher } };
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
