#!/bin/bash

set -e # abort on error
set -u # abort on undefined variable

source "./scripts/variables.sh"
source "./scripts/functions.sh"

HIDE_WARNINGS=1

################################################################################ 
print_header "Verify License"
################################################################################ 

./bin/ssh_mapr_cluster_1_host_0.sh <<EOF
   echo mapr | maprlogin password -user mapr
   maprcli license list -json | sed -E 's/"grace":(.*),/"grace":\1/' |  sed '/"license"/d' | sed '/Inc./d' | python -m json.tool
EOF

./bin/ssh_mapr_cluster_2_host_0.sh <<EOF
   echo mapr | maprlogin password -user mapr
   maprcli license list -json | sed -E 's/"grace":(.*),/"grace":\1/' |  sed '/"license"/d' | sed '/Inc./d' | python -m json.tool
EOF

################################################################################ 
print_header "Done!"
################################################################################ 
