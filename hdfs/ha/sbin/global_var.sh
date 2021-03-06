#!/bin/bash

# cluster parameters

# HA cluster
#namenodes=(0 1)
#datanodes=(2 3 4) # make sure sdb is formatted
#journalnodes=(2 3 4) # modify hdfs-site.xml as well
#reconf_journalnode=4
#znodes=(0 1 5) # core-site.xml? zoo.cfg
#znode_ids=(1 2 3)
#clients=(5)
#allnodes=(0 1 2 3 4 5)

# 4 datanodes
namenodes=(0 1)
datanodes=(2 3 4 5) # make sure sdb is formatted
#reconf_datanode=5
journalnodes=(0 1 6) # modify hdfs-site.xml as well
#reconf_journalnode=6
znodes=(0 1 6) # core-site.xml?
znode_ids=(1 2 3)
clients=(6)
allnodes=(0 1 2 3 4 5 6)

# dir
hadoop_root_dir=/root/hdfs-root
hadoop_data_dir=$hadoop_root_dir/data # for datanode
journal_dir=$hadoop_root_dir/journal # for datanode
large_file_dir=$hadoop_root_dir/my_large_file # for client
large_file_dir_tmp=$hadoop_root_dir/my_large_file/tmp # for client
root_etc=$TEST_HOME/etc
root_data=$TEST_HOME/data

#
split="%" # must sync with awk split
read_times=10 # default value
benchmark_threads=5 # default value
#points=('endof_pre_stage' 'endof_reconfig_stage' 'endof_post_stage')
#valid_components=('cluster' 'active_namenode' 'standby_namenode' 'datanode' 'journalnode')
valid_components=('cluster' 'namenode' 'datanode' 'journalnode' 'none')

# error types
ERRORS=(COMMAND_ERROR RECONFIG_ERROR FATAL_ERROR SYSTEM_ERROR)
ERRORS_NUM=${#ERRORS[@]}
for ((i=0; i < $ERRORS_NUM; i++)); do
    name=${ERRORS[i]}
    declare ${name}=$i
done
