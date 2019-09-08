#!/bin/bash

if [ -z "$TEST_HOME" ]; then
    echo "TEST_HOME not set."
    exit
fi

if [ $# -ne 1 ]; then
    echo "./verify_result.sh [testdir]"
    exit 1
fi


split="#"
testdir=$1
root_dir=$TEST_HOME/sbin/base_error_set
ret=0 # 0 for ok, 1 for error

if [[ $testdir == *"cluster_stop"* ]]; then
    error_base=$root_dir/cluster_reboot_base.txt
    echo "Error_base is cluster_reboot_base.txt"
else
    sub_log=$(echo $testdir | awk -F "$split" 'NR==1 {print $1}')
    echo "Error_base is online_reconfig_"$sub_log"_base.txt"
    error_base=$root_dir/online_reconfig_"$sub_log"_base.txt
fi

# check errors in our test log
test_errors=$(grep -r "TEST_ERROR" $testdir/run.log)
if [ "$test_errors" != "" ]; then
    ret=1
fi
grep -r "TEST_ERROR" $testdir/run.log | awk '{printf "%s", "run.log: "} {print $0}' 

# check errors in HDFS log
for sub_log in all_logs/clients all_logs/namenodes all_logs/datanodes all_logs/journalnodes
do
    errors=$(grep -r "WARN\|ERROR\|FATAL" $testdir/$sub_log | awk -F " " '{ if ($3 == "WARN" || $3 == "ERROR" || $3 == "FATAL") print $5}' | sort -u)
    
    for err in ${errors[@]}
    do
        found=$(grep $err $error_base)
        if [ "$found" != "" ]; then
            #echo "$err found in normal_error"
            continue
        else
            echo "$sub_log: $err not existed in base error set!"
            ret=1
        fi
    done
done

if [ $ret -eq 0 ]; then
    echo "NO NEW ERROR FOUND"
fi
echo ""

exit $ret
