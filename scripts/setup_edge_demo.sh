#!/bin/bash

set -e # abort on error
set -u # abort on undefined variable

source "./scripts/variables.sh"
source "./scripts/functions.sh"

export HIDE_WARNINGS=1

echo "Downloading application to mapr clusters ..."

./generated/ssh_mapr_cluster_1_host_0.sh "curl -L -o ./data-fabric-edge-core-cloud-master.zip https://github.com/snowch/data-fabric-edge-core-cloud/archive/master.zip"
./generated/ssh_mapr_cluster_1_host_0.sh "md5sum ./data-fabric-edge-core-cloud-master.zip"

CLUSTER2_NODE0="$(printf $(terraform output -json mapr_cluster_2_hosts_private_ip_flat) | sed 's/"//' | head -n1)" && \

./generated/ssh_mapr_cluster_1_host_0.sh \
   "sudo -u mapr bash -c 'scp -o StrictHostKeyChecking=no ./data-fabric-edge-core-cloud-master.zip mapr@${CLUSTER2_NODE0}:~/'"

echo "Setting up HQ application ..."

./generated/ssh_mapr_cluster_1_host_0.sh << EOF
   set -e
   sudo service mapr-posix-client-basic restart
   sudo cp -f /home/ubuntu/data-fabric-edge-core-cloud-master.zip /home/mapr/
   sudo chown mapr:mapr /home/mapr/data-fabric-edge-core-cloud-master.zip
   sudo rm -rf /home/mapr/microservices-dashboard
   sudo -u mapr bash -c 'cd /home/mapr; unzip -d /home/mapr -o /home/mapr/data-fabric-edge-core-cloud-master.zip'
   sudo -u mapr bash -c 'cd /home/mapr; mv data-fabric-edge-core-cloud-master microservices-dashboard'
   sudo -u mapr bash -c 'cd /home/mapr; echo mapr | maprlogin password -user mapr'
   sudo -u mapr bash -c 'cd /home/mapr/microservices-dashboard; ./installDemo.sh hq'
EOF

echo "Setting up Edge application ..."

./generated/ssh_mapr_cluster_2_host_0.sh << EOF
   set -e
   sudo service mapr-posix-client-basic restart
   sudo rm -rf /home/mapr/microservices-dashboard
   
   sudo -u mapr bash -c 'unzip -d /home/mapr -o /home/mapr/data-fabric-edge-core-cloud-master.zip'
   sudo -u mapr bash -c 'mv /home/mapr/data-fabric-edge-core-cloud-master /home/mapr/microservices-dashboard'
   sudo -u mapr bash -c 'rm -f /home/mapr/microservices-dashboard/eclipse/microservices-dashboard-app.tar'
   sudo -u mapr bash -c 'cd /home/mapr/microservices-dashboard/eclipse; tar cf microservices-dashboard-app.tar microservices-dashboard/'
   sudo -u mapr bash -c 'cd /home/mapr; echo mapr | maprlogin password -user mapr'
   sudo -u mapr bash -c 'cd /home/mapr/microservices-dashboard; ./installDemo.sh edge'
EOF

################################################################################ 
print_header "Demo Setup Complete"
################################################################################ 
