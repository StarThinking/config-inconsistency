#!/bin/bash

for i in $(seq 0 6)
do
    ips+=($(sudo virsh domifaddr node-$i-link-0 | grep ipv4 | awk -F " " '{print $4}' | cut -d"/" -f1))
done

for i in $(seq 0 6)
do
    echo "ip address of node-$i-link-0 is ${ips[i]}"
done

echo "generate /etc/hosts"

for i in $(seq 0 6)
do
    echo -e "${ips[i]}\t\tnode-$i-link-0"
done
