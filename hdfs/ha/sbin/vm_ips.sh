#!/bin/bash

for i in $(seq 0 6)
do
    ips+=($(sudo virsh domifaddr node-$i-link-0 | grep ipv4 | awk -F " " '{print $4}' | cut -d"/" -f1))
done

for i in $(seq 0 6)
do
    echo "ip address of node-$i-link-0 is ${ips[i]}"
done

echo "generating... temperary hosts"

rm ./hosts.tmp
touch ./hosts.tmp

echo "# The following lines are desirable for IPv6 capable hosts" >> ./hosts.tmp
echo "::1     localhost ip6-localhost ip6-loopback" >> ./hosts.tmp
echo "ff02::1 ip6-allnodes" >> ./hosts.tmp 
echo "ff02::2 ip6-allrouters" >> ./hosts.tmp
for i in $(seq 0 6)
do
    echo -e "${ips[i]}\t\tnode-$i-link-0" >> ./hosts.tmp
done

echo "hosts.tmp :"
cat ./hosts.tmp

echo "update /etc/hosts for each vm"
for i in $(seq 0 6)
do
    scp ./hosts.tmp root@${ips[i]}:/etc/hosts 
done
