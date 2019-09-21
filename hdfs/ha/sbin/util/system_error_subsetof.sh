#!/bin/bash

#for split="#"
. $TEST_HOME/sbin/global_var.sh
. $TEST_HOME/sbin/util/error_helper.sh

errorset_names=('component' 'test_22' 'test_11' 'test_12')

function system_error_subsetof {
    if [ $# -lt 1 ]; then
        echo "${ERRORS[$COMMAND]}[wrong_arguments]"
	return 1
    fi
    test_12=$1
    shift 1

    ret=0

    # generate system errors for test_12
    test_12_system_errors=$(generate_system_errors $test_12)
    
    set_size=0
    component=$(echo $test_12 | awk -F "$split" 'NR==1 {print $1}')
    root_base_dir=$TEST_HOME/data/reconfig_general_error/system_error
    component_errors=$root_base_dir/"$component".txt
    if [ ! -f $component_errors ]; then
	echo "${ERRORS[$COMMAND]}[no_component_errors_file]"
	return 1
    fi
    system_error_sets[0]=$(cat $component_errors)

    # generate system error sets for set 1 2 3
    while [ $# -ge 1 ]; do
	set_size=$(( set_size + 1 ))
        dir=$1
	system_error_sets[$set_size]=$(generate_system_errors $dir)
        shift 1
    done	

    touch system_errors_found.tmp.txt
    touch system_errors_not_found.tmp.txt
    
    # search for system errors
    for err in ${test_12_system_errors[@]}; do
	found=-1
	set_index=0
	while [ $set_size -ge $set_index ]; do
	    for e in ${system_error_sets[$set_index]}; do
	        if [ "$err" == "$e" ]; then
	    	found=$set_index
                    echo "[$found] $err is found in ${errorset_names[$found]} " >> system_errors_found.tmp.txt
                    break
	        fi  
	    done

            if [ $found -ge 0 ]; then
                break
            else # keep search in the next set 
	        set_index=$(( set_index + 1 ))
            fi
	done

	if [ $found -lt 0 ]; then
	    ret=1
	    echo -n "[$found] $err CANNOT be found in error set ${errorset_names[0]}" >> system_errors_not_found.tmp.txt
            set_index=1
            while [ $set_size -ge $set_index ]; do
                echo -n ", ${errorset_names[$set_index]} " >> system_errors_not_found.tmp.txt
                set_index=$(( set_index + 1 ))
            done
            echo "" >> system_errors_not_found.tmp.txt
	fi
    done
    
    # print results
    echo "System Errors:"
    cat system_errors_found.tmp.txt | sort -u
    cat system_errors_not_found.tmp.txt | sort -u
    rm system_errors_found.tmp.txt
    rm system_errors_not_found.tmp.txt

    echo "system_error_subsetof returns $ret" 

    return $ret
}
