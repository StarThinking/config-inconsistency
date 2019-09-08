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
nodes=('namenode' 'datanode' 'journalnode' 'client')

for stage_id in $(seq 0 ${#points[@]})
do
    # run.log
    mkdir $testdir/$stage_id
    mv $testdir/run.log'#'$stage_id $testdir/$stage_id

    # namenode datanode journalnode client
    mkdir $testdir/$stage_id/all_logs
    for node_name in ${nodes[@]}
    do
	array_name="$node_name"s
	mkdir $testdir/$stage_id/all_logs/$array_name
	mv $testdir/all_logs/$array_name/*"#$stage_id"* $testdir/$stage_id/all_logs/$array_name
    done
done
