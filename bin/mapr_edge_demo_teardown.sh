#!/bin/bash

export HIDE_WARNINGS=1

source "./scripts/variables.sh"
source "./scripts/functions.sh"

################################################################################
print_header "Edge Cluster - logging in"
################################################################################

./bin/ssh_mapr_cluster_2_host_0.sh sudo -u mapr bash <<EOF
    echo mapr | maprlogin password -user mapr -cluster edge1.enterprise.org
    maprlogin authtest -cluster edge1.enterprise.org

    echo mapr | maprlogin password -user mapr -cluster dc1.enterprise.org
    maprlogin authtest -cluster dc1.enterprise.org
EOF

################################################################################
print_header "Running teardown on Edge Cluster - Deleting replicatedStream"
################################################################################

./bin/ssh_mapr_cluster_2_host_0.sh sudo -u mapr bash <<EOF

    if [[ -e /mapr/edge1.enterprise.org/apps/pipeline/data/replicatedStream ]]; then
       maprcli stream replica remove \
         -path /mapr/dc1.enterprise.org/apps/pipeline/data/replicatedStream \
         -replica /mapr/edge1.enterprise.org/apps/pipeline/data/replicatedStream 

       maprcli stream delete \
         -path /mapr/edge1.enterprise.org/apps/pipeline/data/replicatedStream 
    fi

    if [[ -e /mapr/dc1.enterprise.org/apps/pipeline/data/replicatedStream ]]; then
       maprcli stream delete \
         -path /mapr/dc1.enterprise.org/apps/pipeline/data/replicatedStream 
    fi
EOF

################################################################################
print_header "Running teardown on Edge Cluster - Deleting Volumes"
################################################################################

./bin/ssh_mapr_cluster_2_host_0.sh sudo -u mapr bash <<EOF

    if [[ -e /mapr/dc1.enterprise.org/apps/pipeline/data/files-missionX ]]; then
       maprcli volume remove \
          -name files-missionX \
          -force true \
          -cluster dc1.enterprise.org || true
    fi

    if [[ -e /mapr/edge1.enterprise.org/apps/pipeline/data/files-missionX ]]; then
       maprcli volume remove \
          -name files-missionX \
          -force true \
          -cluster edge1.enterprise.org || true
    fi
EOF

################################################################################
print_header "Running teardown on Edge Cluster - Deleting Tables"
################################################################################

./bin/ssh_mapr_cluster_2_host_0.sh sudo -u mapr bash <<EOF
    set -x
    if [[ -e /mapr/edge1.enterprise.org/apps/pipeline/data/imagesTable ]]; then
       maprcli table delete \
          -path /apps/pipeline/data/imagesTable
    fi
EOF

./bin/ssh_mapr_cluster_1_host_0.sh sudo -u mapr bash <<EOF
    set -x
    if [[ -e /mapr/dc1.enterprise.org/apps/pipeline/data/imagesTable ]]; then
       maprcli table delete \
          -path /apps/pipeline/data/imagesTable
    fi
EOF
