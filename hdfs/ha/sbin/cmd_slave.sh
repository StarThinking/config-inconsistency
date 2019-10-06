#!/bin/bash
set -u

TEST_HOME=/root/config-inconsistency/hdfs/ha

if [ -z "$TEST_HOME" ]; then
    echo "TEST_HOME not set."
    exit 3
fi

cmd_master='node-0'

function start {
    if [ $# -ne 5 ]; then
        echo "ERROR: wrong args"
        return 1
    fi

    test_id=$1 # based on date and time
    node_id=$2
    task_file=$3
    wait_time=$4
    repeat_times=$5
    
    test_dir=~/"$test_id"-node-$node_id
    mkdir $test_dir
    
    vm0=$(virsh domifaddr node-0-link-0 | grep ipv4 | awk -F " " '{print $4}' | cut -d"/" -f1)
    echo vm0 is $vm0
    echo "git pull for vm0 on node-$node_id"
    ssh $vm0 "cd $TEST_HOME; git pull > /dev/null"
    echo "" 
  
    # fetch task from cmd_master
    scp $cmd_master:$task_file $test_dir/task.txt
    if [ $? -ne 0 ]; then
        echo "ERROR: fetch task from cmd_master failed! quit"
        exit 4
    fi
    
    echo "send test_dir $test_dir to vm0"
    scp -r $test_dir $vm0:~
    rm -rf $test_dir
    
    echo "starting test_framework..."
    # hard-coded wait time and repeat times
    nohup ssh $vm0 "cd $test_dir; export wait_time=$wait_time; export repeat_times=$repeat_times; nohup bash --login $TEST_HOME/sbin/test_framework.sh ./task.txt $wait_time $repeat_times >> nohup.txt &" &

    return 0
}

function collect {
    if [ $# -ne 2 ]; then
        echo "ERROR: wrong args"
        return 1
    fi
    
    test_id=$1 # based on date and time
    node_id=$2
    test_dir=~/"$test_id"-node-$node_id
    
    vm0=$(virsh domifaddr node-0-link-0 | grep ipv4 | awk -F " " '{print $4}' | cut -d"/" -f1)
    echo vm0 is $vm0
    echo "git pull for vm0 on node-$node_id"
    ssh $vm0 "cd $TEST_HOME; git pull > /dev/null"
    echo "" 
    
    # fetech test_dir from vm0
    scp -r $vm0:$test_dir ~
    if [ $? -ne 0 ]; then
        echo "WARN: $vm0 doesn't have $test_dir"
        return 1
    fi
    echo "fetched test_dir $test_dir from vm0"   
    
    sleep 2
    
    scp -r $test_dir $cmd_master:~/$test_id
    if [ $? -ne 0 ]; then
	echo "ERROR: $cmd_master might not have dir $test_id"
	return 1
    fi
    echo "sent test_dir $test_dir from node-$node_id to $cmd_master ir $test_id
"
    return 0
}

function list {
    if [ $# -ne 2 ]; then
        echo "ERROR: wrong args"
        return 1
    fi

    test_id=$1 # based on date and time
    node_id=$2
    test_dir=~/"$test_id"-node-$node_id
    
    vm0=$(virsh domifaddr node-0-link-0 | grep ipv4 | awk -F " " '{print $4}' | cut -d"/" -f1)
    echo vm0 is $vm0
    echo "git pull for vm0 on node-$node_id"
    ssh $vm0 "cd $TEST_HOME; git pull > /dev/null"
    echo "" 
    
    echo "$test_id"-node-$node_id :
    ssh $vm0 "ls -l $test_dir"
    echo "task.txt:"
    ssh $vm0 "cat $test_dir/task.txt"
    ssh $vm0 "grep -rn 'new_line_end' $test_dir | wc -l; echo "/" b=$(cat $test_dir/task.txt | wc -l); echo $a out of $b"
    echo ""
}

if [ $# -lt 2 ]; then
    echo "ERROR: wrong args, quit"
    exit 2
fi

cmd=$1
shift 1
if [ "$cmd" == 'start' ] || [ "$cmd" == 'collect' ] || [ "$cmd" == 'list' ]; then
    $cmd $@
    exit $?
else
    echo "ERROR: wrong cmd $cmd"
    exit 1
fi
