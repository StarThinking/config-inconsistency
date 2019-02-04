#!/bin/bash

id=$1
running=true
# on sdb1 device
large_file_dir=/root/my_large_file

trap 'echo "signal TERM catched and let quit gracefully"; running=false' TERM

while [ $running == true ]
do
    echo "file has been put into HDFS"
   
    sleep 10
done

echo 'benchmark exits'
