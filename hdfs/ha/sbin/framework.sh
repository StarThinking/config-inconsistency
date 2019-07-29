#!/bin/bash

# if a script wants to be executed by itself, 
# it needs to load global variables
. $TEST_HOME/sbin/global_var.sh

if [ $# -ne 2 ]; then
    echo "wrong arguments"
    exit 1
fi

task_file=$1
waittime=$2

IFS=$'\n'      
set -f         
for line in $(cat < "$task_file")
do
    component=$(echo $line | awk -F " " '{print $1}')
    parameter=$(echo $line | awk -F " " '{print $2}')
    value1=$(echo $line | awk -F " " '{print $3}')
    value2=$(echo $line | awk -F " " '{print $4}')
    reconfig_mode=online_reconfig
    tuple_dir="$component"_"$parameter"_"$value1"_"$value2"
    mkdir $tuple_dir 
    cd $tuple_dir
    echo component=$component parameter=$parameter value1=$value1 value2=$value2
    $TEST_HOME/sbin/run_hdfs_test.sh $component $parameter $value1 $value2 $reconfig_mode $waittime 

    testdir="$component"_"$parameter"_"$value1"_"$value2"_"$reconfig_mode"_"$waittime"
    $TEST_HOME/sbin/verify_result.sh $testdir
    ret=$?
    echo ret=$ret
    if [ $ret -ne 0 ]
    then
	echo "furthur checking..."
	reconfig_mode=cluster_stop
	$TEST_HOME/sbin/run_hdfs_test.sh $component $parameter $value1 $value2 $reconfig_mode $waittime
	reconfig_mode=online_reconfig
	$TEST_HOME/sbin/run_hdfs_test.sh $component $parameter $value1 $value1 $reconfig_mode $waittime
	$TEST_HOME/sbin/run_hdfs_test.sh $component $parameter $value2 $value2 $reconfig_mode $waittime
    else
	echo "no problem."
    fi

    echo ""
    cd ..
done

#verify_result.sh
