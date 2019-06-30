#!/bin/bash

line_num=$(wc -l name.txt | cut -d' ' -f1)

for i in $(seq 1 $line_num)
do
    echo -n '$base/run_test.sh ' >> tmp.sh 
    echo -n `sed -n "$i p" name.txt` >> tmp.sh
    echo -n " " >> tmp.sh
    echo -n "true" >> tmp.sh
    echo -n " journalnode" >> tmp.sh
    echo -n " default" >> tmp.sh
    echo -n " 1" >> tmp.sh
    echo " 120" >> tmp.sh
    echo ""  >> tmp.sh
    
    echo -n '$base/run_test.sh ' >> tmp.sh 
    echo -n `sed -n "$i p" name.txt` >> tmp.sh
    echo -n " " >> tmp.sh
    echo -n "false" >> tmp.sh
    echo -n " journalnode" >> tmp.sh
    echo -n " default" >> tmp.sh
    echo -n " 1" >> tmp.sh
    echo " 120" >> tmp.sh
    echo ""  >> tmp.sh
    
done
