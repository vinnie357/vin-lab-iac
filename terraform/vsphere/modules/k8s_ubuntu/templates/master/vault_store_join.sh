
# send join command to vault
joinCommand=$(kubeadm token create --print-join-command | base64 -w 0)
vaultToken=${vaultToken}
vaultUrl=${vaultUrl}
secretName=${HOST}
payload=$(cat -<<EOF
{
  "data": {
      "joinCommand": "$(kubeadm token create --print-join-command | base64 -w 0)",
      "dns": "$(ip -4 addr show ens192 | grep -oP '(?<=inet\s)\d+(\.\d+){3}') ${HOST}.${DOMAIN}"
    }
}
EOF
)
curl  \
--header "X-Vault-Token: $vaultToken" \
--request POST \
--data "$payload" \
$vaultUrl/v1/secret/data/$secretName