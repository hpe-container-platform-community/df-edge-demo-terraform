#!/bin/bash

HIDE_WARNINGS=1

source "./scripts/variables.sh"

DC_MAPR_USERTICKET="$(HIDE_WARNINGS=1 ./bin/ssh_mapr_cluster_1_host_0.sh 'sudo head -n1 /opt/mapr/conf/mapruserticket')"
EDGE_MAPR_USERTICKET="$(HIDE_WARNINGS=1 ./bin/ssh_mapr_cluster_2_host_0.sh 'sudo head -n1 /opt/mapr/conf/mapruserticket')"

for I in 0 1 2; do
   echo "$DC_MAPR_USERTICKET" | \
      ./bin/ssh_mapr_cluster_1_host_$I.sh "sudo bash -c 'cat > /opt/mapr/conf/mapruserticket'"

   echo "$EDGE_MAPR_USERTICKET" | \
      ./bin/ssh_mapr_cluster_2_host_$I.sh "sudo bash -c 'cat > /opt/mapr/conf/mapruserticket'"
done;

for I in 0 1 2; do
   echo "$DC_MAPR_USERTICKET" | \
      ./bin/ssh_mapr_cluster_2_host_$I.sh "sudo bash -c 'cat >> /opt/mapr/conf/mapruserticket'"
      
   echo "$EDGE_MAPR_USERTICKET" | \
      ./bin/ssh_mapr_cluster_1_host_$I.sh "sudo bash -c 'cat >> /opt/mapr/conf/mapruserticket'"
done;

for i in 1 2; do   
  for j in 0 1 2; do    
    echo CLUSTER $i HOST $j;   
    ./bin/ssh_mapr_cluster_${i}_host_${j}.sh "sudo cat /opt/mapr/conf/mapruserticket"
  done;
done;
