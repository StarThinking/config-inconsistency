#!/bin/bash

if [ -z "$TEST_HOME" ]; then
    echo "TEST_HOME not set."
    exit
fi

node_num=9 # 9+1=10

for i in $(seq 0 $node_num)
do
    ips+=($(sudo virsh domifaddr hadoop-$i | grep ipv4 | awk -F " " '{print $4}' | cut -d"/" -f1))
done

for i in $(seq 0 $node_num)
do
    echo "ip address of hadoop-$i is ${ips[i]}"
done

echo "generating... temperary hosts"

rm $TEST_HOME/sbin/hosts.tmp
touch $TEST_HOME/sbin/hosts.tmp

echo "# The following lines are desirable for IPv6 capable hosts" >> $TEST_HOME/sbin/hosts.tmp
echo "::1     localhost ip6-localhost ip6-loopback" >> $TEST_HOME/sbin/hosts.tmp
echo "ff02::1 ip6-allnodes" >> $TEST_HOME/sbin//hosts.tmp 
echo "ff02::2 ip6-allrouters" >> $TEST_HOME/sbin/hosts.tmp
for i in $(seq 0 $node_num)
do
    echo -e "${ips[i]}\t\thadoop-$i" >> $TEST_HOME/sbin/hosts.tmp
    echo -e "${ips[i]}\t\thadoop-$i" >> /etc/hosts
done

echo "hosts.tmp :"
cat $TEST_HOME/sbin/hosts.tmp

echo "update /etc/hosts for each vm"
for i in $(seq 0 $node_num)
do
    $TEST_HOME/sbin/util/vm_autoscp.sh root ${ips[i]} $TEST_HOME/sbin/hosts.tmp /etc/hosts 
    $TEST_HOME/sbin/util/vm_autossh.sh root ${ips[i]} "echo hadoop-$i > /etc/hostname; reboot"
done

rm $TEST_HOME/sbin/hosts.tmp
