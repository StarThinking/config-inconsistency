#!/bin/bash

if [ -z "$TEST_HOME" ]; then
    echo "TEST_HOME not set."
    exit
fi

# if a script wants to be executed by itself, 
# it needs to load global variables
. $TEST_HOME/sbin/global_var.sh

if [ "$#" -ne 3 ]
then
    echo "./binary_search.sh [name] [reconf_type] [time_senestive]"
    exit
fi

name=$1
reconf_type=$2
time_sense=$3

function verify_input {
    local value=$1
    local test_mode=verifyinput
    if [ $time_sense -eq 1 ]; then
        test_mode=test
    fi
    local round=1
    local waittime=30
    local ret=0 # 0 if ok, 1 if not ok
    local read_times=10
    local benchmark_threads=5

    echo "verify_input for parameter $name with value $value"

    $TEST_HOME/sbin/run_test.sh $name $value $reconf_type $test_mode $round $waittime $read_times $benchmark_threads
    testdir="$TEST_HOME"/"$name"-"$value"-"$test_mode"-"$round"-"$waittime"
   
    $TEST_HOME/sbin/verify_result.sh $testdir $reconf_type 
    ret=$?
    echo "verify_result.sh parameter $name with value $value returns $ret"   
    return $ret   
}

function find_minimum {
    local range_start=1
    local range_end=1
    
    # find range_start and range_end roughly
    for (( ; ; ))
    do
        verify_input $range_end
	local ret=$?
	if [ $ret -eq 0 ]; then # might be too large
	    echo "set range_end as $range_end"
	    break
	else # ret=1: too small, double
	    range_start=$range_end
	    range_end=$(( range_end * 2 ))
	fi
    done

    if [ $time_sense -eq 1 ]; then
	return $range_end
    fi

    local lowest=$(( (range_start + range_end ) / 2 ))
    if [ $range_start -eq $range_end ]; then
	return $lowest
    fi	
    
    # find the lowest value in the range
    for (( ; ; ))
    do
        verify_input $lowest
        local ret=$?
        if [ $ret -eq 0 ]; then # might be too large
    	    local distance=$(( range_end - range_start ))
    	    if [ $distance -le 2 ]; then
    	    	break
    	    else
    	        range_end=$lowest
    	        lowest=$(( ( range_end + range_start ) / 2 ))
    	    fi
        else # ret=1: too small
    	    range_start=$lowest
    	    lowest=$(( (range_end + range_start) / 2 ))
        fi
    done
    
    return $lowest
}

find_minimum
minimum_value=$?
echo "the minimum value for parameter $name is $minimum_value"
$TEST_HOME/sbin/run_test.sh $name $minimum_value namenode default 1 300 10 5
#$TEST_HOME/sbin/run_test.sh $name $minimum_value namenode test 1 300 10 5
