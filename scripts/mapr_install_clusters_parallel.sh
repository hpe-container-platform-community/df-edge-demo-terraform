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

################################################################################
print_header "Setting up Cross-Cluster Security"
################################################################################

DC_MAPR_USERTICKET="$(HIDE_WARNINGS=1 ./generated/ssh_mapr_cluster_1_host_0.sh 'sudo head -n1 /opt/mapr/conf/mapruserticket')"
EDGE_MAPR_USERTICKET="$(HIDE_WARNINGS=1 ./generated/ssh_mapr_cluster_2_host_0.sh 'sudo head -n1 /opt/mapr/conf/mapruserticket')"

for I in 0 1 2; do
   echo "$DC_MAPR_USERTICKET" | \
      ./generated/ssh_mapr_cluster_1_host_$I.sh "sudo bash -c 'cat > /opt/mapr/conf/mapruserticket'"

   echo "$EDGE_MAPR_USERTICKET" | \
      ./generated/ssh_mapr_cluster_2_host_$I.sh "sudo bash -c 'cat > /opt/mapr/conf/mapruserticket'"
done;

for I in 0 1 2; do
   echo "$DC_MAPR_USERTICKET" | \
      ./generated/ssh_mapr_cluster_2_host_$I.sh "sudo bash -c 'cat >> /opt/mapr/conf/mapruserticket'"
      
   echo "$EDGE_MAPR_USERTICKET" | \
      ./generated/ssh_mapr_cluster_1_host_$I.sh "sudo bash -c 'cat >> /opt/mapr/conf/mapruserticket'"
done;

for i in 1 2; do   
  for j in 0 1 2; do    
    echo CLUSTER $i HOST $j;   
    ./generated/ssh_mapr_cluster_${i}_host_${j}.sh "sudo cat /opt/mapr/conf/mapruserticket"
  done;
done;


printf $(terraform output -json mapr_cluster_1_hosts_private_ip_flat) | sed 's/"//' > localmaprhosts
printf $(terraform output -json mapr_cluster_2_hosts_private_ip_flat) | sed 's/"//' > remotemaprhosts

./generated/ssh_mapr_cluster_1_host_0.sh \
   "sudo -u mapr bash -c 'cat > /tmp/localmaprhosts && cat /tmp/localmaprhosts'" < localmaprhosts
   
./generated/ssh_mapr_cluster_1_host_0.sh \
   "sudo -u mapr bash -c 'cat > /tmp/remotemaprhosts && cat /tmp/remotemaprhosts'" < remotemaprhosts

./generated/ssh_mapr_cluster_1_host_0.sh "sudo apt-get -y install expect pssh"

./generated/ssh_mapr_cluster_1_host_0.sh "sudo -u mapr expect" <<EOF

   set remoteip [exec head -n1 /tmp/remotemaprhosts]
   
   spawn /opt/mapr/server/configure-crosscluster.sh create all \
         -localuser mapr -localhosts /tmp/localmaprhosts \
         -remoteuser mapr -remotehosts /tmp/remotemaprhosts \
         -remoteip \$remoteip

   expect "Enter password for mapr user (mapr) for local cluster:" { send "mapr\r" }
   expect "Enter password for mapr user (mapr) for remote cluster:" { send "mapr\r" }
   expect eof
EOF

################################################################################ 
print_header "Verify Cross-Cluster Security"
################################################################################ 

echo mapr | ./generated/ssh_mapr_cluster_1_host_0.sh \
   sudo -u mapr maprlogin password -cluster edge1.enterprise.org

echo mapr | ./generated/ssh_mapr_cluster_2_host_0.sh \
   sudo -u mapr maprlogin password -cluster dc1.enterprise.org

################################################################################ 
print_header "Done!"
################################################################################ 
