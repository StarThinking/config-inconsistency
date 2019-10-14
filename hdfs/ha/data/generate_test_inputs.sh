#!/bin/bash

set -u

if [ -z "$TEST_HOME" ]; then
    echo "TEST_HOME not set."
    exit 3
fi
. $TEST_HOME/sbin/global_var.sh

if [ $# -ne 2 ]; then
    echo "wrong args"
    exit 1
fi

method=$1
component=$2
file=$TEST_HOME/data/$method/"$component".txt
para_zero_list=$root_data/parameter_bank/zero.txt
para_minusone_list=$root_data/parameter_bank/minusone.txt

if [ ! -f $file ] || [ ! -f $para_zero_list ] || [ ! -f $para_minusone_list ]; then
    echo "file $file or $para_zero_list or $para_minusone_list not exist"
    exit 1
fi

para_num=$(wc -l $file | awk -F " " '{print $1}')
parameter_array=($(cat $file | awk -F " " '{print $1}'))
default_value_array=($(cat $file | awk -F " " '{print $2}'))

function call_getInt {
    threshold=10
    for (( i=0; i<para_num; i++ ))
    do
        parameter=${parameter_array[$i]}
        v1=${default_value_array[$i]}
	v2_array_raw=()
        v2_array_raw+=( 1 )
        if [ $v1 -eq 0 ] || [ $v1 -eq -1 ]; then
	    v2_array_raw+=( 0 )
	    v2_array_raw+=( 8 )
	    v2_array_raw+=( 4096 )
        else
   	    if [ $v1 -le $threshold ]; then
                v2_array_raw+=( $(( v1 + 1 )) )
                v2_array_raw+=( $(( v1 - 1 )) )
            fi
            v2_array_raw+=( $(( v1 * 2 )) )
            v2_array_raw+=( $(( v1 / 2 )) )
            v2_array_raw+=( $(( v1 * 128 )) )
            v2_array_raw+=( $(( v1 / 128 )) )
        fi

	# zero
	grep $parameter $para_zero_list > /dev/null
        if [ $? -eq 0 ]; then
	    # echo "zero"
	    v2_array_raw+=( 0 )
        fi

	# minus one
	grep $parameter $para_minusone_list > /dev/null
        if [ $? -eq 0 ]; then
            #echo "minus one"
	    v2_array_raw+=( -1 )
	fi
		
	# remove duplication
        v2_array=( $(echo ${v2_array_raw[@]} | tr ' ' '\n' | sort -u | tr '\n' ' ') )

        for v2 in ${v2_array[@]}
        do
    	    if [ $v1 -ne $v2 ]; then
                echo $component $parameter $v1 $v2
                echo $component $parameter $v2 $v1
    	    fi
        done
    done
}

function call_getLong {
    for (( i=0; i<para_num; i++ ))
    do
        parameter=${parameter_array[$i]}
        v1=${default_value_array[$i]}
	v2_array_raw=()
        v2_array_raw+=( $(( v1 * 2 )) )
        v2_array_raw+=( $(( v1 * 16 )) )
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

function call_getFloat {
    for (( i=0; i<para_num; i++ ))
    do
        parameter=${parameter_array[$i]}
        v1=${default_value_array[$i]}
        for v2 in 0.01 0.1 0.5 0.9 0.99
        do
    	    if [ $(bc <<< "$v1 != $v2") -eq 1 ]; then
                echo $component $parameter $v1 $v2
    	    fi
        done
    done
}

function call_getBoolean {
    for (( i=0; i<para_num; i++ ))
    do
        echo $component ${parameter_array[$i]} false FALSE
        echo $component ${parameter_array[$i]} true TRUE
    done
}

call_$method

