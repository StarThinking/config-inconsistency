#!/bin/bash

# use this script after format dir

if [ $# -ne 1 ]; then
    echo "wrong argument."
    exit 1
fi

init_image=$1
node_num=14
store_dir=~/vm_images

#for i in $(seq 0 $node_num); do virsh destroy hadoop-$i; virsh undefine hadoop-$i; rm $store_dir/hadoop-"$i".qcow2; done
sleep 10

ifconfig virbr0 down
brctl delbr virbr0
service libvirtd restart
sleep 5
virsh net-destroy default
virsh net-start default

for i in $(seq 0 $node_num)
do
    cp $init_image $store_dir/hadoop-"$i".qcow2
    sudo virt-install --name hadoop-"$i" --memory 8192 --vcpus 2 --disk $store_dir/hadoop-"$i".qcow2 --import --os-variant ubuntu16.04 &
    pids[$i]=$?
    sleep 60
done

echo "wait for 300s..."
sleep 300

for pid in ${pids[@]}
do
    echo "killing process $pid"
    kill -SIGINT $pid
done

sleep 5
echo "vm installed:"
sudo virsh list
