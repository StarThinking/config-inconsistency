#!/bin/bash

id=$1
running=true

trap 'echo "sub_benchmark $i signal TERM catched and let quit gracefully"; running=false' TERM

while [ $running == true ]
do
    sleep 2

    for i in $(seq 1 $read_times)
    do
        $HADOOP_HOME/bin/hdfs dfs -get /myfile"$id" $large_file_dir_tmp/myfile"$id"

        if [ ! -f $large_file_dir_tmp/myfile"$id" ]; then
	    echo "TEST_ERROR: get failed!"
	fi        
        echo "file $id has been read from HDFS for $i time"
	
	local res=$(diff $large_file_dir_tmp/myfile"$id" $large_file_dir/myfile"$id")
	if [ "$res" != "" ]; then
		echo "TEST_ERROR: diff failed!"
	else	
		echo "diff succeed!"
	fi
        rm $large_file_dir_tmp/myfile"$id"
        
	sleep 1
	
	if [ $running != true ]; then
	    break
	fi
    done

    $HADOOP_HOME/bin/hdfs dfs -rm /myfile"$id"
    echo "file $id has been removed from HDFS"
done
