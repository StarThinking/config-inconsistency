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

echo > $tmp_file
#echo > $output_file

for i in ${samples[@]}
do
    echo ""$i":"
    generate_fatal_errors $i | tee -a $tmp_file
    echo ""
done

#sort -u $tmp_file >> $output_file
echo "merged result:"
sort -u $tmp_file
rm $tmp_file


