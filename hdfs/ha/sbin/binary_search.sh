#!/bin/bash

if [ -z "$TEST_HOME" ]; then
    echo "TEST_HOME not set."
    exit
fi

# if a script wants to be executed by itself, 
# it needs to load global variables
. $TEST_HOME/sbin/global_var.sh

if [ "$#" -lt 5 ]
then
    echo "./binary_search.sh [name] [reconf_type] [round] [waittime] [time_senestive] [read_times] [benchmark_threads]" 
    exit
fi

name=$1
reconf_type=$2
round=$3
waittime=$4
time_sense=$5
read_times=10 # default value
benchmark_threads=5 # default value
if [ $# -eq 8 ]; then
    read_times=$6
    benchmark_threads=$7
fi

function verify_input {
    local value=$1
    local test_mode=verifyinput
    if [ $time_sense -eq 1 ]; then
        test_mode=test
    fi
    local round=1
    local waittime=31
    local ret=0 # 0 if ok, 1 if not ok
    local read_times=10
    local benchmark_threads=6

    echo "verify_input for parameter $name with value $value"

    $TEST_HOME/sbin/run_test.sh $name $value $reconf_type $test_mode $round $waittime $read_times $benchmark_threads
    local testdir="$TEST_HOME"/"$name"-"$value"-"$reconf_type"-"$test_mode"-"$round"-"$waittime"
   
    $TEST_HOME/sbin/verify_result.sh $testdir $reconf_type 
    ret=$?
    echo "verify_result.sh parameter $name with value $value returns $ret"   
    return $ret   
}

retval=0 # pass return value to caller, as it can be larger than 255
function find_minimum {
    local range_start=1
    local range_end=1
    local lowest=1

    # find range first
    for (( ; ; ))
    do
        verify_input $range_end
	if [ $? -eq 0 ]; then # might be too large
	    echo "break, set range_end as $range_end"
	    break
	else # ret=1: too small, double
	    range_start=$range_end
	    range_end=$(( range_end * 2 ))
	fi
    done

    # find the lowest value in the range
    local max_step=5
    local steps=0
    for (( ; ; ))
    do
        lowest=$(( (range_start + range_end ) / 2 ))
	
	if [ $range_start -ge $range_end ] || [ $steps -gt $max_step ]; then 
	    break
	fi

        verify_input $lowest
        
        if [ $? -eq 0 ]; then # ok-branch: might be too large
 	    echo "ok branch"
    	    range_end=$lowest
        else # not-ok-branch: too small
	    echo "not ok branch"
    	    range_start=$(( lowest + 1 )) # it is important to add by 1
        fi
	steps=$(( steps + 1 ))
    done
    
    retval=$lowest
    return 
}

echo > $TEST_HOME/bs_run.log
exec &> $TEST_HOME/bs_run.log
find_minimum
minimum_value=$retval
echo "the minimum value for parameter $name is $minimum_value"
$TEST_HOME/sbin/run_test.sh $name $minimum_value $reconf_type default $round $waittime
testdir="$TEST_HOME"/"$name"-"$minimum_value"-"$reconf_type"-"default"-"$round"-"$waittime"
mv $TEST_HOME/bs_run.log $testdir
$TEST_HOME/sbin/run_test.sh $name $minimum_value $reconf_type test $round $waittime
#$TEST_HOME/sbin/run_test.sh $name $minimum_value namenode test 1 300 10 5
