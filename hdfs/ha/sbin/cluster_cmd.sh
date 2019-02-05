#!/bin/bash

if [ -z "$TEST_HOME" ]; then 
    echo "TEST_HOME not set."
    exit
fi

# if a script wants to be executed by itself, 
# it needs to load global variables
. $TEST_HOME/sbin/global_var.sh

if [ "$#" -lt 1 ]
then
    echo "e.g., ./cluster_cmd.sh [start|stop|collectlog]"
    exit
fi

command=$1
shift 1

function start {
    # copy default configuration to all nodes
    for i in ${allnodes[@]}
    do
        scp $TEST_HOME/etc/* node-"$i"-link-0:$HADOOP_HOME/etc/hadoop
        # override sbin
        scp $TEST_HOME/sbin/* node-"$i"-link-0:$TEST_HOME/sbin
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
        ssh node-"$i"-link-0  "rm -rf $hadoop_data_dir/*"
    done

    # init zookeeper
    $HADOOP_HOME/bin/hdfs zkfc -formatZK

    
    $HADOOP_HOME/sbin/start-dfs.sh
    $HADOOP_HOME/bin/hdfs haadmin -getAllServiceState
}

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
        ssh node-"$i"-link-0 "rm -rf $hadoop_data_dir/*; rm -rf /root/journal; rm $HADOOP_HOME/logs/*"
    done
    
    # stop and clear up zookeeper
    echo "stop zookeeper"
    for i in ${znodes[@]}
    do
        ssh node-"$i"-link-0 "$ZOOKEEPER_HOME/bin/zkServer.sh stop; rm -rf /root/zookeeper-data"
    done
}

function collectlog {
    local test=$1
    echo "collect logs for test $test"
    mkdir $test/all_logs
    mkdir $test/all_logs/namenodes
    mkdir $test/all_logs/datanodes
    mkdir $test/all_logs/jnodes
    mkdir $test/all_logs/clients
    
    for i in ${namenodes[@]}
    do
        scp node-"$i"-link-0:$HADOOP_HOME/logs/hadoop-root-namenode* $test/all_logs/namenodes
    done
    
    for i in ${datanodes[@]}
    do
        scp node-"$i"-link-0:$HADOOP_HOME/logs/hadoop-root-datanode* $test/all_logs/datanodes
    done
    
    for i in ${jnodes[@]}
    do
        scp node-"$i"-link-0:$HADOOP_HOME/logs/hadoop-root-journalnode* $test/all_logs/jnodes
    done
   
    scp node-"$clientnode"-link-0:/tmp/client*.log $test/all_logs/clients
    ssh node-"$clientnode"-link-0 "rm /tmp/client*.log"
}

if [ $command = "start" ]; then
    start
elif [ $command = "stop" ]; then
    stop
elif [ $command = "collectlog" ]; then
    if [ "$#" -ne 1 ]; then
        echo "wrong command, e.g., ./cluster_cmd.sh collectlog TEST_DIR"
    else
        collectlog $1
    fi
else
    echo "wrong command, e.g., ./cluster_cmd.sh [start|stop|collectlog]"
fi
