#!/bin/bash
set -u

id=$1
running=true

trap 'echo "sub_benchmark $id is handling signal TERM"; clean_up; exit 0' TERM

function clean_up {
    echo "clean up for sub_benchmark $id"
    echo "let's try to exit gracefully"

    if [ -f $large_file_dir_tmp/myfile"$id" ]; then
        rm $large_file_dir_tmp/myfile"$id"
    fi
   
    file_exist_ret=$($HADOOP_HOME/bin/hdfs dfs -test -f /myfile"$id")
    if [ $file_exist_ret -eq 0 ]; then
        $HADOOP_HOME/bin/hdfs dfs -rm /myfile"$id"
        if [ $? -ne 0 ]; then
            echo "${ERRORS[$FATAL]}[sub_benchmark:remove_failure]: remove hdfs file failed"
        fi
    fi

    echo "clean up finished"
  
    return 0
}


function check_file {
    if [ ! -f $large_file_dir_tmp/myfile"$id" ]; then
        echo "${ERRORS[$FATAL]}[sub_benchmark:no_download_file]: file not exist!"
        return 1
    fi        
    
    local res=$(diff $large_file_dir_tmp/myfile"$id" $large_file_dir/myfile"$id")
    
    if [ "$res" != "" ]; then
        echo "${ERRORS[$FATAL]}[sub_benchmark:diff_failure]: diff failed!"
        return 1
    fi

    return 0
}

count=0
while [ $running == true ]
do
    $HADOOP_HOME/bin/hdfs dfs -get /myfile"$id" $large_file_dir_tmp/myfile"$id"
    if [ $? -ne 0 ]; then
        echo "${ERRORS[$FATAL]}[sub_benchmark:get_failure]: get hdfs file failed"
        exit 1
    else
        if ! check_file; then # fail
            exit 1
        else
            echo "get myfile"$id" for $count times success"
            sleep 2
        fi
    fi
    
    $HADOOP_HOME/bin/hdfs dfs -rm /myfile"$id"
    if [ $? -ne 0 ]; then
        echo "${ERRORS[$FATAL]}[sub_benchmark:remove_failure]: remove hdfs file failed"
        exit 1
    else
        echo "remove myfile"$id" for $count times success"
        sleep 2
    fi
 
    $HADOOP_HOME/bin/hdfs dfs -put $large_file_dir_tmp/myfile"$id" /myfile"$id"
    if [ $? -ne 0 ]; then
        echo "${ERRORS[$FATAL]}[sub_benchmark:put_failure]: put hdfs file failed"
        exit 1
    else
        rm $large_file_dir_tmp/myfile"$id"
        echo "put myfile"$id" for $count times success"
        sleep 2
    fi

    count=$(( $count + 1 ))
    echo ""
done
