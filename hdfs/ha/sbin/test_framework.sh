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

error_stage=1 # after pre 

function procedure {
    line=$1
    reconfig_mode=$2
    stop=0 
    
    component=$(echo $line | awk -F '[#| ]' '{print $1}')
    parameter=$(echo $line | awk -F '[#| ]' '{print $2}')
    value1=$(echo $line | awk -F '[#| ]' '{print $3}')
    value2=$(echo $line | awk -F '[#| ]' '{print $4}')
    tuple_dir="$component""$split""$parameter""$split""$value1""$split""$value2"
   # echo component=$component parameter=$parameter value1=$value1 value2=$value2
   # mkdir $tuple_dir 
   # cd $tuple_dir

    echo "run $reconfig_mode v1-v2 test"
    $TEST_HOME/sbin/run_hdfs_test.sh $component $parameter $value1 $value2 $reconfig_mode $waittime 
    test_12="$component""$split""$parameter""$split""$value1""$split""$value2""$split""$reconfig_mode""$split""$waittime"
    $TEST_HOME/sbin/util/cut_log.sh $test_12
    $TEST_HOME/sbin/util/stage.sh $test_12
    no_run_error_in_pre $test_12
    ret=$?
    if [ $ret -eq 0 ]; then
        echo "no run error in pre stage"
        subsetof $reconfig_mode $error_stage $test_12 
        ret=$?
        if [ $ret -eq 0 ]; then
            echo "no issue for $tuple_dir in stage $error_stage : test_12 < test_c, stop."
	    stop=1
        fi
    else
        echo "run error in pre stage, stop"
    	stop=1
    fi 

    if [ $stop -eq 0 ]; then
        echo "run $reconfig_mode v2-v2 test"
        $TEST_HOME/sbin/run_hdfs_test.sh $component $parameter $value2 $value2 $reconfig_mode $waittime 
        test_22="$component""$split""$parameter""$split""$value2""$split""$value2""$split""$reconfig_mode""$split""$waittime"
        $TEST_HOME/sbin/util/cut_log.sh $test_22
        $TEST_HOME/sbin/util/stage.sh $test_22
        no_run_error_in_pre $test_22
        ret=$?
        if [ $ret -eq 0 ]; then
            echo "no run error in pre stage"
            subsetof $reconfig_mode $error_stage $test_12 $test_22
            ret=$?
            if [ $ret -eq 0 ]; then
                echo "no issue for $tuple_dir in stage $error_stage : test_12 < test_c + test_22, stop."
                stop=1
            fi
        else
            echo "run error in pre stage, stop"
    	    stop=1
        fi 
    fi
    
    if [ $stop -eq 0 ]; then
        echo "run $reconfig_mode v1-v1 test"
        $TEST_HOME/sbin/run_hdfs_test.sh $component $parameter $value1 $value1 $reconfig_mode $waittime 
        test_11="$component""$split""$parameter""$split""$value1""$split""$value1""$split""$reconfig_mode""$split""$waittime"
        $TEST_HOME/sbin/util/cut_log.sh $test_11
        $TEST_HOME/sbin/util/stage.sh $test_11
        no_run_error_in_pre $test_11
        ret=$?
        if [ $ret -eq 0 ]; then
            echo "no run error in pre stage"
            subsetof $reconfig_mode $error_stage $test_12 $test_22 $test_11
            ret=$?
            if [ $ret -eq 0 ]; then
                echo "no issue for $tuple_dir in stage $error_stage : test_12 < test_c + test_22 + test_11, stop."
                stop=1
            fi
        else
            echo "run error in pre stage, stop"
    	    stop=1
        fi 
    fi

    return $stop
}

IFS=$'\n'      
set -f         
for line in $(cat < "$task_file")
do
    echo "---------------------------------------------------------"
    
    component=$(echo $line | awk -F '[#| ]' '{print $1}')
    parameter=$(echo $line | awk -F '[#| ]' '{print $2}')
    value1=$(echo $line | awk -F '[#| ]' '{print $3}')
    value2=$(echo $line | awk -F '[#| ]' '{print $4}')
    tuple_dir="$component""$split""$parameter""$split""$value1""$split""$value2"
    echo component=$component parameter=$parameter value1=$value1 value2=$value2
    mkdir $tuple_dir 
    cd $tuple_dir

    reconfig_mode=online_reconfig
    procedure $line $reconfig_mode  
    online_procedure_ret=$? 
    if [ $online_procedure_ret -eq 1 ]; then
	echo "online reconfigurable"
    else
        reconfig_mode=cluster_stop
	procedure $line $reconfig_mode
	cluster_procedure_ret=$?
	if [ $cluster_procedure_ret -eq 1 ]; then
	    echo "ISSUE : not online reconfigurable but cluster stop reconfigurable"
	else
	    echo "ISSUE : not reconfigurable"
	fi
    fi 
    #if [ $stop -eq 0 ]; then
    #    echo "run cluster v1-v2 test"
    #    reconfig_mode=cluster_stop
    #    $TEST_HOME/sbin/run_hdfs_test.sh $component $parameter $value1 $value2 $reconfig_mode $waittime 
    #    cluster_12="$component""$split""$parameter""$split""$value1""$split""$value2""$split""$reconfig_mode""$split""$waittime"
    #    subsetof $test_12 $test_22 $test_11 $cluster_12
    #    ret=$?
    #    if [ $ret -eq 0 ]; then
    #        echo "ISSUE for $tuple_dir : not reconfigurable!"
    #    else
    #        echo "ISSUE for $tuple_dir : not online reconfigurable!"
    #    fi
    #fi
     
    cd ..
    echo "---------------------------------------------------------"
done
