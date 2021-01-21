#!/bin/bash

HIDE_WARNINGS=1

source "./scripts/variables.sh"

./bin/ssh_mapr_cluster_2_host_0.sh sudo -u mapr bash <<EOF
   set -e

   echo mapr | maprlogin password -user mapr
   maprlogin authtest

   echo "Running 'maprcli service list'"
   echo "See https://docs.datafabric.hpe.com/62/ReferenceGuide/service-list.html#servicelist__state"
   echo
   /opt/mapr/bin/maprcli service list
EOF
