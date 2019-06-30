#!/bin/bash

if [ -z "$TEST_HOME" ]; then 
    echo "TEST_HOME not set."
    exit
fi

# if a script wants to be executed by itself, 
# it needs to load global variables
. $TEST_HOME/sbin/global_var.sh

argument_num=6
argument_num_optional=8
if [ $# -lt $argument_num ]; then
    echo "./run_test [component: <namenode|datanode|journalnode>] [parameter] [value1] [value2] [reconfig_mode: <cluster_stop|online_reconfig] [waittime] optional: [read_times] [benchmark_threads]"
    exit
fi

component=$1
parameter=$2
value1=$3
value2=$4
reconfig_mode=$5 # cluster_stop|online_reconfig
waittime=$6
read_times=10 # default value
benchmark_threads=5 # default value
if [ $# -eq $argument_num_optional ]; then
    read_times=$7
    benchmark_threads=$8
fi

if [ $reconfig_mode != "cluster_stop" ] && [ $reconfig_mode != "online_reconfig" ]; then
    echo "reconfig_mode: cluster_stop | online_reconfig"
    exit
fi

# create test dir
testdir=./"$component"-"$parameter"-"$value1"-"$value2"-"$reconfig_mode"-"$waittime"
mkdir $testdir

# create two hdfs-site.xml
parameter_stub=nametobereplaced
value_stub=valuetobereplaced
cp $TEST_HOME/etc/hdfs-site-template.xml $testdir/hdfs-site.xml.1
cp $TEST_HOME/etc/hdfs-site-template.xml $testdir/hdfs-site.xml.2
sed -i "s/$parameter_stub/$parameter/g" $testdir/hdfs-site.xml.1
sed -i "s/$parameter_stub/$parameter/g" $testdir/hdfs-site.xml.2
sed -i "s/$value_stub/$value1/g" $testdir/hdfs-site.xml.1
sed -i "s/$value_stub/$value2/g" $testdir/hdfs-site.xml.2
exec &> $testdir/run.log

# main procedure

# start the cluster
echo "start cluster"
$TEST_HOME/sbin/cluster_cmd.sh start $testdir/hdfs-site.xml.1
# start benchmark running on client
$TEST_HOME/sbin/cluster_cmd.sh start_client $read_times $benchmark_threads
sleep $waittime

# perform reconfiguration 
# stop benchmark running on client before reconfiguration
$TEST_HOME/sbin/cluster_cmd.sh stop_client

if [ $reconfig_mode = "online_reconfig" ]; then
    echo "performing $reconfig_mode ..."
    $TEST_HOME/sbin/reconf.sh $component $testdir/hdfs-site.xml.2
    if [ $? -ne 0 ]; then
        echo "TEST_ERROR: $reconfig_mode reconfiguration $component failed"
    fi

    # start benchmark running on client again
    $TEST_HOME/sbin/cluster_cmd.sh start_client $read_times $benchmark_threads
    sleep $waittime

    echo "performing $reconfig_mode ..."
    $TEST_HOME/sbin/reconf.sh $component $testdir/hdfs-site.xml.1
    if [ $? -ne 0 ]; then
        echo "TEST_ERROR: $reconfig_mode reconfiguration $component failed"
    fi

elif [ $reconfig_mode = "cluster_stop" ]; then
    echo "performing $reconfig_mode ..."
    # stop and clean the cluster
    $TEST_HOME/sbin/cluster_cmd.sh stop
    sleep 2
    $TEST_HOME/sbin/cluster_cmd.sh start $testdir/hdfs-site.xml.2
fi


# stop benchmark running on client
$TEST_HOME/sbin/cluster_cmd.sh stop_client

# collect logs for this test 
$TEST_HOME/sbin/cluster_cmd.sh collectlog $testdir

# stop and clean the cluster
$TEST_HOME/sbin/cluster_cmd.sh stop
