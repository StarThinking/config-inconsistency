#!/bin/bash

apt-get -y install expect
ssh-keygen -t rsa

# for this image
ssh-keygen -f "/root/.ssh/known_hosts" -R node-1-link-0

for i in $(seq 0 9)
do
    $TEST_HOME/sbin/util/vm_autossh.sh root hadoop-$i "mkdir -p ~/.ssh"
    sleep 1
    $TEST_HOME/sbin/util/vm_autoscp.sh root hadoop-$i ~/.ssh/id_rsa.pub ~/hadoop-$i.id_rsa.pub
    sleep 1
    $TEST_HOME/sbin/util/vm_autossh.sh root hadoop-$i "cat ~/hadoop-$i.id_rsa.pub >> ~/.ssh/authorized_keys; rm ~/hadoop-$i.id_rsa.pub"
done


echo "Don't forget to run this script from the other namenode !!"
