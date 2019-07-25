#!/bin/bash

for i in 30 31 60 61 62 120 200 500 3700
do
./sbin/run_test.bak.sh namenode dfs.image.compress false false online_reconfig $i
done 

for i in 30 31 60 61 62 120 200 500 3700
do
./sbin/run_test.bak.sh datanode dfs.image.compress false false online_reconfig $i
done 

for i in 30 31 60 61 62 120 200 500 3700
do
./sbin/run_test.bak.sh journalnode dfs.image.compress false false online_reconfig $i
done 
