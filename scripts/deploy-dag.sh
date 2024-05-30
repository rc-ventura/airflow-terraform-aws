#!/bin/bash

set -e

ip_address=$(cd terraform && terraform output instance_ip_address | sed 's/"//g')
ssh_key_path=$(cd terraform && terraform output ssh_key_path | sed 's/"//g')

scp -i $ssh_key_path \
    -o StrictHostKeyChecking=no \
    -o UserKnownHostsFile=/dev/null \
    -r dags/* ubuntu@${ip_address}:/home/ubuntu/dags/;

ssh -i $ssh_key_path \
    -o StrictHostKeyChecking=no \
    -o UserKnownHostsFile=/dev/null \
    -t ubuntu@${ip_address} /home/ubuntu/copy-dags.sh;