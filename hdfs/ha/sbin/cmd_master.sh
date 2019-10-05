#!/bin/bash
set -u

if [ -z "$TEST_HOME" ]; then
    echo "TEST_HOME not set."
    exit 3
fi

if [ $# -lt 5 ]; then
    echo "args are wrong: [test_id] [task_file] [wait_time] [repeat_times] [nodes..], exit"
    exit 1
fi

test_id=$1
task_file=$2
wait_time=30
repeat_times=1
shift 4
nodes=("$@")


echo "task_file is $task_file"
nodes_size=${#nodes[@]}
echo "nodes are ${nodes[@]}, nodes_size is $nodes_size"

split $task_file -d -n l/$nodes_size
split_prefix='x0'

for i in ${nodes[@]}
do
    task_file=$(pwd)/"$split_prefix""$i"
    echo "task for node-$i is:"
    cat $task_file
    ssh node-"$i" "cd $TEST_HOME; git pull"
    ssh node-"$i" "$TEST_HOME/sbin/cmd_slave.sh $test_id $i $task_file $wait_time $repeat_times"
    echo "cmd slave has been called for node-$i"  
    echo "" 
done

