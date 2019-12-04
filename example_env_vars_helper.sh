#!/bin/bash
## set vars
#aws_key_id=$(cat aws/credentials | grep aws_access_key_id | awk '{print $3}' )
#aws_key_value=$(cat aws/credentials | grep aws_secret_access_key | awk '{print $3}' )
# vcenter
vcenter_username="youraccount"
vcenter_password="Your password"
# aws
aws_key_id="your key"
aws_key_value="your key"
aws_region="your region"
aws_stack_name="your stack"
# azure
arm_resource_group="your group"
arm_subscription_id="your subscription id"
arm_tenant_id="your tenant id"
arm_client_id="your client id"
arm_client_secret="your client secret"
# gcp
#key=API_KEY "your api key"
gcp_credentials=$(cat creds/gcp/gcp_creds.json)
gcp_sa_file="sa file name no extension"
gcp_project_id="your porject id"
#https://cloud.google.com/compute/docs/regions-zones/
gcp_region="your desired region"
gcp_auth_kind="your auth kind"
gcp_service_account_email="your service account "
gcp_service_account_file="your account file"
gcp_scopes="your scope"
# ansible
vault_test_item="test-me"
ansible_vault_password="your vault password"
# creds
ssh_key_dir="$(echo $HOME)/.ssh"
ssh_key_name="id_rsa"
ssh_key_dir="/path/to/your ssh key"
ssh_key_name="your ssh key name"
#bigiq
bigiq_host="your bigiq address"
bigiq_username="your bigiq username"
bigiq_password="your bigiq password"
#bigip
bigip_password="your bigip password"
## export vars
# test
export VAULT_TEST_ITEM=${vault_test_item}
# creds
export SSH_KEY_DIR=${ssh_key_dir}
export SSH_KEY_NAME=${ssh_key_name}
# azure
export ARM_RESOURCE_GROUP=${arm_resource_group}
export ARM_SUBSCRIPTION_ID=${arm_subscription_id}
export ARM_TENANT_ID=${arm_tenant_id}
export ARM_CLIENT_ID=${arm_client_id}
export ARM_CLIENT_SECRET=${arm_client_secret}
# aws
export AWS_ACCESS_KEY_ID=${aws_key_id}
export AWS_SECRET_ACCESS_KEY=${aws_key_value}
export AWS_REGION=${aws_region}
export AWS_STACK_NAME=${aws_stack_name}
# vcenter
export VCENTER_USERNAME=${vcenter_username}
export VCENTER_PASSWORD=${vcenter_password}
# gcp
export GCP_CREDENTIALS=${gcp_credentials}
export GCP_AUTH_KIND=${gcp_auth_kind}
export GCP_SERVICE_ACCOUNT_EMAIL${gcp_service_account_email}
export GCP_SERVICE_ACCOUNT_FILE${gcp_service_account_file}
export GCP_SCOPES${gcp_scopes}
export GCP_SA_FILE=${gcp_sa_file}
export GCP_PROJECT_ID=${gcp_project_id}
export GCP_REGION=${gcp_region}
## export bigiq vars
export BIGIQ_HOST=${bigiq_host}
export BIGIQ_USERNAME=${bigiq_username}
export BIGIQ_PASSWORD=${bigiq_password}
# export bigip vars
export BIGIP_PASS=${bigip_password}
# ansible vault
export ANSIBLE_VAULT_PASSWORD=${ansible_vault_password}
echo "env vars done"