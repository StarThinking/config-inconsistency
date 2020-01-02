#!/bin/bash
set -u

if [ -z "$TEST_HOME" ]; then
    echo "TEST_HOME not set."
    exit 3
fi

node_num=9

for i in $(seq 0 $node_num)
do
    vm_ip=($(sudo virsh domifaddr hadoop-$i | grep ipv4 | awk -F " " '{print $4}' | cut -d"/" -f1))
    $TEST_HOME/sbin/util/vm_autoscp.sh root $vm_ip ~/.ssh/id_rsa.pub ~/id_rsa.pub.tmp
    $TEST_HOME/sbin/util/vm_autossh.sh root $vm_ip "cat ~/id_rsa.pub.tmp >> ~/.ssh/authorized_keys; rm ~/id_rsa.pub.tmp"
    sleep 2
    echo "testing host-vm$i ssh without password:"
    msg=$(ssh $vm_ip "cat /etc/hostname")
    if [ "$msg" == "hadoop-$i" ]; then
        echo "Ok hadoop-$i"
    else
        echo "Failed hadoop-$i"
    fi
done
