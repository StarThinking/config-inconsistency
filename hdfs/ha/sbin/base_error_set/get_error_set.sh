#!/bin/bash

samples=()
output_file=merged.txt
tmp_file=merged.txt.tmp

while [ $# -ne 0 ]
  do
    samples+=("$1")
    shift
done

echo > $tmp_file
echo > $output_file

for i in ${samples[@]}
do    
    grep -r "WARN\|ERROR\|FATAL" $i | awk -F " " '{ if ($3 == "WARN" || $3 == "ERROR" || $3 == "FATAL") print $5}' | sort -u >> $tmp_file
done

sort -u $tmp_file >> $output_file
rm $tmp_file


