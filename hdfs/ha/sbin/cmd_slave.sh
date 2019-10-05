#!/bin/bash
set -u

TEST_HOME=/root/config-inconsistency/hdfs/ha

if [ -z "$TEST_HOME" ]; then
    echo "TEST_HOME not set."
    exit 3
fi

if [ $# -ne 5 ]; then
    echo "ERROR: wrong args, quit"
    exit 2
fi

cmd_master='node-0'
test_id=$1 # based on date and time
node_id=$2
task_file=$3
wait_time=$4
repeat_times=$5

test_dir=~/"$test_id"-node-$node_id
mkdir $test_dir

vm0=$(virsh domifaddr node-0-link-0 | grep ipv4 | awk -F " " '{print $4}' | cut -d"/" -f1)
echo vm0 is $vm0

# fetch task from cmd_master
scp $cmd_master:$task_file $test_dir/task.txt
if [ $? -ne 0 ]; then
    echo "ERROR: fetch task from cmd_master failed! quit"
    exit 4
fi

echo "send test_dir $test_dir to vm0"
scp -r $test_dir $vm0:~
rm -rf $test_dir

echo "git pull for vm0 on node-$node_id"
ssh $vm0 "cd $TEST_HOME; git pull"

echo "starting test_framework..."
# hard-coded wait time and repeat times
nohup ssh $vm0 "cd $test_dir; export wait_time=$wait_time; export repeat_times=$repeat_times; nohup bash --login $TEST_HOME/sbin/test_framework.sh ./task.txt $wait_time $repeat_times >> nohup.txt &" &
