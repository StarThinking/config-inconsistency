#!/bin/bash

# use this script after format dir

if [ $# -ne 1 ]; then
    echo "wrong argument."
    exit 1
fi

init_image=$1

ifconfig virbr0 down
brctl delbr virbr0
service libvirtd restart
sleep 5
virsh net-destroy default
virsh net-start default

for i in $(seq 0 9); do virsh destroy hadoop-$i; virsh undefine hadoop-$i; done
sleep 10

for i in $(seq 0 9)
do
    cp $init_image ~/vm_images/hadoop-"$i".qcow2
    sudo virt-install --name hadoop-"$i" --memory 8192 --vcpus 2 --disk ~/vm_images/hadoop-"$i".qcow2 --import --os-variant ubuntu16.04 &
    pids[$i]=$?
done

echo "wait for 600s..."
sleep 600

for pid in ${pids[@]}
do
    echo "killing process $pid"
    kill -SIGINT $pid
done

sleep 5
echo "vm installed:"
sudo virsh list
