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

component=$1
method=$2
file=$TEST_HOME/data/$method/"$component".txt

if [ ! -f $file ]; then
    echo "file $file not exist"
    exit 1
fi

para_num=$(wc -l $file | awk -F " " '{print $1}')
#echo para_num=$para_num
parameter_array=($(cat $file | awk -F " " '{print $1}'))
default_value_array=($(cat $file | awk -F " " '{print $2}'))

function call_getInt {
    for (( i=0; i<para_num; i++ ))
    do
        parameter=${parameter_array[$i]}
        v1=${default_value_array[$i]}
	v2_array_raw=()
        v2_array_raw+=( $(( v1 + 1 )) )
        v2_array_raw+=( $(( v1 * 2 )) )
        v2_array_raw+=( $(( v1 * 16 )) )
        v2_array_raw+=( $(( v1 - 1 )) )
        v2_array_raw+=( $(( v1 / 2 )) )
        v2_array_raw+=( $(( v1 / 16 )) )
        v2_array_raw+=( 0 )
        v2_array_raw+=( 1 )
        v2_array_raw+=( -1 )
        v2_array=( $(echo ${v2_array_raw[@]} | tr ' ' '\n' | sort -u | tr '\n' ' ') )

        for v2 in ${v2_array[@]}
        do
    	    if [ $v1 -ne $v2 ]; then
                echo $component $parameter $v1 $v2
    	    fi
        done
    done
}

function call_getBoolean {
    for (( i=0; i<para_num; i++ ))
    do
        echo $component ${parameter_array[$i]} false true
    done
}

call_$method

