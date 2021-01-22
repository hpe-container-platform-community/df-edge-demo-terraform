#!/bin/bash

set -e # abort on error
set -u # abort on undefined variable

source "./scripts/variables.sh"
source "./scripts/functions.sh"

HIDE_WARNINGS=1

################################################################################ 
print_header "Verify License"
################################################################################ 

./bin/ssh_mapr_cluster_1_host_0.sh 'echo mapr | maprlogin password -user mapr'
./bin/ssh_mapr_cluster_2_host_0.sh 'echo mapr | maprlogin password -user mapr'

./bin/ssh_mapr_cluster_1_host_0.sh -T <<EOF
   echo -n "Cluster 1 MapR Enterprise Trial License expiry (must not be empty): "
   maprcli license list -json | sed -E 's/"grace":(.*),/"grace":\1/' |  sed '/"license"/d' | sed '/Inc./d' | jq '.data[] | select(.description == "MapR Enterprise Trial Edition") | .expiry'
EOF

./bin/ssh_mapr_cluster_2_host_0.sh -T <<EOF
   echo -n "Cluster 2 MapR Enterprise Trial License expiry (must not be empty): "
   maprcli license list -json | sed -E 's/"grace":(.*),/"grace":\1/' |  sed '/"license"/d' | sed '/Inc./d' | jq '.data[] | select(.description == "MapR Enterprise Trial Edition") | .expiry'
EOF

################################################################################ 
print_header "Done!"
################################################################################ 
