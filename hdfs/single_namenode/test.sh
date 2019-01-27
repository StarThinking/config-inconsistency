#!/bin/bash

command=$1
type=$2
property=$3
value=$4
node_update=4
namenodes=(0)
datanodes=(2 3 4)
nodes=(${namenodes[@]} ${datanodes[@]})
filenum=5
TEST_HOME=/root/config-inconsistency/hdfs/single_namenode

source ~/.bashrc

function start {
    rm -rf $TEST_HOME/tmp
    mkdir $TEST_HOME/tmp
    
    # create hdfs workers file according to datanodes parameter
    > $TEST_HOME/etc/workers
    for i in ${datanodes[@]}
    do
        echo node-$i-link-0 >> $TEST_HOME/etc/workers
    done
    
    # copy default configuration to namenodes
    for i in ${namenodes[@]}
    do
        scp $TEST_HOME/etc/* node-"$i"-link-0:$HADOOP_HOME/etc/hadoop
    done
    
    # copy default configuration to datanodes
    for i in ${datanodes[@]}
    do
        scp $TEST_HOME/etc/* node-"$i"-link-0:$HADOOP_HOME/etc/hadoop
        ssh node-"$i"-link-0  "mkdir /root/data"
    done
    
    # start with default configuration
    $HADOOP_HOME/bin/hdfs namenode -format
    $HADOOP_HOME/sbin/start-dfs.sh
}

function test {
    # input some data
    # ....
    $HADOOP_HOME/bin/hdfs dfs -mkdir /test
    $HADOOP_HOME/bin/hdfs dfs -mkdir /test/0/
    
    for j in $(seq 1 $filenum)
    do
        dd if=/dev/urandom of=$TEST_HOME/tmp/file$j bs=16M count=16 
    done
    
    for j in $(seq 1 $filenum)
    do
        $HADOOP_HOME/bin/hdfs dfs -copyFromLocal $TEST_HOME/tmp/file$j /test/0 &
    done
    
    echo "copyFromLocal done"
    sleep 30
    
    # stop and update one node configuration
    ssh node-"$node_update"-link-0 "$HADOOP_HOME/bin/hdfs --daemon stop datanode"
    scp $TEST_HOME/$type/$property/$value/hdfs-site.xml node-"$node_update"-link-0:$HADOOP_HOME/etc/hadoop/hdfs-site.xml
    ssh node-"$node_update"-link-0 "$HADOOP_HOME/bin/hdfs --daemon start datanode"
    
    $HADOOP_HOME/bin/hdfs dfs -mkdir /test/1/
    
    for j in $(seq 1 $filenum)
    do
        $HADOOP_HOME/bin/hdfs dfs -cp /test/0/file$j /test/1/file$j &
    done
    
    sleep 30
    
    for j in $(seq 1 $filenum)
    do
        $HADOOP_HOME/bin/hdfs dfs -copyToLocal /test/1/file$j $TEST_HOME/tmp/file"$j".copied &
    done
    
    echo "copyToLocal done"
    sleep 30
    
    for j in $(seq 1 $filenum)
    do
        diff $TEST_HOME/tmp/file"$j".copied $TEST_HOME/tmp/file$j
        cat $TEST_HOME/tmp/file"$j".copied >> $TEST_HOME/tmp/merged
    done
    
    $HADOOP_HOME/bin/hdfs dfs -put $TEST_HOME/tmp/merged /test/
    echo "put merged file done"
    sleep 30
    
    # save logs
    for i in ${nodes[@]}
    do
        mkdir $TEST_HOME/$type/$property/$value/node-"$i"-link-0
        scp -r node-"$i"-link-0:$HADOOP_HOME/logs $type/$property/$value/node-"$i"-link-0
    done
}

function stop {
    # stop and clear up everything
    echo "stop and clear up everything"
    $HADOOP_HOME/bin/hdfs dfs -rm -r /test/*
    $HADOOP_HOME/bin/hdfs dfs -rm -r /test
    $HADOOP_HOME/sbin/stop-dfs.sh

    for i in ${namenodes[@]}
    do
        ssh node-"$i"-link-0 "rm -rf /tmp/hadoop-root; rm -rf $HADOOP_HOME/logs/*"
    done

    for i in ${datanodes[@]}
    do
        ssh node-"$i"-link-0 "rm -rf /root/data; rm $HADOOP_HOME/logs/*"
    done

    rm -rf $TEST_HOME/tmp
}

if [ "$#" -ne 1 ]
then
    echo "e.g., ./test.sh [start|stop|test]"
    exit
fi

if [ $command = "start" ]; then
    start
elif [ $command = "stop" ]; then
    stop
elif [ $command = "test" ]; then
    start; test; stop
else
    echo "wrong command, e.g., [start|stop|test]"
fi
