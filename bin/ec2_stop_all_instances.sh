#!/bin/bash

set -u

source "./scripts/variables.sh"
source "scripts/functions.sh"


SSH_OPTS="-o StrictHostKeyChecking=no -o ConnectTimeout=10 -o ConnectionAttempts=1 -q"

set +u

aws --region $REGION --profile $PROFILE ec2 stop-instances \
    --instance-ids $ALL_INSTANCE_IDS \
    --output table \
    --query "StoppingInstances[*].{ID:InstanceId,State:CurrentState.Name}"
