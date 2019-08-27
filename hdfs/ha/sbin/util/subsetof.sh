#!/bin/bash

#for split="#"
. $TEST_HOME/sbin/global_var.sh

errorset_names=('online_component' 'online_22' 'online_11' 'cluster_12')

function generate_run_errors {
    dir=$1
    grep -r "TEST_ERROR" $dir/run.log | awk -F "[\]\[]" '{print $2}' 2>/dev/null
}

function generate_system_errors {
    dir=$1
    grep -r "WARN\|ERROR\|FATAL" $dir | awk -F " " '{ if ($3 == "WARN" || $3 == "ERROR" || $3 == "FATAL") print $5}' | sort -u 2>/dev/null
}

function subsetof {
    ret=0

    online_12=$1
    shift 1

    # generate run and system errors for online_12
    online_12_run_errors=$(generate_run_errors $online_12)
    online_12_system_errors=$(generate_system_errors $online_12)
    
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
        testrun_error_unions[$union_size]=$(generate_run_errors $dir)
	system_error_unions[$union_size]=$(generate_system_errors $dir)
        shift 1
    done	

    touch system_errors_found.tmp.txt
    touch system_errors_not_found.tmp.txt
    touch run_errors_found.tmp.txt
    touch run_errors_not_found.tmp.txt
    
    # search for system errors
    for err in ${online_12_system_errors[@]}; do
	found=-1
	union_index=0
	while [ $union_size -ge $union_index ]; do
	    for e in ${system_error_unions[$union_index]}; do
	        if [ "$err" == "$e" ]; then
	    	found=$union_index
                    echo "[$found] $err is found in ${errorset_names[$found]} " >> system_errors_found.tmp.txt
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
	    echo -n "[$found] $err CANNOT be found in error set ${errorset_names[0]}" >> system_errors_not_found.tmp.txt
            union_index=1
            while [ $union_size -ge $union_index ]; do
                echo -n ", ${errorset_names[$union_index]} " >> system_errors_not_found.tmp.txt
                union_index=$(( union_index + 1 ))
            done
            echo "" >> system_errors_not_found.tmp.txt
	fi
    done
    
    # saerch for run errors
    for err in ${online_12_run_errors[@]}; do
	found=-1
	union_index=0
	while [ $union_size -ge $union_index ]; do
	    for e in ${testrun_error_unions[$union_index]}; do
	        if [ "$err" == "$e" ]; then
	    	found=$union_index
                    echo "[$found] $err is found in ${errorset_names[$found]} " >> run_errors_found.tmp.txt
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
	    echo -n "[$found] $err CANNOT be found in error set ${errorset_names[0]}" >> run_errors_not_found.tmp.txt
            union_index=1
            while [ $union_size -ge $union_index ]; do
                echo -n ", ${errorset_names[$union_index]} " >> run_errors_not_found.tmp.txt
                union_index=$(( union_index + 1 ))
            done
            echo "" >> run_errors_not_found.tmp.txt
	fi
    done
	    
    # print results
    echo "System Errors:"
    cat system_errors_found.tmp.txt | sort -u
    cat system_errors_not_found.tmp.txt | sort -u
    rm system_errors_found.tmp.txt
    rm system_errors_not_found.tmp.txt

    echo "Test Run Errors:"
    cat run_errors_found.tmp.txt | sort -u
    cat run_errors_not_found.tmp.txt | sort -u
    rm run_errors_found.tmp.txt
    rm run_errors_not_found.tmp.txt
    
    # ignore situation when cluster_reboot generates run errors
    #echo "subsetof with union_size $union_size"
    if [ $union_size -eq 3 ]; then 
        echo ""
    	echo "verify run errors in cluster v1-v2 test"
	if [ "${testrun_error_unions[3]}" != "" ]; then
            echo "testrun_error_unions is not empty:"
     	    echo ${testrun_error_unions[3]}
	    ret=2
	fi
    fi

    echo "subsetof returns $ret" 
    echo ""

    return $ret
}

