#!/bin/bash
set -u

if [ -z "$TEST_HOME" ]; then
    echo "TEST_HOME not set."
    exit 3
fi

if [ $# -ne 2 ]; then
    echo "wrong args"
    exit 1
fi

n=$1
dir=$2

for i in $(seq 1 8)
do
    for component in namenode datanode journalnode
    do
        for reconf in online cluster
        do
            $TEST_HOME/data/base_error_set/get_error_set.sh $dir/component_errors_n"$n"."$i"/"$component"*"$reconf"* >> "$reconf"_"$component"_n"$n".txt
        done
    done
done
