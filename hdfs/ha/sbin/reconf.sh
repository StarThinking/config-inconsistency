#!/bin/bash

if [ -z "$TEST_HOME" ]; then 
    echo "TEST_HOME not set."
    exit
fi

# if a script wants to be executed by itself, 
# it needs to load global variables
 . $TEST_HOME/sbin/global_var.sh

if [ "$#" -ne 2 ]
then
    echo "e.g., ./reconf.sh [namenode|datanode] [config_file]"
    exit
fi

type=$1
new_conf=$2

function switch_active { 
    # find avtive and standby namenode nodes
    active=$($HADOOP_HOME/bin/hdfs haadmin -getAllServiceState | grep active | cut -d':' -f1)
    standby=$($HADOOP_HOME/bin/hdfs haadmin -getAllServiceState | grep standby | cut -d':' -f1)
    echo "active node before switch: $active"
    echo "standby node before switch: $standby"
    
    # stop active namenode
    ssh $active "$HADOOP_HOME/bin/hdfs --daemon stop namenode"
    sleep 15
    
    # change configuration to file xxx
    scp $new_conf $active:$HADOOP_HOME/etc/hadoop
    echo "change hdfs-site.xml configuration as $new_conf"
    
    
    # reboot namenode which should be become standby namenode
    ssh $active "$HADOOP_HOME/bin/hdfs --daemon start namenode"
    sleep 5
    old_standby=$standby
    standby=$active
    
    # confirm active and standby namenodes are switched
    active=$($HADOOP_HOME/bin/hdfs haadmin -getAllServiceState | grep active | cut -d':' -f1)
    if [ "$active" != "$old_standby" ]
    then
        echo "Error: standby namenode failed to turn active."
        exit
    fi
    
    echo "active node after switch: $active"
    echo "standby node after switch: $standby"
}

function switch_datanode {
    # stop one datanode
    ssh node-"$reconf_datanode"-link-0 "$HADOOP_HOME/bin/hdfs --daemon stop datanode"
       
    # change configuration to file xxx
    scp $new_conf node-"$reconf_datanode"-link-0:$HADOOP_HOME/etc/hadoop
    echo "change hdfs-site.xml configuration as $new_conf"
    
    # reboot datanode
    ssh node-"$reconf_datanode"-link-0 "$HADOOP_HOME/bin/hdfs --daemon start datanode"
}

if [ $type = "namenode" ]; then
    switch_active; sleep 10; switch_active
elif [ $type = "datanode" ]; then
    switch_datanode 
else
    echo "e.g., ./reconf.sh [namenode|datanode] [config_file]"
fi
