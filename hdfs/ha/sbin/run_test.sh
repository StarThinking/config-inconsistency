#!/bin/bash

export TEST_HOME=/root/config-inconsistency/hdfs/ha

. $TEST_HOME/sbin/benchmark.sh

if [ $# -lt 1 ]; then
    echo "./run_test TESTDIR"
    exit
fi

testdir=$1

# start the cluster
$TEST_HOME/sbin/cluster_cmd.sh start

# start running benchmark
start_benchmark $testdir

sleep 30 

# change configuration to be as given file
$TEST_HOME/sbin/reconf.sh $testdir/hdfs-site.xml

sleep 30

# stop running benchmark
stop_benchmark $testdir

# collect logs for this test 
$TEST_HOME/sbin/cluster_cmd.sh collectlog $testdir

# stop and clean the cluster
$TEST_HOME/sbin/cluster_cmd.sh stop
