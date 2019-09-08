#!/bin/bash

if [ -z "$TEST_HOME" ]; then 
    echo "TEST_HOME not set."
    exit
fi

# if a script wants to be executed by itself, 
# it needs to load global variables
. $TEST_HOME/sbin/global_var.sh

#if [ "$#" -lt 1 ]
#then
#    echo "e.g., ./cluster_cmd.sh [start|stop|collectlog|start_client|stop_client|stop_client_gracefully] optional: [hdfs-site.xml] [read_times] [benchmark_threads]"
#    exit
#fi

testdir=$1
nodes=('namenode' 'datanode' 'journalnode')

function cut_one_log {
    log_file=$1
    echo "log to be cut is $log_file"
    head_line=0
    tail_line=0
    part_id=0
    total_line=$(wc -l $log_file | cut -d' ' -f1)
    for p in ${points[@]}
    do
	head_line=$tail_line
        tail_line=$(grep -rn $p $log_file | cut -d':' -f1)
	length=$(( tail_line - head_line ))
	head -n $tail_line $log_file | tail -n $length >> "$log_file"'#'"$part_id"
	part_id=$(( part_id + 1 ))
    done
    length=$(( total_line - tail_line ))
    tail -n $length $log_file >> "$log_file"'#'"$part_id"
}

for node_name in ${nodes[@]}
do
    array_name="$node_name"s
    eval array=\( \${${array_name}[@]} \)
    for i in ${array[@]}
    do
        cut_one_log $testdir/all_logs/$array_name/hadoop-root-"$node_name"-node-"$i"-link-0.log
    done
done


for c in $(seq 1 $benchmark_threads)
do
     cut_one_log $testdir/all_logs/clients/client$c.log
done

cut_one_log $testdir/run.log

