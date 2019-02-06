#!/bin/bash

id=$1
running=true

trap 'echo "signal TERM catched and let quit gracefully"; running=false' TERM

while [ $running == true ]
do
    $HADOOP_HOME/bin/hdfs dfs -put "$large_file_dir"/myfile"$id" /myfile"$id"
    $HADOOP_HOME/bin/hdfs dfs -ls /
    echo "file $id has been put into HDFS"

    for i in $(seq 1 $read_times)
    do
        $HADOOP_HOME/bin/hdfs dfs -get /myfile"$id" $large_file_dir_tmp/myfile"$id"
        echo "file $id has been read from HDFS for $i time"
	local res=$(diff $large_file_dir_tmp/myfile"$id" $large_file_dir/myfile"$id")
	if [ "$res" != "" ]; then
		echo "Error: diff failed!"
	else	
		echo "diff succeed!"
	fi
        rm $large_file_dir_tmp/myfile"$id"
        sleep 10
    done

    $HADOOP_HOME/bin/hdfs dfs -rm /myfile"$id"
    echo "file $id has been removed from HDFS"

    sleep 10
done
