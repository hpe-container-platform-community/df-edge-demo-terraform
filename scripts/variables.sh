#!/usr/bin/env bash

HIDE_WARNINGS=${HIDE_WARNINGS:-0}

set -e # abort on error
set -u # abort on undefined variable

# disable '-x' because it is too verbose for this script
# and is not useful for for this script
if [[ $- == *x* ]]; then
  was_x_set=1
else
  was_x_set=0
fi
set +x

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
OUTPUT_JSON=$(cat "${SCRIPT_DIR}/../generated/output.json")

###############################################################################
# Set variables from terraform output
###############################################################################

# Ensure python is able to parse the OUTPUT_JSON file
python3 - <<____HERE
import json,sys,subprocess

try:
   with open('${SCRIPT_DIR}/../generated/output.json') as f:
      json.load(f)
except: 
   print(80 * '*')
   print("ERROR: Can't parse: '${SCRIPT_DIR}/../generated/output.json'")
   print(80 * '*')
   sys.exit(1)
____HERE

###############################################################################
# Set variables from terraform output
###############################################################################

PROJECT_DIR=$(echo $OUTPUT_JSON | python3 -c 'import json,sys;obj=json.load(sys.stdin);print (obj["project_dir"]["value"])')
#echo PROJECT_DIR="${PROJECT_DIR}"
[ "$PROJECT_DIR" ] || ( echo "ERROR: PROJECT_DIR is empty" && exit 1 )

LOG_FILE="${PROJECT_DIR}"/generated/bluedata_install_output.txt
# [[ -f "$LOG_FILE" ]] && mv -f "$LOG_FILE" "${LOG_FILE}".old

CLIENT_CIDR_BLOCK=$(echo $OUTPUT_JSON | python3 -c 'import json,sys;obj=json.load(sys.stdin);print (obj["client_cidr_block"]["value"])')
[ "$CLIENT_CIDR_BLOCK" ] || ( echo "ERROR: CLIENT_CIDR_BLOCK is empty" && exit 1 )

VPC_CIDR_BLOCK=$(echo $OUTPUT_JSON | python3 -c 'import json,sys;obj=json.load(sys.stdin);print (obj["vpc_cidr_block"]["value"])')
[ "$VPC_CIDR_BLOCK" ] || ( echo "ERROR: VPC_CIDR_BLOCK is empty" && exit 1 )

USER_TAG=$(echo $OUTPUT_JSON | python3 -c 'import json,sys;obj=json.load(sys.stdin);print (obj["user"]["value"])')
[ "$USER_TAG" ] || ( echo "ERROR: USER_TAG is empty" && exit 1 )

PROFILE=$(echo $OUTPUT_JSON | python3 -c 'import json,sys;obj=json.load(sys.stdin);print (obj["aws_profile"]["value"])')
[ "$PROFILE" ] || ( echo "ERROR: PROFILE is empty" && exit 1 )

REGION=$(echo $OUTPUT_JSON | python3 -c 'import json,sys;obj=json.load(sys.stdin);print (obj["aws_region"]["value"])')
[ "$REGION" ] || ( echo "ERROR: REGION is empty" && exit 1 )

LOCAL_SSH_PUB_KEY_PATH=$(echo $OUTPUT_JSON | python3 -c 'import json,sys;obj=json.load(sys.stdin);print (obj["ssh_pub_key_path"]["value"])')
LOCAL_SSH_PRV_KEY_PATH=$(echo $OUTPUT_JSON | python3 -c 'import json,sys;obj=json.load(sys.stdin);print (obj["ssh_prv_key_path"]["value"])')

[ "$LOCAL_SSH_PUB_KEY_PATH" ] || ( echo "ERROR: LOCAL_SSH_PUB_KEY_PATH is empty" && exit 1 )
[ "$LOCAL_SSH_PRV_KEY_PATH" ] || ( echo "ERROR: LOCAL_SSH_PRV_KEY_PATH is empty" && exit 1 )

#echo LOCAL_SSH_PUB_KEY_PATH=${LOCAL_SSH_PUB_KEY_PATH}
#echo LOCAL_SSH_PRV_KEY_PATH=${LOCAL_SSH_PRV_KEY_PATH}

CA_KEY="$(echo $OUTPUT_JSON | python3 -c 'import json,sys;obj=json.load(sys.stdin);print (obj["ca_key"]["value"])')"
CA_CERT="$(echo $OUTPUT_JSON | python3 -c 'import json,sys;obj=json.load(sys.stdin);print (obj["ca_cert"]["value"])')"

[ "$CA_KEY" ] || ( echo "ERROR: CA_KEY is empty" && exit 1 )
[ "$CA_CERT" ] || ( echo "ERROR: CA_CERT is empty" && exit 1 )


### TODO: refactor this checks below to a method

IP_WARNING=()

#### MAPR CLUSTER 1

