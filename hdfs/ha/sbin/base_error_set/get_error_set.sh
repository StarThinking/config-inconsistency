#!/bin/bash

samples=()
#output_file=merged.txt
tmp_file=merged.txt.tmp
stage=$1
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
    grep -r "WARN\|ERROR\|FATAL" $i/$stage | awk -F " " '{ if ($3 == "WARN" || $3 == "ERROR" || $3 == "FATAL") print $5}' | sort -u | tee -a $tmp_file
    echo ""
done

#sort -u $tmp_file >> $output_file
echo "merged result:"
sort -u $tmp_file
rm $tmp_file


