#!/bin/bash

source "./scripts/variables.sh"
source "./scripts/functions.sh"

./bin/ssh_mapr_cluster_1_host_0.sh "sudo reboot" || true 
./bin/ssh_mapr_cluster_1_host_1.sh "sudo reboot" || true
./bin/ssh_mapr_cluster_1_host_2.sh "sudo reboot" || true
./bin/ssh_mapr_cluster_2_host_0.sh "sudo reboot" || true
./bin/ssh_mapr_cluster_2_host_1.sh "sudo reboot" || true
./bin/ssh_mapr_cluster_2_host_2.sh "sudo reboot" || true

for MAPR_CLUSTER_HOST in ${MAPR_CLUSTER1_HOSTS_PUB_IPS[@]}; do
   echo "Waiting for $MAPR_CLUSTER_HOST ssh to be ready"
   while ! nc -w5 -z ${MAPR_CLUSTER_HOST} 22; do printf "." -n ; done;
   echo "Connected to $MAPR_CLUSTER_HOST"
done

for MAPR_CLUSTER_HOST in ${MAPR_CLUSTER2_HOSTS_PUB_IPS[@]}; do
   echo "Waiting for $MAPR_CLUSTER_HOST ssh to be ready"
   while ! nc -w5 -z ${MAPR_CLUSTER_HOST} 22; do printf "." -n ; done;
   echo "Connected to $MAPR_CLUSTER_HOST"
done
