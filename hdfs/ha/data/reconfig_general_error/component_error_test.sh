#!/bin/bash

if [ -z "$TEST_HOME" ]; then
    echo "TEST_HOME not set."
    exit 3
fi

cmd=$TEST_HOME/sbin/test.sh 
for i in 30 40 50 60 100 120 180 200
do
$cmd namenode dfs.image.compress false false $i .
#$cmd datanode dfs.image.compress false false $i .
#$cmd journalnode dfs.image.compress false false $i .
#$cmd cluster dfs.image.compress false false $i .
done 

#for i in 50 100 200 400 1000
#do
#$TEST_HOME/sbin/run_hdfs_test.sh journalnode dfs.image.compress false false online_reconfig $i
#$TEST_HOME/sbin/run_hdfs_test.sh journalnode dfs.image.compress false false cluster_stop $i
#done 

#for i in 60 61 62 63 64 65 66 67 68 69 70 120 200 400 800 1000 1600
#do
#$TEST_HOME/sbin/run_hdfs_test.sh namenode dfs.image.compress false false online_reconfig $i
#$TEST_HOME/sbin/run_hdfs_test.sh namenode dfs.image.compress false false cluster_stop $i
#done 

