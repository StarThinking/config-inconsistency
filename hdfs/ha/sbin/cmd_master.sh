#!/bin/bash
set -u

if [ -z "$TEST_HOME" ]; then
    echo "TEST_HOME not set."
    exit 3
fi

function start_test {
    if [ $# -lt 5 ]; then
        echo "args are wrong: [test_id] [task_file] [wait_time] [repeat_times] [nodes..], exit"
        return 1
    fi
    
    test_id=$1
    task_file=$2
    wait_time=$3
    repeat_times=$4
    shift 4
    nodes=("$@")
    
    
    echo "task_file is $task_file"
    nodes_size=${#nodes[@]}
    echo "nodes are ${nodes[@]}, nodes_size is $nodes_size"
    
    split $task_file -d -n l/$nodes_size
    sub_task_files=($(ls | grep x0 | sort -u))
    echo "sub_task_files is ${sub_task_files[@]}"
    
    for (( i=0; i<nodes_size; i++ ))
    do
        node_id=${nodes[i]}
        ssh node-"$node_id" "cd $TEST_HOME; git pull"
    done
    
    echo "finished node git pull"
    
    for (( i=0; i<nodes_size; i++ ))
    do
        node_id=${nodes[i]}
        sub_task_file=$(pwd)/${sub_task_files[i]}
        echo "sub_task_file for node-$node_id is:"
        cat $sub_task_file
        ssh node-"$node_id" "$TEST_HOME/sbin/cmd_slave.sh 'start_test' $test_id $node_id $sub_task_file $wait_time $repeat_times"
        echo "cmd slave has been called for node-$node_id"  
        echo "" 
    done
}

function collect_result {
    if [ $# -lt 2 ]; then
        echo "ERROR: wrong args"
        return 1
    fi

    test_id=$1 # based on date and time
    shift 1
    nodes=("$@")
    
    if [ ! -f ~/$test_id ]; then
        echo "~/$test_id not existed"
        return 1
    fi

    for (( i=0; i<nodes_size; i++ ))
    do
        node_id=${nodes[i]}
        ssh node-"$node_id" "$TEST_HOME/sbin/cmd_slave.sh 'collect_result' $test_id $node_id"
    done
}

if [ $# -lt 2 ]; then
    echo "ERROR: wrong args, quit"
    exit 2
fi

cmd=$1
shift 1
if [ "$cmd" == 'start_test' ] || [ "$cmd" == 'collect_result' ]; then
    $cmd $@
else
    echo "ERROR: wrong cmd $cmd"
fi
