#!/bin/bash
# create vault for you
# check for vars
if [ -z "${VAULT_TEST_ITEM}" ] || [ -z "${BIGIP_PASS}" ] || [ -z "${BIGIQ_HOST}" ] || [ -z "${BIGIQ_USERNAME}" ] || [ -z "${BIGIQ_PASSWORD}" ] || [ -z "${ARM_RESOURCE_GROUP}" ]\
 || [ -z "${ARM_SUBSCRIPTION_ID}" ] || [ -z "${ARM_TENANT_ID}" ] || [ -z "${ARM_CLIENT_ID}" ] || [ -z "${ARM_CLIENT_SECRET}" ]
then
    echo "check ENV vars"
    #exit 1
else
  # to do get pw from keystore
  #BIGIP_PASS=$(cd setup/ && make keys | grep value | awk '{ print $2 }')
  rm -f .tmp.txt
  echo "#vault vars" >> .tmp.txt
  echo "vault_test_item: ${VAULT_TEST_ITEM}" >> .tmp.txt
  echo "vault_vcenter_username: ${VCENTER_USERNAME}" >> .tmp.txt
  echo "vault_vcenter_password: ${VCENTER_PASSWORD}" >> .tmp.txt
  echo "vault_bigip_password: ${BIGIP_PASS}" >> .tmp.txt
  echo "vault_bigiq_host: \"${BIGIQ_HOST}\"" >> .tmp.txt
  echo "vault_bigiq_username: \"${BIGIQ_USERNAME}\"" >> .tmp.txt
  echo "vault_bigiq_password: \"${BIGIQ_PASSWORD}\"" >> .tmp.txt
  echo "resourceGroup: \"${ARM_RESOURCE_GROUP}\"" >> .tmp.txt
  echo "subscriptionId: \"${ARM_SUBSCRIPTION_ID}\"" >> .tmp.txt
  echo "directoryId: \"${ARM_TENANT_ID}\"" >> .tmp.txt
  echo "applicationId: \"${ARM_CLIENT_ID}\"" >> .tmp.txt
  echo "apiAccessKey: \"${ARM_CLIENT_SECRET}\"" >> .tmp.txt
ansible-vault encrypt --vault-password-file ansible/scripts/.vault_pass.sh  < ".tmp.txt" > ansible/group_vars/all/vault.yaml && rm -f .tmp.txt
echo "vault done"
fi

# payload="$(echo "vault_bigip_password: \"${BIGIP_PASS}\"")\n$(echo "vault_bigiq_host: \"${BIGIQ_HOST}\"")\n$(echo "vault_bigiq_username: \"${BIGIQ_USERNAMENAME}\"")\n\
# $(echo "vault_bigiq_password: \"${BIGIQ_PASSWORD}\"")\n$(echo "resourceGroup: \"${ARM_RESOURCE_GROUP}\"")\n$(echo "subscriptionId: \"${ARM_SUBSCRIPTION_ID}\"")\n\
# $(echo "directoryId: \"${ARM_TENANT_ID}\"")\n$(echo "applicationId: \"${ARM_CLIENT_ID}\"")\n$(echo "apiAccessKey: \"${ARM_CLIENT_SECRET}\"")"
# echo -e "${payload}"