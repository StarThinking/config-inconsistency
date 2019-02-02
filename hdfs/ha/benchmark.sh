#!/bin/bash

id=$1
running=true
# on sdb1 device
large_file_dir=/root/my_large_file

trap 'echo "signal TERM catched and let quit gracefully"; running=false' TERM

while [ $running == true ]
do
    $HADOOP_HOME/bin/hdfs dfs -put "$large_file_dir"/myfile"$id" /myfile"$id"
    $HADOOP_HOME/bin/hdfs dfs -ls /
    echo "file $file has been put into HDFS"

    $HADOOP_HOME/bin/hdfs dfs -get /myfile"$id" ./tmp."$id"
    echo "file $file has been got from HDFS"
    rm ./tmp."$i"
    
    $HADOOP_HOME/bin/hdfs dfs -rm /myfile"$id"
    echo "file $file has been removed from HDFS"
   
    sleep 10
done

echo 'benchmark exits'
