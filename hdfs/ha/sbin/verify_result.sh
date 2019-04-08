#!/bin/bash

if [ -z "$TEST_HOME" ]; then
    echo "TEST_HOME not set."
    exit
fi

if [ $# -lt 2 ]; then
    echo "./verify_result.sh [testdir] [reconf_type] optional: [error_base_file]"
    exit
fi

testdir=$1
reconf_type=$2
ret=0 # 0 for ok, 1 for error

if [ $# -eq 2 ]; then
    error_base=$TEST_HOME/sbin/base_error_set/"$reconf_type"_base.txt
elif [ $# -eq 3 ]; then
    error_base=$3
else
    echo "Error: wrong number of aruguments"
    exit 1
fi

# check errors in test log
run_error=$(grep -r TEST_ERROR $testdir/run.log) 
if [ "$run_error" != "" ]; then
    echo "Error: TEST_ERROR found in run.log!"
    ret=1
fi

# check errors in client log
client_error=$(grep -r TEST_ERROR $testdir/all_logs/clients) 
if [ "$client_error" != "" ]; then
    echo "Error: TEST_ERROR found in clients!"
    ret=1
fi

# check errors HDFS log
errors=($(grep -r "WARN\|ERROR\|FATAL" $testdir | awk -F " " '{ if ($3 == "WARN" || $3 == "ERROR" || $3 == "FATAL") print $5}' | sort -u))

for err in ${errors[@]}
do
    found=$(grep $err $error_base)
    if [ "$found" != "" ]; then
        #echo "$err found in normal_error"
        continue
    else
        echo "$err NOT found in base error set"
        ret=1
    fi
done

exit $ret
