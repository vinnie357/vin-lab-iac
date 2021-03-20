#!/bin/bash
#set vars
. .env_vars_helper.sh
#create vault
. ansible/scripts/.vault.setup.sh
echo "setup done"
