#!/usr/bin/env bash

source "./scripts/variables.sh"

ssh -o StrictHostKeyChecking=no -i "${LOCAL_SSH_PRV_KEY_PATH}" -T centos@${AD_PUB_IP} python - << ENDSSH
import sys
import re
import os

success_text = "PLAY RECAP *********************************************************************\n" + \
"node1                      : ok=396  changed=104  unreachable=0    failed=0    skipped=149  rescued=0    ignored=0   \n" + \
"node2                      : ok=361  changed=82   unreachable=0    failed=0    skipped=167  rescued=0    ignored=0   \n" + \
"node3                      : ok=340  changed=61   unreachable=0    failed=0    skipped=164  rescued=0    ignored=0   \n"

success_text = re.escape(success_text)
#print(success_text)

for i in [1, 2]:
   filename = "ansible_log_{}.txt".format(i)
   with open(filename) as f:
       match = re.findall(success_text, f.read(), re.MULTILINE)
       if match:
   	  print("ansible install successful for cluster '{}'".format(i))
       else:
   	  print("ansible install seems to have failed - check '{}' on AD server for more info".format(os.path.realpath(f.name)))
   	  exit(1)

exit(0)
ENDSSH

