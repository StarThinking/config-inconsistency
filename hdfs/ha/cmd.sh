#!/bin/bash

command=$1
type=$2
property=$3
value=$4
node_update=4
namenodes=(0 1)
datanodes=(2 3 4)
jnodes=(2 3 4)
znodes=(0 1 5)
allnodes=(0 1 2 3 4 5)
filenum=5
TEST_HOME=/root/config-inconsistency/hdfs/ha

source ~/.bashrc

function start {
    # copy default configuration to all nodes
    for i in ${allnodes[@]}
    do
        scp $TEST_HOME/etc/* node-"$i"-link-0:$HADOOP_HOME/etc/hadoop
    done
    
    ### START MANUAL FAILOVER ###
    # start journal nodes
    for i in ${jnodes[@]}
    do
        ssh node-$i-link-0 "mkdir /root/journal"
        ssh node-$i-link-0 "$HADOOP_HOME/bin/hdfs --daemon start journalnode"
    done   
    sleep 5

    # format hdfs fs
    $HADOOP_HOME/bin/hdfs namenode -format
    $HADOOP_HOME/bin/hdfs --daemon start namenode
    sleep 5
    
    # copy meta-data to the other namenode (nn2)
    scp -r /tmp/hadoop-root node-1-link-0:/tmp
    ssh node-1-link-0 "echo 'Y' | $HADOOP_HOME/bin/hdfs namenode -bootstrapStandby"
 
    ### SHUTDOWN MANUAL FAILOVER ###
    $HADOOP_HOME/bin/hdfs --daemon stop namenode
    for i in ${jnodes[@]}
    do
        ssh node-$i-link-0 "$HADOOP_HOME/bin/hdfs --daemon stop journalnode"
    done

    ### START AUTOMATIC FAILOVER ###
    # start zookeeper
    echo "start zookeeper"
    for i in ${znodes[@]}
    do
        scp $TEST_HOME/etc/zoo.cfg node-"$i"-link-0:$ZOOKEEPER_HOME/conf
        ssh node-"$i"-link-0 "mkdir /root/zookeeper-data"
    done

    ssh node-0-link-0 "echo 1 > /root/zookeeper-data/myid"
    ssh node-1-link-0 "echo 2 > /root/zookeeper-data/myid"
    ssh node-5-link-0 "echo 3 > /root/zookeeper-data/myid"

    for i in ${znodes[@]}
    do
        ssh node-"$i"-link-0 "$ZOOKEEPER_HOME/bin/zkServer.sh start" &
    done
    
    # prepare datanode dir
    for i in ${datanodes[@]}
    do
        ssh node-"$i"-link-0  "mkdir /root/data"
    done
    
    # init zookeeper
    $HADOOP_HOME/bin/hdfs zkfc -formatZK

    
    $HADOOP_HOME/sbin/start-dfs.sh
    $HADOOP_HOME/bin/hdfs haadmin -getAllServiceState
}

#function test {
#}

function stop {
    # stop and clear up everything
    echo "stop hdfs"
    $HADOOP_HOME/sbin/stop-dfs.sh

    for i in ${namenodes[@]}
    do
        ssh node-"$i"-link-0 "rm -rf /tmp/hadoop-root; rm -rf $HADOOP_HOME/logs/*"
    done

    for i in ${datanodes[@]}
    do
        ssh node-"$i"-link-0 "rm -rf /root/data; rm -rf /root/journal; rm $HADOOP_HOME/logs/*"
    done
    
    # stop and clear up zookeeper
    echo "stop zookeeper"
    for i in ${znodes[@]}
    do
        ssh node-"$i"-link-0 "$ZOOKEEPER_HOME/bin/zkServer.sh stop; rm -rf /root/zookeeper-data"
    done
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
