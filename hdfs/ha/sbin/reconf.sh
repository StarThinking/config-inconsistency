#!/bin/bash

if [ -z "$TEST_HOME" ]; then 
    echo "TEST_HOME not set."
    exit 1
fi

# if a script wants to be executed by itself, 
# it needs to load global variables
. $TEST_HOME/sbin/global_var.sh

type=$1
new_conf=$2

function switch_active { # return 0 if success, 1 if error
    # find avtive and standby namenode nodes
    active0=$($HADOOP_HOME/bin/hdfs haadmin -getAllServiceState | grep active | cut -d':' -f1)
    standby0=$($HADOOP_HOME/bin/hdfs haadmin -getAllServiceState | grep standby | cut -d':' -f1)
    echo "active0 node before switch: $active0"
    echo "standby0 node before switch: $standby0"
    
    # stop active0 
    ssh $active0 "$HADOOP_HOME/bin/hdfs --daemon stop namenode"
   
    # wait until standby becomes active
    max_try=15
    tries=0
    for (( ; ; ))
    do
        current_active=$($HADOOP_HOME/bin/hdfs haadmin -getAllServiceState | grep active | cut -d':' -f1)
	if [ "$current_active" = "$standby0" ]; then
	    echo "$standby0 has turned ACTIVE from STANDBY" 
	    break;
        else
	    sleep 2
	    tries=$(( tries + 1 ))
	    if [ $tries -gt $max_try ]; then
		echo "TEST_ERROR: after $tries tries turn ACTIVE failed"
		return 1; # report error
	    fi
	fi
    done

    # change configuration of active0 to file xxx
    scp $new_conf $active0:$HADOOP_HOME/etc/hadoop
    echo "change hdfs-site.xml configuration as $new_conf"
    
    # reboot active0 which should become standby namenode after reboot
    ssh $active0 "$HADOOP_HOME/bin/hdfs --daemon start namenode"

    # wait until active0 has been rebooted as standby
    max_try=15
    tries=0
    for (( ; ; ))
    do
        current_standby=$($HADOOP_HOME/bin/hdfs haadmin -getAllServiceState | grep standby | cut -d':' -f1)
	if [ "$current_standby" = "$active0" ]; then
            echo "$active0 has turned STANDBY from ACTIVE" 
            break;
        else
            sleep 2
            tries=$(( tries + 1 ))
            if [ $tries -gt $max_try ]; then
		echo "TEST_ERROR: after $tries tries turn STANDBY failed"
                return 1; # report error
            fi
        fi
    done    

    # confirm active and standby namenodes are switched
    active1=$($HADOOP_HOME/bin/hdfs haadmin -getAllServiceState | grep active | cut -d':' -f1)
    standby1=$($HADOOP_HOME/bin/hdfs haadmin -getAllServiceState | grep standby | cut -d':' -f1)
    echo "active1 node after switch: $active1"
    echo "standby1 node after switch: $standby1"
    
    return 0
}

function switch_datanode {
    # stop one datanode
    ssh node-"$reconf_datanode"-link-0 "$HADOOP_HOME/bin/hdfs --daemon stop datanode"
       
    # change configuration to file xxx
    scp $new_conf node-"$reconf_datanode"-link-0:$HADOOP_HOME/etc/hadoop
    echo "change hdfs-site.xml configuration as $new_conf"
    
    # reboot datanode
    ssh node-"$reconf_datanode"-link-0 "$HADOOP_HOME/bin/hdfs --daemon start datanode"
    
    return 0
}

function switch_journalnode {
    # stop one journalnode
    ssh node-"$reconf_journalnode"-link-0 "$HADOOP_HOME/bin/hdfs --daemon stop journalnode"
       
    # change configuration to file xxx
    scp $new_conf node-"$reconf_journalnode"-link-0:$HADOOP_HOME/etc/hadoop
    echo "change hdfs-site.xml configuration as $new_conf"
    
    # reboot journalnode
    ssh node-"$reconf_journalnode"-link-0 "$HADOOP_HOME/bin/hdfs --daemon start journalnode"
    
    return 0
}

if [ "$#" -eq 2 ]; then
    if [ $type = "namenode" ]; then
        if ! switch_active; then # failed 
    	    exit 1
        fi
        sleep 10
        switch_active
        exit $?
    elif [ $type = "datanode" ]; then
        switch_datanode 
        exit $?
    elif [ $type = "journalnode" ]; then
        switch_journalnode
        exit $?
    fi
fi
    
echo "e.g., ./reconf.sh [namenode|datanode|journalnode] [config_file]"
exit 1
