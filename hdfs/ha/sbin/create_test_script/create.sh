#!/bin/bash

line_num=$(wc -l name.txt | cut -d' ' -f1)

for i in $(seq 1 $line_num)
do
    echo -n "./sbin/run_test.sh " >> tmp.sh 
    echo -n `sed -n "$i p" name.txt` >> tmp.sh
    echo -n " " >> tmp.sh
    echo -n `sed -n "$i p" value1.txt` >> tmp.sh
    echo -n " datanode" >> tmp.sh
    echo -n " default" >> tmp.sh
    echo -n " 1" >> tmp.sh
    echo " 300" >> tmp.sh
    
    echo ""  >> tmp.sh
done
