#!/bin/bash
set -u

if [ -z "$TEST_HOME" ]; then
    echo "TEST_HOME not set."
    exit 3
fi

vm0_ip=($(sudo virsh domifaddr node-0-link-0 | grep ipv4 | awk -F " " '{print $4}' | cut -d"/" -f1))
$TEST_HOME/sbin/util/vm_autoscp.sh root $vm0_ip ~/.ssh/id_rsa.pub ~/id_rsa.pub.tmp
$TEST_HOME/sbin/util/vm_autossh.sh root $vm0_ip "cat ~/id_rsa.pub.tmp >> ~/.ssh/authorized_keys; rm ~/id_rsa.pub.tmp"
sleep 2
echo "testing host-vm0 ssh without password:"
msg=$(ssh $vm0_ip "cat /etc/hostname")
if [ "$msg" == "node-0-link-0" ]; then
    echo "Ok"
else
    echo "Failed"
fi
