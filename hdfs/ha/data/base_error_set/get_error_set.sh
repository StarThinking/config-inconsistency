#!/bin/bash
set -u

if [ -z "$TEST_HOME" ]; then
    echo "TEST_HOME not set."
    exit 3
fi

. $TEST_HOME/sbin/global_var.sh
. $TEST_HOME/sbin/util/subsetof.sh

samples=()
#output_file=merged.txt
res_file=merged.txt.tmp
occ_file=occ.txt.tmp
shift

while [ $# -ne 0 ]
do
    samples+=("$1")
    shift
done

#echo > $output_file

errors=('command' 'fatal' 'system')

for i in $(seq 0 $(( ${#errors[@]} - 1 )))
do 
    echo > $res_file
    echo > $occ_file
    echo "${errors[$i]}"
    
    for j in ${samples[@]}
    do
        echo ""$j":"
        generate_"${errors[$i]}"_errors $j | tee -a $res_file
        echo ""
    done
    
    echo "merged result for ${errors[$i]}:"
    error_set=$(sort -u $res_file)
    #echo "error set: ${error_set[@]}"
    echo "occurance of each error:"
    for e in ${error_set[@]}
    do
        occ=$(cat $res_file | grep $e | wc -l)
	echo "$occ $e" >> $occ_file
    done
    cat $occ_file | sort -u -r

    rm $occ_file
    rm $res_file
done

#sort -u $res_file >> $output_file


