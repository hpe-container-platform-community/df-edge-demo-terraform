#!/bin/bash

set -e # abort on error
set -u # abort on undefined variable

source "./scripts/variables.sh"
source "./scripts/functions.sh"

################################################################################
print_header "Installing MAPR"
################################################################################

(
      print_header "Installing MAPR Cluster 1"
      CLUSTER_ID=1
      ./scripts/mapr_install_cluster.sh ${CLUSTER_ID}
) &

(
      print_header "Installing MAPR Cluster 2"
      CLUSTER_ID=2
      ./scripts/mapr_install_cluster.sh ${CLUSTER_ID}
) &

FAIL=0

jobs -p

for job in $(jobs -p); do
   echo $job
   wait $job || FAIL=1
done

if [[ "$FAIL" != "0" ]]; then
   echo "ERROR: failed to install MAPR"
   exit 1
fi

