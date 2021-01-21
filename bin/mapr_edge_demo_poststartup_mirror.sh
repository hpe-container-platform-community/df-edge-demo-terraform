#!/bin/bash

export HIDE_WARNINGS=1

source "./scripts/variables.sh"

./bin/ssh_mapr_cluster_2_host_0.sh sudo -u mapr bash <<EOF

   echo mapr | maprlogin password -user mapr
   maprlogin authtest

   echo mapr | maprlogin password -user mapr -cluster dc1.enterprise.org
   maprlogin authtest -cluster dc1.enterprise.org

   . /home/mapr/microservices-dashboard/scripts/edge/createMirror.sh
EOF
