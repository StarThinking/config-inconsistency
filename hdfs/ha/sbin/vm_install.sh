#!/bin/bash

for i in $(seq 0 6)
do
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

sudo virsh list
