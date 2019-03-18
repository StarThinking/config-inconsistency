#!/bin/bash

if [ -z "$TEST_HOME" ]; then
    echo "TEST_HOME not set."
    exit
fi

testdir=$1
reconf_type=$2
ret=0
error_base=$TEST_HOME/sbin/base_error_set/"$reconf_type"_base.txt

# check if test itself and client is valid
test_error=$(grep -r TEST_ERROR $testdir) 
if [ "$test_error" != "" ]; then
    echo "Error: test_error found!"
    ret=1
fi

# check HDFS
errors=($(grep -r "WARN\|ERROR\|FATAL" $testdir | awk -F " " '{ if ($3 == "WARN" || $3 == "ERROR") print $5}' | sort -u))

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
