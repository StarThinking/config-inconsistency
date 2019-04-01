#!/bin/bash

if [ -z "$TEST_HOME" ]; then
    echo "TEST_HOME not set."
    exit
fi

# if a script wants to be executed by itself, 
# it needs to load global variables
. $TEST_HOME/sbin/global_var.sh

if [ "$#" -lt 7 ]
then
    echo "./binary_search.sh [min|max] [name] [default_value] [reconf_type] [round] [waittime] [time_senestive] [read_times] [benchmark_threads]" 
    exit
fi

min_or_max=$1
name=$2
default_value=$3
reconf_type=$4
round=$5
waittime=$6
time_sense=$7
read_times=10 # default value
benchmark_threads=5 # default value
if [ $# -eq 9 ]; then
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
    local waittime=21
    local ret=0 # 0 if ok, 1 if not ok
    local read_times=10
    local benchmark_threads=5

    echo "verify_input for parameter $name with value $value"

    $TEST_HOME/sbin/run_test.sh $name $value $reconf_type $test_mode $round $waittime $read_times $benchmark_threads
    local testdir="$TEST_HOME"/"$name"-"$value"-"$reconf_type"-"$test_mode"-"$round"-"$waittime"
   
    $TEST_HOME/sbin/verify_result.sh $testdir $reconf_type
    ret=$?
    echo "verify_result.sh parameter $name with value $value returns $ret" 
    rm -rf $testdir 
    return $ret   
}

retval=0 # pass return value to caller, as it can be larger than 255
function find_minimum {
    local range_start=1
    local range_end=1
    local middle=1

    # find range first
    for (( ; ; ))
    do
        verify_input $range_end
	if [ $? -eq 0 ]; then # might be too large
	    echo "break, set range_start = $range_start, range_end = $range_end"
	    break
	else # ret=1: too small, double
	    range_start=$(( range_end + 1 ))
	    range_end=$(( range_end * 2 ))
	fi
    done

    # find the minimum value in the range
    local max_step=5
    local steps=0
    for (( ; ; ))
    do
        middle=$(( (range_start + range_end ) / 2 ))
	
	if [ $range_start -ge $range_end ] || [ $steps -gt $max_step ]; then 
	    break
	fi

        verify_input $middle
        
        if [ $? -eq 0 ]; then # ok-branch: might be too large
 	    echo "ok branch"
    	    range_end=$middle
        else # not-ok-branch: too small
	    echo "not ok branch"
    	    range_start=$(( middle + 1 )) # it is important to add by 1
        fi

	steps=$(( steps + 1 ))
    done
    
    retval=$middle
    return 
}

retval=0 # pass return value to caller, as it can be larger than 255
function find_maximum {
    local range_start=$default_value
    local range_end=$default_value
    local middle=0
    local factor1=8
    local factor2=2
    local MAX=$(( (2**63) - 1 ))

    # find range first
    for (( ; ; ))
    do
        verify_input $range_end
	if [ $? -eq 1 ]; then # error
	    echo "break, set range_start = $range_start, range_end = $range_end"
    	    middle=$range_start
	    break
	elif [ $range_end -ge $(( MAX / factor1 )) ]; then # too large
	    echo "break, set range_start = $range_start, range_end = $range_end"
    	    middle=$range_end
	    break
	else # too small
	    range_start=$(( range_end ))
	    range_end=$(( range_end * factor1 ))
	fi
    done

    # find the maximum value in the range
   # local max_step=10
   # local steps=0
   # for (( ; ; ))
   # do
   #     middle=$(( (range_start + range_end ) / factor2 ))
   #     
   #     if [ $range_start -ge $range_end ] || [ $steps -gt $max_step ]; then 
   #         break
   #     fi

   #     verify_input $middle
   #     
   #     if [ $? -eq 0 ]; then # ok-branch
   #         echo "ok branch"
   # 	    break
   #     else # not-ok-branch
   #         echo "not ok branch"
   # 	    range_end=$middle 
   #     fi

   #     steps=$(( steps + 1 ))
   # done
    
    retval=$middle
    return 
}

echo > $TEST_HOME/bs_run.log
exec &> $TEST_HOME/bs_run.log

if [ $min_or_max = "min" ]; then
    find_minimum
elif [ $min_or_max = "max" ]; then
    find_maximum
else
    echo "Error: wrong argument."
fi
searched_value=$retval
echo "the $min_or_max value for parameter $name is $searched_value"

# do default test
$TEST_HOME/sbin/run_test.sh $name $searched_value $reconf_type default $round $waittime
testdir="$TEST_HOME"/"$name"-"$searched_value"-"$reconf_type"-"default"-"$round"-"$waittime"
mv $TEST_HOME/bs_run.log $testdir
