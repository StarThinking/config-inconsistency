#!/bin/bash

#./binary_search.sh [name] [reconf_type] [round] [waittime] [time_senestive] [read_times] [benchmark_threads]

line_num=$(wc -l name.txt | cut -d' ' -f1)

for i in $(seq 1 $line_num)
do
    echo -n "./sbin/binary_search.sh " >> tmp.sh 
    echo -n " max " >> tmp.sh
    echo -n `sed -n "$i p" name.txt` >> tmp.sh
    echo -n " " >> tmp.sh
    echo -n `sed -n "$i p" value.txt` >> tmp.sh
    echo -n " " >> tmp.sh
    echo -n " namenode" >> tmp.sh
    echo -n " 1" >> tmp.sh
    echo -n " 300" >> tmp.sh
    echo " 1" >> tmp.sh
    
    echo ""  >> tmp.sh
done