MAPR_CLUSTER1_COUNT=$(echo $OUTPUT_JSON | python3 -c 'import json,sys;obj=json.load(sys.stdin);print (obj["mapr_cluster_1_count"]["value"][0], sep=" ")') 
if [[ "$MAPR_CLUSTER1_COUNT" != "0" ]]; then
   MAPR_CLUSTER1_NAME=$(echo $OUTPUT_JSON | python3 -c 'import json,sys;obj=json.load(sys.stdin);print (obj["mapr_cluster_1_name"]["value"][0], sep=" ")') 
   MAPR_CLUSTER1_HOSTS_INSTANCE_IDS=$(echo $OUTPUT_JSON | python3 -c 'import json,sys;obj=json.load(sys.stdin);print (*obj["mapr_cluster_1_hosts_instance_id"]["value"][0], sep=" ")') 
   MAPR_CLUSTER1_HOSTS_PRV_IPS=$(echo $OUTPUT_JSON | python3 -c 'import json,sys;obj=json.load(sys.stdin);print (*obj["mapr_cluster_1_hosts_private_ip"]["value"][0], sep=" ")') 
   MAPR_CLUSTER1_HOSTS_PUB_IPS=$(echo $OUTPUT_JSON | python3 -c 'import json,sys;obj=json.load(sys.stdin);print (*obj["mapr_cluster_1_hosts_public_ip"]["value"][0], sep=" ")') 

   read -r -a MAPR_CLUSTER1_HOSTS_PRV_IPS <<< "$MAPR_CLUSTER1_HOSTS_PRV_IPS"
   read -r -a MAPR_CLUSTER1_HOSTS_PUB_IPS <<< "$MAPR_CLUSTER1_HOSTS_PUB_IPS"
else
   MAPR_CLUSTER1_NAME=""
   MAPR_CLUSTER1_HOSTS_INSTANCE_IDS=""
   MAPR_CLUSTER1_HOSTS_PRV_IPS=()
   MAPR_CLUSTER1_HOSTS_PUB_IPS=()
fi


MAPR_CLUSTER2_COUNT=$(echo $OUTPUT_JSON | python3 -c 'import json,sys;obj=json.load(sys.stdin);print (obj["mapr_cluster_2_count"]["value"][0], sep=" ")') 
if [[ "$MAPR_CLUSTER2_COUNT" != "0" ]]; then
   MAPR_CLUSTER2_NAME=$(echo $OUTPUT_JSON | python3 -c 'import json,sys;obj=json.load(sys.stdin);print (obj["mapr_cluster_2_name"]["value"][0], sep=" ")') 
   MAPR_CLUSTER2_HOSTS_INSTANCE_IDS=$(echo $OUTPUT_JSON | python3 -c 'import json,sys;obj=json.load(sys.stdin);print (*obj["mapr_cluster_2_hosts_instance_id"]["value"][0], sep=" ")') 
   MAPR_CLUSTER2_HOSTS_PRV_IPS=$(echo $OUTPUT_JSON | python3 -c 'import json,sys;obj=json.load(sys.stdin);print (*obj["mapr_cluster_2_hosts_private_ip"]["value"][0], sep=" ")') 
   MAPR_CLUSTER2_HOSTS_PUB_IPS=$(echo $OUTPUT_JSON | python3 -c 'import json,sys;obj=json.load(sys.stdin);print (*obj["mapr_cluster_2_hosts_public_ip"]["value"][0], sep=" ")') 

   read -r -a MAPR_CLUSTER2_HOSTS_PRV_IPS <<< "$MAPR_CLUSTER2_HOSTS_PRV_IPS"
   read -r -a MAPR_CLUSTER2_HOSTS_PUB_IPS <<< "$MAPR_CLUSTER2_HOSTS_PUB_IPS"
else
   MAPR_CLUSTER2_NAME=""
   MAPR_CLUSTER2_HOSTS_INSTANCE_IDS=""
   MAPR_CLUSTER2_HOSTS_PRV_IPS=()
   MAPR_CLUSTER2_HOSTS_PUB_IPS=()
fi

AD_SERVER_ENABLED=$(echo $OUTPUT_JSON | python3 -c 'import json,sys;obj=json.load(sys.stdin);print (obj["ad_server_enabled"]["value"])')

if [[ "$AD_SERVER_ENABLED" == "True" ]]; then
   AD_INSTANCE_ID=$(echo $OUTPUT_JSON | python3 -c 'import json,sys;obj=json.load(sys.stdin);print (obj["ad_server_instance_id"]["value"])') 
   AD_PRV_IP=$(echo $OUTPUT_JSON | python3 -c 'import json,sys;obj=json.load(sys.stdin);print (obj["ad_server_private_ip"]["value"])') 
   AD_PUB_IP=$(echo $OUTPUT_JSON | python3 -c 'import json,sys;obj=json.load(sys.stdin);print (obj["ad_server_public_ip"]["value"])') 
else
   AD_INSTANCE_ID=""
fi


if [[ $was_x_set == 1 ]]; then
   set -x
else
   set +x
fi 


ALL_MAPR_INSTANCE_IDS="${MAPR_CLUSTER1_HOSTS_INSTANCE_IDS} ${MAPR_CLUSTER2_HOSTS_INSTANCE_IDS}"
ALL_INSTANCE_IDS="${AD_INSTANCE_ID} ${MAPR_CLUSTER1_HOSTS_INSTANCE_IDS} ${MAPR_CLUSTER2_HOSTS_INSTANCE_IDS}"

if [[ ${#IP_WARNING[@]} != 0 && ${HIDE_WARNINGS} == 0 ]]; then
   tput setaf 3
   echo "WARNING: ${IP_WARNING[@]} could not be retrieved -> is the instance(s) running?"
   tput sgr0
fi

