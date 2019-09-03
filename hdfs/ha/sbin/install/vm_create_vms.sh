#!/bin/bash

# use this script after format dir

if [ $# -ne 1 ]; then
    echo "wrong argument."
    exit 1
fi

init_image=$1

ifconfig virbr0 down
brctl delbr virbr0
virsh net-start default


for i in $(seq 0 6)
do
#    cp $init_image ~/vm_images/node-"$i"-link-0.qcow2
    sudo virt-install --name node-"$i"-link-0 --memory 2048 --vcpus 2 --disk ~/vm_images/node-"$i"-link-0.qcow2 --import --os-variant ubuntu16.04 &
    pids[$i]=$?
done

echo "wait for 60s..."
sleep 60

for pid in ${pids[@]}
do
    echo "killing process $pid"
    kill -SIGINT $pid
done

sleep 5
echo "vm installed:"
sudo virsh list
