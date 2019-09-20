#!/bin/bash

function validate_argument {
    argument="$1"
    shift
    valid_values=("$@") # reconstruct array
    valid=1
    for v in ${valid_values[@]}
    do
	if [ "$argument" == "$v" ]; then
	    valid=0
	fi 
    done
    return $valid
}

function get_namenode_ip {
    if [ $# -ne 1 ]; then
        echo "${ERRORS[$COMMAND]}[wrong_arguments]: get_namenode_ip"
	return 1
    fi
    max_try=5
    i=0
    ip=""
    avtive_standby=$1
    
    while [ $i -lt $max_try ]; do
        i=$(( i + 1 )) 
	raw=$($HADOOP_HOME/bin/hdfs haadmin -getAllServiceState | grep $avtive_standby)
	if [ $? -ne 0 ]; then
	    sleep 5
	    continue
	else
            ip=$(echo $raw | cut -d':' -f1) 
	    break
	fi 
    done
    
    if [ $i -ge $max_try ]; then
	echo "${ERRORS[$RECONFIG]}[get_namenode_ip_failure]: getAllServiceState for $avtive_standby failed after $max_try tries"
	return 1
    fi
    # return this value to caller
    echo "$ip"
    return 0
}
