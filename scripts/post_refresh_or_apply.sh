#!/usr/bin/env bash

set -e # abort on error
set -u # abort on undefined variable

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

source "$SCRIPT_DIR/variables.sh"

# add private key to AD server to allow passwordless ssh to all other hosts
if [[  "$AD_SERVER_ENABLED" == "True" && "$AD_PUB_IP" ]]; then
   cat generated/controller.pub_key | \
      ssh -q -o StrictHostKeyChecking=no -i "${LOCAL_SSH_PRV_KEY_PATH}" -T centos@${AD_PUB_IP} "cat >> /home/centos/.ssh/authorized_keys" 
fi

exit 0
