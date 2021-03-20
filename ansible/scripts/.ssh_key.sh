#!/bin/bash

cat /root/.ssh/${SSH_KEY_NAME} > /root/.ssh/key
chmod 400 /root/.ssh/key
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/key

echo "done"
