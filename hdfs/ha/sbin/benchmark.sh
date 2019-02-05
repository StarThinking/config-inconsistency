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
read_times=1
benchmark_threads=1

# run benchmark
function start_benchmark { 
    #local testdir=$1
    
    rm -rf $large_file_dir_tmp/*
    rm /tmp/client*log

    for i in $(seq 1 $benchmark_threads)
    do
        . $TEST_HOME/sbin/sub_benchmark.sh $i &> /tmp/client"$i".log &
        pids[$i]=$!
	echo "sub benchmark $i started"
    done
}

# kill and wait benchmark finish
function stop_benchmark {
    #local testdir=$1
    
    for i in $(seq 1 $benchmark_threads)
    do
        kill ${pids[$i]}
    done
    
    for i in $(seq 1 $benchmark_threads)
    do
        wait ${pids[$i]}
	echo "sub benchmark $i stopped"
    done
}

if [ "$#" -ne 1 ]; then
    echo "benchmark.sh [start|stop]"
    exit
fi

command=$1
if [ $command == "start" ]; then
    start_benchmark
elif [ $command == "stop" ]; then
    stop_benchmark
else
    echo "error: wrong arguments. benchmark.sh [start|stop]"
fi
