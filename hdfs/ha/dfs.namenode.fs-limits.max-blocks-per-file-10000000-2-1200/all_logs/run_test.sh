#!/bin/bash

if [ -z "$TEST_HOME" ]; then 
    echo "TEST_HOME not set."
    exit
fi

# if a script wants to be executed by itself, 
# it needs to load global variables
. $TEST_HOME/sbin/global_var.sh

if [ $# -lt 4 ]; then
    echo "./run_test [name] [value] [round] [waittime]"
    exit
fi

name=$1
value=$2
round=$3
waittime=$4

# create test dir
testdir="$TEST_HOME"/"$name"-"$value"-"$round"-"$waittime"
mkdir $testdir
cp $TEST_HOME/etc/hdfs-site-template.xml $testdir/hdfs-site.xml
sed -i "s/nametobereplaced/$name/g" $testdir/hdfs-site.xml
sed -i "s/valuetobereplaced/$value/g" $testdir/hdfs-site.xml
exec &> $testdir/run.log

# start the cluster
$TEST_HOME/sbin/cluster_cmd.sh start

# start running benchmark
# keep it running on the background on the client
ssh node-$clientnode-link-0 "/bin/bash --login $TEST_HOME/sbin/benchmark.sh start" &
client_benchmark_main_pid=$!

sleep 60

for i in $(seq 1 $round)
do
    # change configuration to be as given file
    $TEST_HOME/sbin/reconf.sh $testdir/hdfs-site.xml
    sleep $waittime
    # change configuration to be as given file
    $TEST_HOME/sbin/reconf.sh $TEST_HOME/etc/hdfs-site.xml
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
