#!/bin/bash

if [ -z "$TEST_HOME" ]; then 
    echo "TEST_HOME not set."
    exit
fi

# if a script wants to be executed by itself, 
# it needs to load global variables
. $TEST_HOME/sbin/global_var.sh

if [ $# -lt 4 ]; then
    echo "./run_test [name] [value] [reconf_type: <namenode|datanode>] [hdfs-site.xml: <default|test>] [round] [waittime]"
    exit
fi

name=$1
value=$2
reconf_type=$3
init_hdfs_site=$4
round=1
waittime=60

# create test dir
testdir="$TEST_HOME"/"$name"-"$value"-"$round"-"$waittime"
mkdir $testdir
cp $TEST_HOME/etc/hdfs-site-template.xml $testdir/hdfs-site.xml
sed -i "s/nametobereplaced/$name/g" $testdir/hdfs-site.xml
sed -i "s/valuetobereplaced/$value/g" $testdir/hdfs-site.xml
exec &> $testdir/run.log

# start the cluster
if [ $init_hdfs_site = "default" ]; then
    echo "start with default hdfs-site.xml"
    $TEST_HOME/sbin/cluster_cmd.sh start
elif [ $init_hdfs_site = "test" ]; then
    echo "start with test hdfs-site.xml"
    $TEST_HOME/sbin/cluster_cmd.sh start $testdir/hdfs-site.xml
else
    echo "[hdfs-site.xml: <default|test>]"
fi

# start running benchmark
# keep it running on the background on the client
ssh node-$clientnode-link-0 "/bin/bash --login $TEST_HOME/sbin/benchmark.sh start" &
client_benchmark_main_pid=$!

sleep 30

for i in $(seq 1 $round)
do
    # change configuration to be as given file
    $TEST_HOME/sbin/reconf.sh $reconf_type $testdir/hdfs-site.xml
    sleep $waittime

    # change configuration to be as given file
    if [ $init_hdfs_site = "default" ]; then
        $TEST_HOME/sbin/reconf.sh $reconf_type $TEST_HOME/etc/hdfs-site.xml
    else
        $TEST_HOME/sbin/reconf.sh $reconf_type $testdir/hdfs-site.xml
    fi
    sleep $waittime
done

# stop running benchmark
ssh node-$clientnode-link-0 "/bin/bash --login $TEST_HOME/sbin/benchmark.sh stop"
echo "stop benchmark signal sent"
wait $client_benchmark_main_pid
echo "all benchmark sub processes on the client node exited"


# collect logs for this test 
$TEST_HOME/sbin/cluster_cmd.sh collectlog $testdir

# stop and clean the cluster
$TEST_HOME/sbin/cluster_cmd.sh stop
