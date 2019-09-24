#!/bin/bash
set -u

# if a script wants to be executed by itself, 
# it needs to load global variables
. $TEST_HOME/sbin/global_var.sh
. $TEST_HOME/sbin/util/system_error_subsetof.sh
. $TEST_HOME/sbin/util/error_helper.sh

if [ $# -ne 2 ]; then
    echo "wrong arguments: [task_file] [waittime]"
    exit 1
fi

task_file=$1
waittime=$2
reconfigurable=1
test_cmd=$TEST_HOME/sbin/test.sh

# return 0 if no errors
# return 1 if errors
function check_reconfig_fatal_errors {
    test=$1
    if [ "$(generate_reconfig_errors $test)" != '' ]; then
	echo "[MARK_RECONFIG_ERROR]"
    fi
    if [ "$(generate_reconfig_errors $test)" != '' ] || [ "$(generate_fatal_errors $test)" != '' ]; then
        echo "reconfig error:"
	generate_reconfig_errors $test
        echo "fatal error:"
	generate_fatal_errors $test
	return 1
    fi
    return 0
}

# return >1 if command errors in subtest
function procedure {
    component=$1
    parameter=$2
    value1=$3
    value2=$4
    test_12="$component""$split""$parameter""$split""$value1""$split""$value2""$split""$waittime"
    test_22="$component""$split""$parameter""$split""$value2""$split""$value2""$split""$waittime"
    test_11="$component""$split""$parameter""$split""$value1""$split""$value1""$split""$waittime"

    #### v1-v2 ####   
    echo "run $component v1-v2 reconfig test"
    $test_cmd $component $parameter $value1 $value2 $waittime
    # make sure no command error
    if [ "$(generate_command_errors $test_12)" != '' ]; then
        echo "command error:"
	generate_command_errors $test_12
	echo "[MARK_COMMAND_ERROR]command error in test_12, quit"
	return 1
    fi

    #### component ####
    system_error_subsetof $test_12 
    ret1=$?
    # check reconfig and fatal error
    check_reconfig_fatal_errors $test_12
    ret2=$?
    if [ $ret1 -eq 0 ] && [ $ret2 -eq 0 ]; then
        echo "system error of test_12 is subset of test_c and there's no fatal error."
	echo "--> MAYBE $component reconfigurable, quit."
        return 0
    else
	echo "system error of test_12 is NOT subset of test_c or it has fatal error, continue."
    fi

    #### v2-v2 ####
    echo "run $component v2-v2 reconfig test"
    $test_cmd $component $parameter $value2 $value2 $waittime 
    # make sure no command error
    if [ "$(generate_command_errors $test_22)" != '' ]; then
        echo "command error:"
	generate_command_errors $test_22
	echo "[MARK_COMMAND_ERROR]command error in test_22."
	echo "--> NO CONCLUSION, quit."
	return 1
    fi
    # make sure no reconfig and fatal error
    check_reconfig_fatal_errors $test_22
    if [ $? -eq 0 ]; then
	echo "no reconfig and fatal errors in test_22, continue."	
    else
	echo "Reconfig or Fatal errors in test_22."
	echo " --> NO CONCLUSION, quit."
	return 0
    fi
   
    #### v1-v1 ####
    echo "run $component v1-v1 reconfig test"
    $test_cmd $component $parameter $value1 $value1 $waittime
    # make sure no command error
    if [ "$(generate_command_errors $test_11)" != '' ]; then    
        echo "command error:"
	generate_command_errors $test_11
	echo "[MARK_COMMAND_ERROR]command error in test_11."
	echo "--> NO CONCLUSION, quit."
	return 1
    fi
    # make sure no reconfig and fatal error
    check_reconfig_fatal_errors $test_11
    if [ $? -eq 0 ]; then
	echo "no reconfig and fatal errors in test_11, continue."	
    else
	echo "Reconfig or Fatal errors in test_11."
	echo "--> NO CONCLUSION, quit."
	return 0
    fi
   
    #### final check ####
    # check reconfig and fatal error
    check_reconfig_fatal_errors $test_12
    if [ $? -ne 0 ]; then
	echo "[MARK_NOT_RECONFIGURABLE]reconfig or fatal errors in test_12."
	echo "--> NOT $component reconfigurable, quit."
	reconfigurable=0
	return 0
    fi
    # check system error
    system_error_subsetof $test_12 $test_22 $test_11
    if [ $? -eq 0 ]; then
        echo "system error of test_12 is subset of union (test_c, test_22, test_11)."
	echo "--> MAYBE $component reconfigurable, quit."
    else
	echo "[MARK_NOT_RECONFIGURABLE]system error of test_12 is NOT subset of union(test_c, test_22, test_11)."
	echo "--> NOT $component reconfigurable, continue."
	reconfigurable=0
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

    reconfigurable=1 # global variable
    procedure $component $parameter $value1 $value2
    if [ $? -ne 0 ]; then
	echo "[MARK_COMMAND_ERROR]command error in the test, quit"
    fi 

    if [ $reconfigurable -ne 1 ]; then # not online reconfigurable  
	echo "" 
	echo "not online $component reconfigurable, continue"
	component=cluster
	reconfigurable=1 # global variable
	procedure $component $parameter $value1 $value2
	if [ $? -ne 0 ]; then
	    echo "[MARK_COMMAND_ERROR]command error in the test, quit"
        fi
    fi 

    cd ..
    echo "---------------------------------------------------------"
done
