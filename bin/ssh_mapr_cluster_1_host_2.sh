#!/bin/bash
source "./scripts/variables.sh"
ssh -o StrictHostKeyChecking=no -i "./generated/controller.prv_key" ubuntu@${MAPR_CLUSTER1_HOSTS_PUB_IPS[2]} "$@"
