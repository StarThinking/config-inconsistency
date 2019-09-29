#!/bin/bash
set -u
if [ -z "$TEST_HOME" ]; then 
    echo "TEST_HOME not set."
    exit 1
fi

# if a script wants to be executed by itself, 
# it needs to load global variables
. $TEST_HOME/sbin/global_var.sh
. $TEST_HOME/sbin/util/argument_checker.sh

if [ $# -ne 3 ]; then
    echo "${ERRORS[$COMMAND_ERROR]}[wrong_args] ./reconf.sh [component] [parameter_from] [config_file]"
    exit 1
fi

component=$1
parameter_from=$2
new_conf=$3
namenode_reconf_interval=180
datanode_reconf_interval=60
journalnode_reconf_interval=60

function check_nn_health {
    max_try=5
    i=0
    for (( i=0; i<=max_try; i++ ))    
    do
        $HADOOP_HOME/bin/hdfs haadmin -checkHealth nn1
        health_nn1=$?
        $HADOOP_HOME/bin/hdfs haadmin -checkHealth nn2
        health_nn2=$?
        if [ $health_nn1 -eq 0 ] && [ $health_nn2 -eq 0 ]; then
	    echo "namenodes are healthy"
	    break
        else
	    echo "namenodes are not healthy, wait for 5 seconds and recheck."
	    sleep 5
        fi
    done
    
    if [ $i -ge $max_try ]; then
        echo "${ERRORS[$RECONFIG_ERROR]}[namenode_unhealth]: namenode1 $health_nn1, namenode2 $health_nn2"
    	return 1
    fi
    return 0
}

function failover {
    if [ $# -ne 2 ]; then
	echo "${ERRORS[$COMMAND_ERROR]}[wrong_arguments]: failover"
    fi 
    active0=$1
    standby0=$2
    
    # failover between active0 and standby0
    # node-0-link-0: nn1, node-1-link-0: nn2
    if [ "$active0" == 'node-0-link-0' ]; then # nn1 is active, and nn2 is standby
        failover_msg=$($HADOOP_HOME/bin/hdfs haadmin -failover nn1 nn2)
    else
        failover_msg=$($HADOOP_HOME/bin/hdfs haadmin -failover nn2 nn1)
    fi
    sleep 20
    
    # check failover return value
    if [ $? -ne 0 ]; then
        echo "${ERRORS[$RECONFIG_ERROR]}[failover_failure]: failed to failover between active0 and standby0"
        return 1
    fi 
    
    # verify active and standby namenodes have been switched
    active1=$(get_namenode_ip active)
    standby1=$(get_namenode_ip standby)
    if [ "$active1" != "$standby0" ] || [ "$standby1" != "$active0" ]; then
        echo "${ERRORS[$RECONFIG_ERROR]}[nn_switch_verify_failure]: namenode switch verification failed"
        return 2
    fi
    
    # check namenode health
    if ! check_nn_health; then
        echo "${ERRORS[$RECONFIG_ERROR]}[nn_unhealth_aftere_failover]: namenode unhealthy"
        return 3
    fi
    echo "$failover_msg"
    return 0
}

function reconfig_namenodes {
    ret=0

    echo "reconfig namenodes ${namenodes[@]}"
    
    reconfig_active_namenode
    if [ $? -ne 0 ]; then
        ret=1
    fi
    
    sleep $namenode_reconf_interval
    
    reconfig_standby_namenode
    if [ $? -ne 0 ]; then
        ret=1
    fi
  
    return $ret
}

function reconfig_datanodes {
    ret=0
    
    echo "reconfig datanodes ${datanodes[@]}"

    for i in ${datanodes[@]}
    do
	reconfig_datanode $i
        if [ $? -ne 0 ]; then
	    ret=1
	fi
	sleep $datanode_reconf_interval
    done

    return $ret
}

function reconfig_journalnodes {
    ret=0
    
    echo "reconfig journalnodes ${journalnodes[@]}"

    for i in ${journalnodes[@]}
    do
	reconfig_journalnode $i
        if [ $? -ne 0 ]; then
	    ret=1
	fi
	sleep $journalnode_reconf_interval
    done

    return $ret
}

function reconfig_standby_namenode { # return 0 if success, 1 if error
    if [ $# -eq 1 ]; then
	standby=$1
    elif [ $# -eq 0 ]; then # find standby namenode node
        standby=$(get_namenode_ip standby)
    else
	echo "${ERRORS[$COMMAND_ERROR]}[wrong_arguments]: reconfig_standby_namenode"
	return 1
    fi
    
    echo "stopping standby namenode $standby ..." 
    ssh $standby "$HADOOP_HOME/bin/hdfs --daemon stop namenode"    
    scp $new_conf $standby:$HADOOP_HOME/etc/hadoop/"$parameter_from"-site.xml
    sleep 5

    echo "starting standby namenode $standby ..." 
    ssh $standby "$HADOOP_HOME/bin/hdfs --daemon start namenode"
    sleep 5
    
    if ! check_nn_health; then
        echo "${ERRORS[$RECONFIG_ERROR]}[reconfig_standby_namenode_failure]: failed"
	return 2
    fi
    echo "finished reconfig for standby namenode on $standby"
    return 0
}

function reconfig_active_namenode { # return 0 if success, 1 if error
    # find avtive0 and standby0 
    active0=$(get_namenode_ip active)
    standby0=$(get_namenode_ip standby)
    echo "active0 is $active0"
    echo "standby0 is $standby0"

    # first failover
    if ! failover $active0 $standby0; then
	echo "${ERRORS[$RECONFIG_ERROR]}[first_failover_failed]: failover failed"
	return 1
    else
	active1=$standby0
	standby1=$active0
    fi
 
    # reconfig standby1
    if ! reconfig_standby_namenode $standby1; then
	return 2
    fi
    
    # second failover
    if ! failover $active1 $standby1; then
	echo "${ERRORS[$RECONFIG_ERROR]}[second_failover_failed]: failover failed"
	return 3
    fi
    active2=$(get_namenode_ip active)
    standby2=$(get_namenode_ip standby)
    echo "active2 is $active2"
    echo "standby2 is $standby2"
    return 0
}

function reconfig_datanode {
    reconf_datanode=$1
    # stop one datanode
    ssh node-"$reconf_datanode"-link-0 "$HADOOP_HOME/bin/hdfs --daemon stop datanode"
       
    # change configuration to file xxx
    scp $new_conf node-"$reconf_datanode"-link-0:$HADOOP_HOME/etc/hadoop/"$parameter_from"-site.xml
    echo "change "$parameter_from"-site.xml configuration as $new_conf on datanode $reconf_datanode"
    sleep 5 
    # reboot datanode
    ssh node-"$reconf_datanode"-link-0 "$HADOOP_HOME/bin/hdfs --daemon start datanode"
    
    return 0
}

function reconfig_journalnode {
    reconf_journalnode=$1
    # stop one journalnode
    ssh node-"$reconf_journalnode"-link-0 "$HADOOP_HOME/bin/hdfs --daemon stop journalnode"
       
    # change configuration to file xxx
    scp $new_conf node-"$reconf_journalnode"-link-0:$HADOOP_HOME/etc/hadoop/"$parameter_from"-site.xml
    echo "change "$parameter_from"-site.xml configuration as $new_conf on journalnode $reconf_journalnode"
    sleep 5
    # reboot journalnode
    ssh node-"$reconf_journalnode"-link-0 "$HADOOP_HOME/bin/hdfs --daemon start journalnode"
    
    return 0
}

function reconfig_clusters {
    reconfig_cluster
    return $?
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
    check_nn_health
    return $?
}

reconfig_"$component"s
exit $?
