#!/bin/bash

# if a script wants to be executed by itself, 
# it needs to load global variables
. $TEST_HOME/sbin/global_var.sh
. $TEST_HOME/sbin/util/subsetof.sh

if [ $# -ne 2 ]; then
    echo "wrong arguments: [task_file] [waittime]"
    exit 1
fi

task_file=$1
waittime=$2

IFS=$'\n'      
set -f         
for line in $(cat < "$task_file")
do
    echo "---------------------------------------------------------"
    stop=0 
    component=$(echo $line | awk -F '[#| ]' '{print $1}')
    parameter=$(echo $line | awk -F '[#| ]' '{print $2}')
    value1=$(echo $line | awk -F '[#| ]' '{print $3}')
    value2=$(echo $line | awk -F '[#| ]' '{print $4}')
    tuple_dir="$component""$split""$parameter""$split""$value1""$split""$value2"
    echo component=$component parameter=$parameter value1=$value1 value2=$value2
    mkdir $tuple_dir 
    cd $tuple_dir

    echo "run online v1-v2 test"
    reconfig_mode=online_reconfig
    $TEST_HOME/sbin/run_hdfs_test.sh $component $parameter $value1 $value2 $reconfig_mode $waittime 
    online_12="$component""$split""$parameter""$split""$value1""$split""$value2""$split""$reconfig_mode""$split""$waittime"
    subsetof $online_12
    ret=$?
    if [ $ret -eq 0 ]; then
        echo "no issue for $tuple_dir : online_12 < online_c, stop."
	stop=1
    fi

    if [ $stop -eq 0 ]; then
        echo "run online v2-v2 test"
        reconfig_mode=online_reconfig
        $TEST_HOME/sbin/run_hdfs_test.sh $component $parameter $value2 $value2 $reconfig_mode $waittime 
        online_22="$component""$split""$parameter""$split""$value2""$split""$value2""$split""$reconfig_mode""$split""$waittime"
        subsetof $online_12 $online_22
        ret=$?
        if [ $ret -eq 0 ]; then
            echo "no issue for $tuple_dir : online_12 < online_c + online_22, stop."
            stop=1
        fi
    fi
    
    if [ $stop -eq 0 ]; then
        echo "run online v1-v1 test"
        reconfig_mode=online_reconfig
        $TEST_HOME/sbin/run_hdfs_test.sh $component $parameter $value1 $value1 $reconfig_mode $waittime 
        online_11="$component""$split""$parameter""$split""$value1""$split""$value1""$split""$reconfig_mode""$split""$waittime"
        subsetof $online_12 $online_22 $online_11
        ret=$?
        if [ $ret -eq 0 ]; then
            echo "no issue for $tuple_dir: online_12 < online_c + online_22 + online_11, stop."
            stop=1
        fi
    fi

    if [ $stop -eq 0 ]; then
        echo "run cluster v1-v2 test"
        reconfig_mode=cluster_stop
        $TEST_HOME/sbin/run_hdfs_test.sh $component $parameter $value1 $value2 $reconfig_mode $waittime 
        cluster_12="$component""$split""$parameter""$split""$value1""$split""$value2""$split""$reconfig_mode""$split""$waittime"
        subsetof $online_12 $online_22 $online_11 $cluster_12
        ret=$?
        if [ $ret -eq 0 ]; then
            echo "ISSUE for $tuple_dir : not reconfigurable!"
        else
            echo "ISSUE for $tuple_dir : not online reconfigurable!"
        fi
    fi
     
    echo "---------------------------------------------------------"
    cd ..
done
