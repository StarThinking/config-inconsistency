#!/bin/bash

if [ $# -ne 2 ]; then
    echo "wrong arguments"
    exit 1
fi

file=$1
component=$2

size=$(wc -l $file | awk -F " " '{print $1}')
echo size=$size
parameter_array=($(cat $file | awk -F " " '{print $1}'))
default_value_array=($(cat $file | awk -F " " '{print $2}'))

index=0
while [ $index -lt $size ]
do
    touch min_max_tmp.txt
    default=${default_value_array[$index]}
    default_mul_2=$(( default * 2 ))
    default_mul_10=$(( default * 10 ))
    default_mul_100=$(( default * 100 ))
    default_div_2=$(( default / 2 ))
    for v in $default_mul_2 $default_mul_10 $default_mul_100 $default_div_2 1 0 
    do
	if [ $default -ne $v ]; then
            echo $component ${parameter_array[$index]} $default $v >> min_max_tmp.txt
            echo $component ${parameter_array[$index]} $v $default >> min_max_tmp.txt
	fi
    done
    
    cat min_max_tmp.txt | sort -u
    rm min_max_tmp.txt

    index=$(( index + 1 ))
done

#cat $file | awk -F " " -v c="$component" '{print c " " $1 " " $2 " "  $2 + 1}'
#cat $file | awk -F " " -v c="$component" '{print c " " $1 " " $2 " "  $2 + 2}'
