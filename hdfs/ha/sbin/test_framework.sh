#!/bin/bash
set -u

# if a script wants to be executed by itself, 
# it needs to load global variables
. $TEST_HOME/sbin/global_var.sh
. $TEST_HOME/sbin/util/subsetof.sh
. $TEST_HOME/sbin/util/error_helper.sh

if [ $# -ne 2 ]; then
    echo "wrong arguments: [task_file] [waittime]"
    exit 1
fi

task_file=$1
waittime=$2
online_reconfigurable=1

# return >1 if command errors in subtest
function procedure {
    component=$1
    parameter=$2
    value1=$3
    value2=$4
    reconfig_mode=$5
    test_12="$component""$split""$parameter""$split""$value1""$split""$value2""$split""$reconfig_mode""$split""$waittime"
    test_22="$component""$split""$parameter""$split""$value2""$split""$value2""$split""$reconfig_mode""$split""$waittime"
    test_11="$component""$split""$parameter""$split""$value1""$split""$value1""$split""$reconfig_mode""$split""$waittime"

    #### v1-v2 ####   
    echo "run $reconfig_mode v1-v2 test"
    $TEST_HOME/sbin/sub_test.sh $component $parameter $value1 $value2 $reconfig_mode $waittime 
    # make sure no command error
    if [ $? -ne 0 ]; then
	echo "command error in test_12, quit"
	return 1
    fi

    subsetof $reconfig_mode $test_12 
    if [ $? -eq 0 ]; then
        echo "test_12 is subset of test_c, quit."
        return 0
    else
	echo "test_12 is NOT subset of test_c, continue."
    fi

    #### v2-v2 ####
    echo "run $reconfig_mode v2-v2 test"
    $TEST_HOME/sbin/sub_test.sh $component $parameter $value2 $value2 $reconfig_mode $waittime 
    # make sure no command error
    if [ $ret -eq 0 ]; then
	echo "command error in test_22, quit"
	return 1
    fi

    # make sure no reconfig and fatal error
    if [ "$(generate_reconfig_errors $test_22)" != '' ] || [ "$(generate_fatal_errors $test_22)" != '' ]; then
	echo "reconfig or fatal errors in test_22, quit"
	return 0
    else
	echo "no reconfig and fatal errors in test_22, continue"	
    fi
    
    #### v1-v1 ####
    echo "run $reconfig_mode v1-v1 test"
    $TEST_HOME/sbin/sub_test.sh $component $parameter $value1 $value1 $reconfig_mode $waittime 
    # make sure no command error
    if [ $ret -eq 0 ]; then
	echo "command error in test_11, quit"
	return 1
    fi

    # make sure no reconfig and fatal error
    if [ "$(generate_reconfig_errors $test_11)" != '' ] || [ "$(generate_fatal_errors $test_11)" != '' ]; then
	echo "reconfig or fatal errors in test_11, quit"
	return 0
    else
	echo "no reconfig and fatal errors in test_11, continue"	
    fi
   
    #### final check ####
    # check reconfig and fatal error
    if [ "$(generate_reconfig_errors $test_12)" != '' ] || [ "$(generate_fatal_errors $test_12)" != '' ]; then
        echo "reconfig_errors:"
	generate_reconfig_errors $test_12
        echo "fatal_errors:"
	generate_fatal_errors $test_12
	echo "reconfig or fatal errors in test_12 --> NOT online reconfigurable, quit"
	online_reconfigurable=0
	return 0
    fi

    # check system error
    subsetof $reconfig_mode $test_12 $test_22 $test_11
    if [ $? -eq 0 ]; then
        echo "test_12 is subset of union (test_c, test_22, test_11) --> MAYBE online reconfigurable, quit."
    else
	echo "test_12 is NOT subset of union(test_c, test_22, test_11) --> NOT online reconfigurable, quit"
	online_reconfigurable=0
    fi
    
    return 0
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
    test_dir="$component""$split""$parameter""$split""$value1""$split""$value2"

    echo "start test procedure for component=$component parameter=$parameter value1=$value1 value2=$value2"
    mkdir $test_dir 
    cd $test_dir

    reconfig_mode=online_reconfig
    online_reconfigurable=1 # global variable
    procedure $component $parameter $value1 $value2 $reconfig_mode  
    if [ $? -ne 0 ]; then
	echo "command error in the test, exit"
    fi 
    
    cd ..
    echo "---------------------------------------------------------"
done
