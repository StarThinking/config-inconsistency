#!/bin/bash

apt-get -y install expect
ssh-keygen -t rsa

# for this image
ssh-keygen -f "/root/.ssh/known_hosts" -R node-1-link-0

for i in $(seq 0 7)
do
    $TEST_HOME/sbin/util/vm_autossh.sh root node-$i-link-0 "mkdir -p ~/.ssh"
    sleep 1
    $TEST_HOME/sbin/util/vm_autoscp.sh root node-$i-link-0 ~/.ssh/id_rsa.pub ~/node-$i-link-0.id_rsa.pub
    sleep 1
    $TEST_HOME/sbin/util/vm_autossh.sh root node-$i-link-0 "cat ~/node-$i-link-0.id_rsa.pub >> ~/.ssh/authorized_keys; rm ~/node-$i-link-0.id_rsa.pub"
done


echo "Don't forget to run this script from the other namenode !!"
