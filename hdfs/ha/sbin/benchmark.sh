#!/bin/bash

. ./global_var.sh

# run benchmark
function start_benchmark { 
    $testdir=$1
    
    rm -rf $large_file_dir_tmp/*

    for i in $(seq 1 $benchmark_threads)
    do
        ./sub_benchmark.sh $i &> $testdir/client"$i".log &
        pids[$i]=$!
	echo "sub benchmark $i started"
    done
}

# kill and wait benchmark finish
function stop_benchmark {
    $testdir=$1
    
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
