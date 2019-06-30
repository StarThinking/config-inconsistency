#!/bin/bash

id=$1
running=true

trap 'echo "sub_benchmark $i signal TERM catched and let quit gracefully"; running=false' TERM

function check_file {
        if [ ! -f $large_file_dir_tmp/myfile"$id" ]; then
	    echo "TEST_ERROR: get failed!"
            return 1
	fi        
	
	local res=$(diff $large_file_dir_tmp/myfile"$id" $large_file_dir/myfile"$id")
	
        if [ "$res" != "" ]; then
	    echo "TEST_ERROR: diff failed!"
            return 1
        fi

        return 0
}

count=0
while [ $running == true ]
do
    $HADOOP_HOME/bin/hdfs dfs -get /myfile"$id" $large_file_dir_tmp/myfile"$id"
    if [ $? -ne 0 ]; then
        echo "TEST_ERROR: get hdfs file faield"
        exit 1
    else
        if ! check_file; then # fail
            exit 1
        else
            echo "get myfile"$id" for $count times success"
            sleep 2
        fi
    fi
    
    if [ $running != true ]; then
        break
    fi
    
    $HADOOP_HOME/bin/hdfs dfs -rm /myfile"$id"
    if [ $? -ne 0 ]; then
        echo "TEST_ERROR: remove hdfs file faield"
        exit 1
    else
        echo "remove myfile"$id" for $count times success"
        sleep 2
    fi
    
    if [ $running != true ]; then
        break
    fi
 
    $HADOOP_HOME/bin/hdfs dfs -put $large_file_dir_tmp/myfile"$id" /myfile"$id"
    if [ $? -ne 0 ]; then
        echo "TEST_ERROR: put hdfs file faield"
        exit 1
    else
        rm $large_file_dir_tmp/myfile"$id"
        echo "put myfile"$id" for $count times success"
        sleep 2
    fi
    
    if [ $running != true ]; then
        break
    fi

    count=$(( $count + 1 ))
    echo ""
done
