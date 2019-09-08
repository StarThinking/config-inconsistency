#!/bin/bash

for i in 30 31 32 33 34 35 36 37 38 39 40 60 61 62 120 200 2000
do
../run_hdfs_test.sh namenode dfs.image.compress false false online_reconfig $i
../run_hdfs_test.sh namenode dfs.image.compress false false cluster_stop $i
done 

for i in 30 31 32 33 34 35 36 37 38 39 40 60 61 62 120 200 2000
do
../run_hdfs_test.sh datanode dfs.image.compress false false online_reconfig $i
../run_hdfs_test.sh datanode dfs.image.compress false false cluster_stop $i
done 

for i in 30 31 32 33 34 35 36 37 38 39 40 60 61 62 120 200 2000
do
../run_hdfs_test.sh journalnode dfs.image.compress false false online_reconfig $i
../run_hdfs_test.sh journalnode dfs.image.compress false false cluster_stop $i
done 

