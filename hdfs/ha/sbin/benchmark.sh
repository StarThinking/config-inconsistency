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

# run benchmark
function start_benchmark { 
    #local testdir=$1
    
    rm -rf $large_file_dir_tmp/*
    rm /tmp/client*log
#    rm /tmp/pids

    # my benchmark
    for i in $(seq 1 $benchmark_threads)
    do
        . $TEST_HOME/sbin/sub_benchmark.sh $i &> /tmp/client"$i".log &
#        echo $! >> /tmp/pids
	echo "sub benchmark $i started"
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

if [ "$#" -lt 3 ]; then
    echo "./benchmark.sh [start] [read_times] [benchmark_threads]"
    exit
fi

if [ $command == "start" ]; then
    start_benchmark
else
    echo "./benchmark.sh [start] [read_times] [benchmark_threads]"
fi
