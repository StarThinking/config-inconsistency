#!/bin/bash
set -u

if [ $# -ne 1 ]; then
    echo "wrong args"
    exit 1
fi

file=$1
errors=$(cat $file | awk -F " " '{print $1}' | awk NF | sort -u)
res_file=occs.txt

for error in ${errors[@]}
do
    sum=0
    occs=($(cat $file | grep $error | awk -F " " '{print $2}'))
    #echo "occs:" ${occs[@]}
    for o in ${occs[@]}
    do
	sum=$(( sum + o ))
    done
    echo $error  $sum >> $res_file
    #echo ""
done

cat $res_file | sort -k 2 -rn
rm $res_file
