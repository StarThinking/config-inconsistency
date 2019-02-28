#!/bin/bash

if [ -z "$TEST_HOME" ]; then
    echo "TEST_HOME not set."
    exit
fi

. $TEST_HOME/sbin/global_var.sh

# mkfs for datanode
#for i in ${datanodes[@]}
for i in 1
do
    ssh node-$i-link-0 "printf '%s\n' n '' '' '' '' w | fdisk /dev/sdb"
    ssh node-$i-link-0 "mkfs.ext4 /dev/sdb1"
    ssh node-$i-link-0 "mkdir $hadoop_data_dir; mount /dev/sdb1 $hadoop_data_dir"
done

# mkfs for client
#ssh node-$clientnode-link-0 "printf '%s\n' n '' '' '' '' w | fdisk /dev/sdb"
#ssh node-$clientnode-link-0 "mkfs.ext4 /dev/sdb1"
#ssh node-$clientnode-link-0 "mkdir $large_file_dir; mount /dev/sdb1 $large_file_dir; mkdir $large_file_dir_tmp"

#for i in $(seq 1 20); do dd if=/dev/urandom iflag=fullblock of=myfile$i bs=4M count=256; done;
