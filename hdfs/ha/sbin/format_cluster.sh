#!/bin/bash

if [ -z "$TEST_HOME" ]; then
    echo "TEST_HOME not set."
    exit
fi

. $TEST_HOME/sbin/global_var.sh

# mkfs sdb and create hadoop root dir for allnode
for i in ${allnodes[@]}
do
#    ssh node-$i-link-0 "printf '%s\n' n '' '' '' '' w | fdisk /dev/sdb"
#    ssh node-$i-link-0 "mkfs.ext4 /dev/sdb1"
    ssh node-$i-link-0 "mkdir $hadoop_root_dir"
done

# create dir for datanode
for i in ${datanodes[@]}
do
    ssh node-$i-link-0 "mkdir $hadoop_data_dir"
done

# create dir for journal node
for i in ${jnodes[@]}
do
    ssh node-$i-link-0 "mkdir $journal_dir"
done

# create dir for client node
for i in ${clients[@]}
do
    ssh node-$i-link-0 "mkdir $large_file_dir; mkdir $large_file_dir_tmp"
done

#for i in $(seq 1 20); do dd if=/dev/urandom iflag=fullblock of=myfile$i bs=4M count=256; done;
