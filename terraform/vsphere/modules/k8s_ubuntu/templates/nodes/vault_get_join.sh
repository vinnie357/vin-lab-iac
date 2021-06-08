# get join command
secretName="$(echo "${HOST/-node-[0-9]/-master-0}")"
vaultUrl="${vaultUrl}"
vaultToken="${vaultToken}"
secretData=$(
curl -s \
--header "X-Vault-Token: $vaultToken" \
--request GET \
$vaultUrl/v1/secret/data/$secretName
)

echo "set host"
echo $secretData | jq -r .data.data.dns >> /etc/hosts
echo "do join command"

echo $secretData | jq -r .data.data.joinCommand | base64 -d | bash