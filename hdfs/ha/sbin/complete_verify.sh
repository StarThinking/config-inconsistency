#!/bin/bash

# if a script wants to be executed by itself, 
# it needs to load global variables
. $TEST_HOME/sbin/global_var.sh

if [ $# -ne 2 ]; then
    echo 'wrong arguments!'
    exit 1
fi

split="#"
ret=0
testdir=$1
waittime=$2
component=$(echo $testdir | awk -F "$split" '{print $1}')
parameter=$(echo $testdir | awk -F "$split" '{print $2}')
value1=$(echo $testdir | awk -F "$split" '{print $3}')
value2=$(echo $testdir | awk -F "$split" '{print $4}')
echo component=$component parameter=$parameter value1=$value1 value2=$value2

reconfig_mode=online_reconfig
subdir[1]="$component""$split""$parameter""$split""$value1""$split""$value2""$split""$reconfig_mode""$split""$waittime"
$TEST_HOME/sbin/verify_result.sh $testdir/${subdir[1]} > /dev/null
if [ $? -eq 0 ]
then
    echo "no issue"
    exit 0
fi

reconfig_mode=cluster_stop
subdir[2]="$component""$split""$parameter""$split""$value1""$split""$value2""$split""$reconfig_mode""$split""$waittime"
reconfig_mode=online_reconfig
subdir[3]="$component""$split""$parameter""$split""$value1""$split""$value1""$split""$reconfig_mode""$split""$waittime"
subdir[4]="$component""$split""$parameter""$split""$value2""$split""$value2""$split""$reconfig_mode""$split""$waittime"

for i in 1 2 3 4
do
    #echo "error$i :"
    error[$i]=$(grep -r "WARN\|ERROR\|FATAL" $testdir/${subdir[i]} | awk -F " " '{ if ($3 == "WARN" || $3 == "ERROR" || $3 == "FATAL") print $5}' | sort -u)
    #echo ${error[i]}
done

general_reconfig_errorbase=$TEST_HOME/sbin/base_error_set/online_reconfig_"$component"_base.txt
for err in ${error[1]}
do
    found1=0 #general_reconfig_errorbase
    found2=0
    found3=0
    found4=0

    
    if [ "$(grep $err $general_reconfig_errorbase)" != "" ]
    then
	found1=1
    fi
 
    for e in ${error[2]}
    do
	if [ "$err" == "$e" ]; then
	    found2=1
	fi
    done
    
    for e in ${error[3]}
    do
	if [ "$err" == "$e" ]; then
	    found3=1
	fi
    done
    
    for e in ${error[4]}
    do
	if [ "$err" == "$e" ]; then
	    found4=1
	fi
    done
    
    if [ $found1 -eq 0 ] && [ $found2 -eq 0 ] && [ $found3 -eq 0 ]
    then
        echo "$err cannot be found in error[1-3]"
	if [ $found4 -eq 0 ]
	then
            ret=1
	else
            ret=2
	fi
    fi
done


if [ $ret -eq 0 ]
then
    echo "no issue as errors can be found in error[1-3]"
elif [ $ret -eq 1 ]
then
    echo "not online reconfigurable"
elif [ $ret -eq 2 ]
then
    echo "not reconfigurable"
fi
