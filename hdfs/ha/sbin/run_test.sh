#!/bin/bash

if [ -z "$TEST_HOME" ]; then 
    echo "TEST_HOME not set."
    exit
fi

# if a script wants to be executed by itself, 
# it needs to load global variables
. $TEST_HOME/sbin/global_var.sh

if [ $# -lt 1 ]; then
    echo "./run_test TESTDIR"
    exit
fi

testdir=$1

# start the cluster
$TEST_HOME/sbin/cluster_cmd.sh start

# start running benchmark
ssh node-$clientnode-link-0 "/bin/bash --login $TEST_HOME/sbin/benchmark.sh start"

sleep 60

# change configuration to be as given file
$TEST_HOME/sbin/reconf.sh $testdir/hdfs-site.xml

sleep 300

# stop running benchmark
ssh node-$clientnode-link-0 "/bin/bash --login $TEST_HOME/sbin/benchmark.sh stop"

# collect logs for this test 
$TEST_HOME/sbin/cluster_cmd.sh collectlog $testdir

# stop and clean the cluster
$TEST_HOME/sbin/cluster_cmd.sh stop
