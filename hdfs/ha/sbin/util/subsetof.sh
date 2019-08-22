#!/bin/bash

#for split="#"
. $TEST_HOME/sbin/global_var.sh

errorset_names=('online_component' 'online_22' 'online_11' 'cluster_12')

function subsetof {
    ret=0

    online_12=$1

    # generate run errors
    online_12_run_errors=$(grep -r "TEST_ERROR" $online_12/run.log | sort -u)
 
    # generate system errors
    online_12_system_errors=$(grep -r "WARN\|ERROR\|FATAL" $online_12 | awk -F " " '{ if ($3 == "WARN" || $3 == "ERROR" || $3 == "FATAL") print $5}' | sort -u)
    
    shift 1
    union_size=0
    while [ $# -ge 1 ]; do
	union_size=$(( union_size + 1 ))
        dir=$1
	#echo "dir = $dir"
	# generate run errors
	dir_run_errors[$union_size]=$(grep -r "TEST_ERROR" $dir/run.log | sort -u)
#	echo "dir_run_errors[$union_size] is:"
#	echo ${dir_run_errors[$union_size]}
 
	# generate system errors
	dir_system_errors[$union_size]=$(grep -r "WARN\|ERROR\|FATAL" $dir | awk -F " " '{ if ($3 == "WARN" || $3 == "ERROR" || $3 == "FATAL") print $5}' | sort -u)
#	echo no. of dir_system_errors[$union_size] is $(echo ${dir_system_errors[$union_size]} | wc -w)
#	echo "dir_system_errors[$union_size] is:"
#	echo ${dir_system_errors[$union_size]}

        shift 1
    done	
    echo "subsetof with union_size $union_size"

    # because online_component_errors do not have any runtime errors
    #if [ "$online_12_run_errors" != "" ]; then
    #    grep -r "TEST_ERROR" $online_12/run.log | awk '{printf "%s", "run.log: "} {print $0}'
    #fi
 
    component=$(echo $online_12 | awk -F "$split" 'NR==1 {print $1}')
    root_base_dir=$TEST_HOME/sbin/base_error_set
    echo "Error_base is online_reconfig_"$component"_base.txt"
    online_component_errors=$root_base_dir/online_reconfig_"$component"_base.txt
 
    for err in ${online_12_system_errors[@]}; do
	found=-1
        if [ "$(grep $err $online_component_errors)" != "" ]; then
	    found=0
            echo "$err is found in ${errorset_names[$found]}"
	else
	    union_index=1
	    while [ $union_size -ge $union_index ]; do
		for e in ${dir_system_errors[$union_index]}; do
		    if [ "$err" == "$e" ]; then
			found=$union_index
                        echo "$err is found in ${errorset_names[$found]}"
		    fi  
		done
		union_index=$(( union_index + 1 ))
	    done
        fi

	if [ $found -lt 0 ]; then
	    ret=1
	    echo -n "$err CANNOT be found in error set ${errorset_names[0]}"
            union_index=1
            while [ $union_size -ge $union_index ]; do
                echo -n ", ${errorset_names[$union_index]} "
                union_index=$(( union_index + 1 ))
            done
            echo ""
	fi
    done

    echo "subsetof returns $ret" 
    echo ""
    return $ret
}

