#!/bin/bash

#for split="#"
. $TEST_HOME/sbin/global_var.sh

errorset_names=('online_component' 'online_22' 'online_11' 'cluster_12')

function subsetof {
    ret=0

    online_12=$1
    shift 1

    # generate run errors
    online_12_run_errors=$(grep -r "TEST_ERROR" $online_12/run.log | awk -F "[\]\[]" '{print $2}' 2>/dev/null)
 
    # generate system errors
    online_12_system_errors=$(grep -r "WARN\|ERROR\|FATAL" $online_12 | awk -F " " '{ if ($3 == "WARN" || $3 == "ERROR" || $3 == "FATAL") print $5}' | sort -u)
    
    # union 0 only has system errors but no run errors
    union_size=0
    component=$(echo $online_12 | awk -F "$split" 'NR==1 {print $1}')
    root_base_dir=$TEST_HOME/sbin/base_error_set
    echo "Error_base is online_reconfig_"$component"_base.txt"
    online_component_errors=$root_base_dir/online_reconfig_"$component"_base.txt
    system_error_unions[0]=$(cat $online_component_errors)
    testrun_error_unions[0]=''

    # generate run and system error unions for union 1 2 3
    while [ $# -ge 1 ]; do
	union_size=$(( union_size + 1 ))
        dir=$1
	#echo "dir = $dir"
	testrun_error_unions[$union_size]=$(grep -r "TEST_ERROR" $dir/run.log | sort -u)
 
	# generate system errors
	system_error_unions[$union_size]=$(grep -r "WARN\|ERROR\|FATAL" $dir | awk -F " " '{ if ($3 == "WARN" || $3 == "ERROR" || $3 == "FATAL") print $5}' | sort -u)
        shift 1
    done	
    echo "subsetof with union_size $union_size"

    touch errors_found.tmp.txt
    touch errors_not_found.tmp.txt
    for err in ${online_12_system_errors[@]}; do
	found=-1
	union_index=0
	while [ $union_size -ge $union_index ]; do
	    for e in ${system_error_unions[$union_index]}; do
	        if [ "$err" == "$e" ]; then
	    	found=$union_index
                    echo "[$found] $err is found in ${errorset_names[$found]} " >> errors_found.tmp.txt
                    break
	        fi  
	    done

            if [ $found -ge 0 ]; then
                break
            else # keep search in the next union 
	        union_index=$(( union_index + 1 ))
            fi
	done

	if [ $found -lt 0 ]; then
	    ret=1
	    echo -n "[$found] $err CANNOT be found in error set ${errorset_names[0]}" >> errors_not_found.tmp.txt
            union_index=1
            while [ $union_size -ge $union_index ]; do
                echo -n ", ${errorset_names[$union_index]} " >> errors_not_found.tmp.txt
                union_index=$(( union_index + 1 ))
            done
            echo "" >> errors_not_found.tmp.txt
	fi
    done

    echo "System Errors:"
    cat errors_found.tmp.txt | sort -u
    cat errors_not_found.tmp.txt | sort -u
    rm  errors_found.tmp.txt
    rm errors_not_found.tmp.txt
    
    touch errors_found.tmp.txt
    touch errors_not_found.tmp.txt
    for err in ${online_12_run_errors[@]}; do
	found=-1
	union_index=0
	while [ $union_size -ge $union_index ]; do
	    for e in ${testrun_error_unions[$union_index]}; do
	        if [ "$err" == "$e" ]; then
	    	found=$union_index
                    echo "[$found] $err is found in ${errorset_names[$found]} " >> errors_found.tmp.txt
                    break
	        fi  
	    done

            if [ $found -ge 0 ]; then
                break
            else # keep search in the next union 
	        union_index=$(( union_index + 1 ))
            fi
	done

	if [ $found -lt 0 ]; then
	    ret=1
	    echo -n "[$found] $err CANNOT be found in error set ${errorset_names[0]}" >> errors_not_found.tmp.txt
            union_index=1
            while [ $union_size -ge $union_index ]; do
                echo -n ", ${errorset_names[$union_index]} " >> errors_not_found.tmp.txt
                union_index=$(( union_index + 1 ))
            done
            echo "" >> errors_not_found.tmp.txt
	fi
    done

    echo "Test Run Errors:"
    cat errors_found.tmp.txt | sort -u
    cat errors_not_found.tmp.txt | sort -u
    rm  errors_found.tmp.txt
    rm errors_not_found.tmp.txt

    echo "subsetof returns $ret" 
    echo ""
    return $ret
}

