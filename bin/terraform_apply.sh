#!/bin/bash

set -e # abort on error
set -u # abort on undefined variable

./scripts/check_prerequisites.sh
source ./scripts/functions.sh

print_term_width "="
echo "TIP: Parameters given to this script are passed to 'terraform apply'"
echo "     Example: ./bin/terraform_apply.sh -var='ad_server_enabled=false'"
print_term_width "="


if [[ ! -f  "./generated/controller.prv_key" ]]; then
   [[ -d "./generated" ]] || mkdir generated
   ssh-keygen -m pem -t rsa -N "" -f "./generated/controller.prv_key"
   mv "./generated/controller.prv_key.pub" "./generated/controller.pub_key"
   chmod 600 "./generated/controller.prv_key"
fi


terraform apply -var-file=etc/bluedata_infra.tfvars \
   -var="client_cidr_block=$(curl -s http://ifconfig.me/ip)/32" "$@"

terraform output -json > generated/output.json 
#./scripts/post_refresh_or_apply.sh

./bin/ec2_instance_status.sh



