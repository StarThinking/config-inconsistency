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
tmp_file=merged.txt.tmp
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
    echo > $tmp_file
    echo "${errors[$i]}"
    
    for j in ${samples[@]}
    do
        echo ""$j":"
        generate_"${errors[$i]}"_errors $j | tee -a $tmp_file
        echo ""
    done
    
    echo "merged result for ${errors[$i]}:"
    sort -u $tmp_file
    rm $tmp_file
done

#sort -u $tmp_file >> $output_file


