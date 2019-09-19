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
