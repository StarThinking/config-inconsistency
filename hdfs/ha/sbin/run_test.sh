#!/bin/bash

if [ -z "$TEST_HOME" ]; then 
    echo "TEST_HOME not set."
    exit
fi

# if a script wants to be executed by itself, 
# it needs to load global variables
. $TEST_HOME/sbin/global_var.sh

if [ $# -lt 6 ]; then
    echo "./run_test [name] [value] [reconf_type: <namenode|datanode>] [test_mode: <default|test|verifyinput>] [round] [waittime] optional: [read_times] [benchmark_threads]"
    exit
fi

name=$1
value=$2
reconf_type=$3
test_mode=$4 # default, test, verifyinput
round=$5
waittime=$6
read_times=5 # default value
benchmark_threads=10 # default value
if [ $# -eq 8 ]; then
    read_times=$7
    benchmark_threads=$8
fi
client_benchmark_main_pid=0

# start running benchmark. keep it running on the background on the client
function start_client {
    for i in ${clients[@]}
    do
        ssh node-$i-link-0 "/bin/bash --login $TEST_HOME/sbin/benchmark.sh start $read_times $benchmark_threads" &
    done
    client_benchmark_main_pid=$!
}

# stop running benchmark
function stop_client {
    for i in ${clients[@]}
    do
        ssh node-$i-link-0 "/bin/bash --login $TEST_HOME/sbin/benchmark.sh stop"
    done
    
    echo "stop benchmark signal sent"
    #wait $client_benchmark_main_pid
    sleep 30
    ssh node-$i-link-0 "ps aux | grep benchmark.sh | awk -F ' ' '{print $2}' | xargs kill -9"
    ssh node-$i-link-0 "ps aux | grep FsShell | awk -F ' ' '{print $2}' | xargs kill -9"
    echo "all benchmark sub processes on the client node has exited"
}

# create test dir
testdir="$TEST_HOME"/"$name"-"$value"-"$test_mode"-"$round"-"$waittime"
mkdir $testdir
cp $TEST_HOME/etc/hdfs-site-template.xml $testdir/hdfs-site.xml
sed -i "s/nametobereplaced/$name/g" $testdir/hdfs-site.xml
sed -i "s/valuetobereplaced/$value/g" $testdir/hdfs-site.xml
exec &> $testdir/run.log

# start the cluster
if [ $test_mode = "default" ]; then
    echo "start with default hdfs-site.xml"
    $TEST_HOME/sbin/cluster_cmd.sh start
elif [ $test_mode = "test" ]; then
    echo "start with test hdfs-site.xml"
    $TEST_HOME/sbin/cluster_cmd.sh start $testdir/hdfs-site.xml
elif [ $test_mode = "verifyinput" ]; then
    echo "start test to verify input parameter value"
    $TEST_HOME/sbin/cluster_cmd.sh start $testdir/hdfs-site.xml
else
    echo "[hdfs-site.xml: <default|test|verifyinput>]"
fi

# start benchmark running on client
start_client

# main test procedure
if [ $test_mode = "default" ] || [ $test_mode = "test" ]; then
    sleep $waittime
    
    for i in $(seq 1 $round)
    do
        # change configuration to be as given file
        $TEST_HOME/sbin/reconf.sh $reconf_type $testdir/hdfs-site.xml
        reconf_ret=$?
        if [ $reconf_ret != 0 ]; then
	    echo "TEST_ERROR: reconf $reconf_type failed"
	    break
	fi
        
	sleep $waittime
    
        # change configuration as the given conf file
        if [ $test_mode = "default" ]; then
            $TEST_HOME/sbin/reconf.sh $reconf_type $TEST_HOME/etc/hdfs-site.xml
        else
            $TEST_HOME/sbin/reconf.sh $reconf_type $testdir/hdfs-site.xml
        fi
        
        reconf_ret=$?
        if [ $reconf_ret != 0 ]; then
	    echo "TEST_ERROR: reconf $reconf_type failed"
            break
	fi
        
        sleep $waittime
    done
else # verifyinput branch
    for i in $(seq 1 $round)
    do
	sleep $waittime
    done
fi

# stop benchmark running on client
stop_client

# collect logs for this test 
$TEST_HOME/sbin/cluster_cmd.sh collectlog $testdir

# stop and clean the cluster
$TEST_HOME/sbin/cluster_cmd.sh stop
