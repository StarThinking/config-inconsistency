#!/bin/bash

if [ -z "$TEST_HOME" ]; then
    echo "TEST_HOME not set."
    exit 3
fi

for i in 30 31 32 33 34 35 36 37 38 39 40 60 61 62 120 200 2000
do
$TEST_HOME/sbin/run_hdfs_test.sh namenode dfs.image.compress false false online_reconfig $i
$TEST_HOME/sbin/run_hdfs_test.sh namenode dfs.image.compress false false cluster_stop $i
done 

for i in 30 31 32 33 34 35 36 37 38 39 40 60 61 62 120 200 2000
do
$TEST_HOME/sbin/run_hdfs_test.sh datanode dfs.image.compress false false online_reconfig $i
$TEST_HOME/sbin/run_hdfs_test.sh datanode dfs.image.compress false false cluster_stop $i
done 

for i in 30 31 32 33 34 35 36 37 38 39 40 60 61 62 120 200 2000
do
$TEST_HOME/run_hdfs_test.sh journalnode dfs.image.compress false false online_reconfig $i
$TEST_HOME/run_hdfs_test.sh journalnode dfs.image.compress false false cluster_stop $i
done 

