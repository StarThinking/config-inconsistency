#!/bin/bash

set -u

if [ -z "$TEST_HOME" ]; then
    echo "TEST_HOME not set."
    exit 3
fi

. $TEST_HOME/sbin/global_var.sh

if [ $# -ne 0 ]; then
    echo "wrong args"
    exit 1
fi

hdfs_para_list=$root_data/parameter_bank/parameter_hdfs.txt
core_para_list=$root_data/parameter_bank/parameter_core.txt

# check which configuration file this parameter belongs to, hdfs or core
function find_parameter {
    parameter=$1
    hdfs_or_core=""
    for p in $(cat $hdfs_para_list)
    do
        if [ "$p" == "$parameter" ] ; then
            hdfs_or_core="hdfs"
        fi
    done

    for p in $(cat $core_para_list)
    do
        if [ "$p" == "$parameter" ] ; then
            hdfs_or_core="core"
        fi
    done
    if [ "$hdfs_or_core" != "hdfs" ] && [ "$hdfs_or_core" != "core" ]; then
        return 1
    fi

    #echo "$hdfs_or_core"
    return 0
}

IFS=$'\n'
#for line in $(cat < "$task_file")
while read line
do
    #echo $line
    component=$(echo $line | awk -F '[%| ]' '{print $1}')
    parameter=$(echo $line | awk -F '[%| ]' '{print $2}')
    value1=$(echo $line | awk -F '[%| ]' '{print $3}')
    value2=$(echo $line | awk -F '[%| ]' '{print $4}')
    #echo $component $parameter
    if find_parameter $parameter; then
        echo "$component $parameter $value1 $value2"
    else
        echo "cannot find parameter $parameter" > /dev/null
    fi
done
