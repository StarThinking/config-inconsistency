#!/bin/bash
set -u

if [ -z "$TEST_HOME" ]; then
    echo "TEST_HOME not set."
    exit 3
fi

. $TEST_HOME/sbin/global_var.sh
. $TEST_HOME/sbin/util/system_error_subsetof.sh

samples=()
#output_file=merged.txt
res_file_tmp=merged.txt.tmp
res_file=merged.txt
occ_file=occ.txt
shift

while [ $# -ne 0 ]
do
    samples+=("$1")
    shift
done

#echo > $output_file

errors=('command' 'reconfig' 'fatal' 'system')

for i in $(seq 0 $(( ${#errors[@]} - 1 )))
do 
    echo > $res_file
    echo > $res_file_tmp
    echo > $occ_file
    echo "${errors[$i]}":
    
    for j in ${samples[@]}
    do
        #echo ""$j":"
        #generate_"${errors[$i]}"_errors $j | tee -a $res_file
        generate_"${errors[$i]}"_errors $j >> $res_file_tmp
        #echo ""
    done
    awk NF $res_file_tmp > $res_file
    
    if [ "$(cat $res_file)" != '' ]; then 
        #echo "merged ioccurance result for ${errors[$i]}:"
        error_set=$(sort -u $res_file)
        for e in ${error_set[@]}
        do
            occ=$(cat $res_file | grep $e | wc -l)
	    echo "$e $occ" >> $occ_file
        done
        cat $occ_file | sort -u | sort -rn -k 2   
    fi

    echo ""
    rm $occ_file
    rm $res_file
    rm $res_file_tmp
done

#sort -u $res_file >> $output_file


