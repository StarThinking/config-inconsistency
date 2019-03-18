#!/bin/bash

if [ -z "$TEST_HOME" ]; then
    echo "TEST_HOME not set."
    exit
fi

# if a script wants to be executed by itself, 
# it needs to load global variables
. $TEST_HOME/sbin/global_var.sh

if [ "$#" -ne 2 ]
then
    echo "./binary_search.sh [name] [reconf_type]"
    exit
fi

name=$1
reconf_type=$2

function verify_input {
    local value=$1
    local test_mode=verifyinput
    local round=1
    local waittime=60
    local ret=0 # 0 if ok, 1 if not ok
    local read_times=1
    local benchmark_threads=1

    echo "verify_input for parameter $name with value $value"

    $TEST_HOME/sbin/run_test.sh $name $value $reconf_type $test_mode $round $waittime $read_times $benchmark_threads
    testdir="$TEST_HOME"/"$name"-"$value"-"$test_mode"-"$round"-"$waittime"
    errors=($(grep -r "WARN\|ERROR\|FATAL" $testdir | awk -F " " '{ if ($3 == "WARN" || $3 == "ERROR") print $5}' | sort -u))
    
    for err in ${errors[@]}
    do
        local found=$(grep $err $TEST_HOME/sbin/"$reconf_type"_base.txt)
	if [ "$found" != "" ]; then
   	    #echo "$err found in normal_error"
	    continue
	else
	    echo "$err NOT found in base error set"
	    ret=1 
	fi
    done
  
    #rm -rf $testdir  
    echo "ret = $ret"   
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
	    range_end=$(( range_end * 2 ))
	    range_start=$range_end
	fi
    done

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
echo "the minimum value for parameter $name is $?"

