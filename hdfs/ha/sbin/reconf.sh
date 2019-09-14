#!/bin/bash

if [ -z "$TEST_HOME" ]; then 
    echo "TEST_HOME not set."
    exit 1
fi

# if a script wants to be executed by itself, 
# it needs to load global variables
. $TEST_HOME/sbin/global_var.sh

function check_nn_health {
    ret=0

    $HADOOP_HOME/bin/hdfs haadmin -checkHealth nn1
    health_nn1=$?
    $HADOOP_HOME/bin/hdfs haadmin -checkHealth nn2
    health_nn2=$?
    if [ $health_nn1 -eq 0 ] && [ $health_nn2 -eq 0 ]; then
	echo "namenodes are healthy"
    else
        echo "${ERRORS[$FATAL]}[namenode_unhealth]: namenode1 $health_nn1, namenode2 $health_nn2"
	ret=1
    fi
    
    return $ret
}

function online_reconfig_namenode { # return 0 if success, 1 if error
    ret=0

    # find avtive and standby namenode nodes
    active0=$($HADOOP_HOME/bin/hdfs haadmin -getAllServiceState | grep active | cut -d':' -f1)
    standby0=$($HADOOP_HOME/bin/hdfs haadmin -getAllServiceState | grep standby | cut -d':' -f1)
    echo "active0 is $active0"
    echo "standby0 is $standby0"
    
    # online reconfig standby0
    echo "stop standby0 and reconfig standby0"
    ssh $standby0 "$HADOOP_HOME/bin/hdfs --daemon stop namenode"
    scp $new_conf $standby0:$HADOOP_HOME/etc/hadoop/"$parameter_from"-site.xml
    ssh $standby0 "$HADOOP_HOME/bin/hdfs --daemon start namenode"
    sleep 10
    check_nn_health
    if [ $? -eq 0 ]; then
	echo "standby0 has been reconfigured succesfully"
    else
        echo "${ERRORS[$FATAL]}[standby0_reconfig_failure]: failed to reconfigure standby0"
	ret=1
        return $ret
    fi

    # failover between active0 and standby0
    if [ $active0 == 'node-0-link-0' ]; then # nn1 is active, and nn2 is standby
	failover_msg=$($HADOOP_HOME/bin/hdfs haadmin -failover nn1 nn2)
    else
	failover_msg=$($HADOOP_HOME/bin/hdfs haadmin -failover nn2 nn1)
    fi
    failover_ret=$?
    if [ $failover_ret -eq 0 ]; then
	echo "$failover_msg"
    else
        echo "${ERRORS[$FATAL]}[failover_failure]: failed to failover between active0 and standby0"
        ret=2
	return $ret
    fi
    sleep 20
    check_nn_health
    if [ $? -ne 0 ]; then
        echo "${ERRORS[$FATAL]}[nn_unhealth_aftere_failover]: namenode unhealthy"
        ret=3
        return $ret
    fi
    
    # verify active and standby namenodes are switched
    active1=$($HADOOP_HOME/bin/hdfs haadmin -getAllServiceState | grep active | cut -d':' -f1)
    standby1=$($HADOOP_HOME/bin/hdfs haadmin -getAllServiceState | grep standby | cut -d':' -f1)
    if [ "$active1" != "$standby0" ] || [ "$standby1" != "$active0" ]; then
	echo "${ERRORS[$FATAL]}[nn_switch_verify_failure]: namenode switch verification failed"
	ret=4
	return $ret
    fi
    
    # online reconfig standby1
    echo "stop standby1 and reconfig standby1"
    ssh $standby1 "$HADOOP_HOME/bin/hdfs --daemon stop namenode"
    scp $new_conf $standby1:$HADOOP_HOME/etc/hadoop/"$parameter_from"-site.xml
    echo "reconfigued "$parameter_from"-site.xml on standby1"
    ssh $standby1 "$HADOOP_HOME/bin/hdfs --daemon start namenode"
    sleep 10
    check_nn_health
    if [ $? -eq 0 ]; then
	echo "standby1 has been reconfigured succesfully"
    else
        echo "${ERRORS[$FATAL]}[standby1_reconfig_failure]: failed to reconfigure standby1"
	ret=5
        return $ret
    fi
    
    return $ret
}

function online_reconfig_datanode {
    # stop one datanode
    ssh node-"$reconf_datanode"-link-0 "$HADOOP_HOME/bin/hdfs --daemon stop datanode"
       
    # change configuration to file xxx
    scp $new_conf node-"$reconf_datanode"-link-0:$HADOOP_HOME/etc/hadoop/"$parameter_from"-site.xml
    echo "change "$parameter_from"-site.xml configuration as $new_conf"
    
    # reboot datanode
    ssh node-"$reconf_datanode"-link-0 "$HADOOP_HOME/bin/hdfs --daemon start datanode"
    
    return 0
}

function online_reconfig_journalnode {
    # stop one journalnode
    ssh node-"$reconf_journalnode"-link-0 "$HADOOP_HOME/bin/hdfs --daemon stop journalnode"
       
    # change configuration to file xxx
    scp $new_conf node-"$reconf_journalnode"-link-0:$HADOOP_HOME/etc/hadoop/"$parameter_from"-site.xml
    echo "change "$parameter_from"-site.xml configuration as $new_conf"
    
    # reboot journalnode
    ssh node-"$reconf_journalnode"-link-0 "$HADOOP_HOME/bin/hdfs --daemon start journalnode"
    
    return 0
}

function reconfig_cluster {
    $HADOOP_HOME/sbin/stop-dfs.sh    
    sleep 1
    for i in ${allnodes[@]}
    do
        scp $new_conf node-"$i"-link-0:$HADOOP_HOME/etc/hadoop/"$parameter_from"-site.xml
    done
    $HADOOP_HOME/sbin/start-dfs.sh
    $HADOOP_HOME/bin/hdfs haadmin -getAllServiceState
    sleep 10
}

if [ $# -ne 3 ]; then
    echo "${ERRORS[$COMMAND]} ./reconf.sh [cluster|namenode|datanode|journalnode] [parameter_from] [config_file]"
    exit 1
fi


type=$1
parameter_from=$2
new_conf=$3

if [ $type = "namenode" ] || [ $type = "datanode" ] || [ $type = "journalnode" ]; then
    online_reconfig_$type
elif [ $type = "cluster" ]; then
    reconfig_cluster
fi
exit $?
