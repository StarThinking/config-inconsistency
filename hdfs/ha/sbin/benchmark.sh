#!/bin/bash

echo $TEST_HOME
if [ -z "$TEST_HOME" ]; then 
    echo "TEST_HOME not set."
    exit
fi

# if a script wants to be executed by itself, 
# it needs to load global variables
. $TEST_HOME/sbin/global_var.sh

# benchmark parameters
command=$1
read_times=$2
benchmark_threads=$3

# init benchmark
function init_benchmark {
    rm -rf $large_file_dir_tmp
    mkdir $large_file_dir_tmp
    rm /tmp/client*log

    for id in $(seq 1 $benchmark_threads)
    do
        $HADOOP_HOME/bin/hdfs dfs -put "$large_file_dir"/myfile"$id" /myfile"$id" &>> /tmp/client"$id".log
        $HADOOP_HOME/bin/hdfs dfs -ls /
        echo "file $id has been put into HDFS"
    done
}

# run benchmark
function start_benchmark { 
    #local testdir=$1
    
#    rm /tmp/pids

    # my benchmark
    for id in $(seq 1 $benchmark_threads)
    do
        . $TEST_HOME/sbin/sub_benchmark.sh $id &>> /tmp/client"$id".log &
#        echo $! >> /tmp/pids
	echo "sub benchmark $id started"
    done

    # nnbench
    #. $TEST_HOME/sbin/nnbench.sh &> /tmp/client-nnbench.log &

#    local pids=$(cat /tmp/pids)
#    
#    for i in ${pids[@]}
#    do
#        wait $i
#        echo "sub benchmark $i stopped"
#    done
}

if [ "$#" -eq 3 ]; then
    if [ $command == "start" ]; then
        start_benchmark
        exit 0
    elif [ $command == "init" ]; then
        init_benchmark
        exit 0
    fi
fi
        
echo "./benchmark.sh [init|start] [read_times] [benchmark_threads]"
