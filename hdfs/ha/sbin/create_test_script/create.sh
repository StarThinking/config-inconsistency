#!/bin/bash

line_num=$(wc -l name.txt | cut -d' ' -f1)

for i in $(seq 1 $line_num)
do
    echo -n "./sbin/run_test.sh " >> tmp.sh 
    echo -n `sed -n "$i p" name.txt` >> tmp.sh
    echo -n " " >> tmp.sh
    echo -n `sed -n "$i p" value1.txt` >> tmp.sh
    echo  " datanode" >> tmp.sh
    
    echo "sleep 30" >> tmp.sh
    
    echo -n "./sbin/run_test.sh " >> tmp.sh 
    echo -n `sed -n "$i p" name.txt` >> tmp.sh
    echo -n " " >> tmp.sh
    echo -n `sed -n "$i p" value2.txt` >> tmp.sh
    echo " datanode" >> tmp.sh
    
    echo "sleep 30" >> tmp.sh
    echo ""  >> tmp.sh
done
