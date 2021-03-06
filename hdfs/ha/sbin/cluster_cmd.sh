#!/bin/bash
set -u

if [ -z "$TEST_HOME" ]; then 
    echo "TEST_HOME not set."
    exit 3
fi

# if a script wants to be executed by itself, 
# it needs to load global variables
. $TEST_HOME/sbin/global_var.sh

if [ "$#" -lt 1 ]
then
    echo "e.g., ./cluster_cmd.sh [start|stop|collectlog|start_client|stop_client|stop_client_gracefully] optional: [hdfs-site.xml] [read_times] [benchmark_threads]"
    exit
fi

function start {
    from=$1
    init_conf=$2
    # datanodes parameter --> hdfs etc/workers 
    > $TEST_HOME/etc/workers
    for i in ${datanodes[@]}
    do
        echo node-"$i"-link-0 >> $TEST_HOME/etc/workers
    done

    # journalnodes --> etc/hdfs-site.xml and hdfs-site-template.xml
   
    # copy configuration to all nodes
    for i in ${allnodes[@]}
    do
	scp $TEST_HOME/etc/* node-"$i"-link-0:$HADOOP_HOME/etc/hadoop
        # override hadoop common  jar
        scp $TEST_HOME/lib/hadoop-common-3.1.2.jar node-"$i"-link-0:$HADOOP_HOME/share/hadoop/common/
 	# sync on node other than node-0
	if [ $i -ne 0 ]; then
            ssh node-"$i"-link-0 "cd $TEST_HOME; git checkout .; git clean -fd; git pull"
	fi
	if [ "$init_conf" != "" ]; then
  	    # send default hdfs and core configuration files
  	    echo "send default hdfs and core configuration files"
	    scp $TEST_HOME/etc/core-site.xml node-"$i"-link-0:$HADOOP_HOME/etc/hadoop
	    scp $TEST_HOME/etc/hdfs-site.xml node-"$i"-link-0:$HADOOP_HOME/etc/hadoop
 	    echo "send $init_conf as default "$from"-site.xml"
	    scp $init_conf node-"$i"-link-0:$HADOOP_HOME/etc/hadoop/"$from"-site.xml
	fi
    done
    
    ### START MANUAL FAILOVER ###
    # start journal nodes
    for i in ${journalnodes[@]}
    do
        #ssh node-$i-link-0 "mkdir /root/journal"
        ssh node-"$i"-link-0 "$HADOOP_HOME/bin/hdfs --daemon start journalnode"
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
    for i in ${journalnodes[@]}
    do
        ssh node-"$i"-link-0 "$HADOOP_HOME/bin/hdfs --daemon stop journalnode"
    done

    ### START AUTOMATIC FAILOVER ###
    # start zookeeper
    echo "start zookeeper"
    for i in ${znodes[@]}
    do
        scp $TEST_HOME/etc/zoo.cfg node-"$i"-link-0:$ZOOKEEPER_HOME/conf
        ssh node-"$i"-link-0 "mkdir /root/zookeeper-data"
    done

    for i in $(seq 0 2)
    do
        ssh node-${znodes[$i]}-link-0 "echo ${znode_ids[$i]} > /root/zookeeper-data/myid"
    done 

    for i in ${znodes[@]}
    do
        ssh node-"$i"-link-0 "$ZOOKEEPER_HOME/bin/zkServer.sh start" &
    done
    
    # prepare datanode dir
    for i in ${datanodes[@]}
    do
        ssh node-"$i"-link-0 "rm -rf $hadoop_data_dir/*"
    done

    # init zookeeper
    sleep 5
    $HADOOP_HOME/bin/hdfs zkfc -formatZK

    $HADOOP_HOME/sbin/start-dfs.sh
    $HADOOP_HOME/bin/hdfs haadmin -getAllServiceState
}

function init_client {
    read_times=$1
    benchmark_threads=$2
    
    for i in ${clients[@]}
    do
        echo "init client node-"$i"-link-0 begins"
        ssh node-"$i"-link-0 "/bin/bash --login $TEST_HOME/sbin/benchmark.sh init $read_times $benchmark_threads"  # fake 1st arguments
        echo "init client node-"$i"-link-0 ends"
    done
    return 0
#    expected_line_num=$(( benchmark_threads + 1 ))
#    echo "expected_line_num = $expected_line_num"
#    while true
#    do
#        line_num=$($HADOOP_HOME/bin/hdfs dfs -ls / | wc -l)
#        echo "line_num = $line_num"
#        if [ $line_num -eq $expected_line_num ]; then
#            return 0
#        else
#            echo "line_num $line_num not equal as expected_line_num $expected_line_num, sleep 20s"
#            sleep 20
#        fi
#    done
#
#    if [ $line_num -eq $expected_line_num ]; then
#        return 0
#    else
#        return 1
#    fi
}

# start running benchmark. keep it running on the background on the client
function start_client {
    read_times=$1
    benchmark_threads=$2

    for i in ${clients[@]}
    do
        ssh node-$i-link-0 "/bin/bash --login $TEST_HOME/sbin/benchmark.sh start $read_times $benchmark_threads" &
    done
}

# stop running benchmark gracefully 
function stop_client_gracefully {
    for i in ${clients[@]}
    do
        count=0
	max_try=10
        while [ $count -le $max_try ]
        do
            ssh node-"$i"-link-0 "ps aux | grep bench | awk -F ' ' '{print \$2}' | xargs kill "
            echo "sleep 10 seconds to wait benchmark to quit itself"
            sleep 10

            #check
            echo "check if client benchmark has been killed"
            if [ $(ssh node-"$i"-link-0 "jps | grep FsShell" | wc -l) -eq 0 ]; then
                echo "benchmark is stopped"
                break;
            fi
            
            count=$(( count + 1 ))
        done

        # cannot wait too long
        if [ $count -gt $max_try ]; then
            echo "${ERRORS[$FATAL_ERROR]}[cluster_cmd:benchmark_hanging] benchamrk seems to be hanging. kill it forcefully."
            stop_client
        fi
    done
}

# stop running benchmark
function stop_client {
    # kill client
    for i in ${clients[@]}
    do
        ssh node-"$i"-link-0  "ps aux | grep bench | awk -F ' ' '{print \$2}' | xargs kill -9"
        ssh node-"$i"-link-0 "pids=\$(jps | grep FsShell | awk -F ' ' '{print \$1}'); for p in \${pids[@]}; do echo killing FsShell \$p; kill -9 \$p; done"
        ssh node-"$i"-link-0  "rm -rf $large_file_dir_tmp/*"
    done
}

function stop {
    # stop and clear up everything
    
    echo "stop hdfs"
    $HADOOP_HOME/sbin/stop-dfs.sh

    for i in ${namenodes[@]}
    do
        ssh node-"$i"-link-0 "rm -rf /tmp/hadoop-root; rm -rf $HADOOP_HOME/logs/*"
	ssh node-"$i"-link-0 "pkill -9 DFSZKFailoverController; pkill -9 NameNode"
    done

    for i in ${datanodes[@]}
    do
        ssh node-"$i"-link-0 "rm -rf $hadoop_data_dir/*; rm -rf $HADOOP_HOME/logs/*"
	ssh node-"$i"-link-0 "pkill -9 DataNode"
    done
    
    for i in ${journalnodes[@]}
    do
        ssh node-"$i"-link-0 "rm -rf $journal_dir/*; rm -rf $HADOOP_HOME/logs/*"
	ssh node-"$i"-link-0 "pkill -9 JournalNode"
    done

    # stop and clear up zookeeper
    echo "stop zookeeper"
    for i in ${znodes[@]}
    do
        ssh node-"$i"-link-0 "$ZOOKEEPER_HOME/bin/zkServer.sh stop; rm -rf /root/zookeeper-data"
        ssh node-"$i"-link-0 "pkill -9 QuorumPeerMain"
    done
    
    for i in ${clients[@]}
    do
        ssh node-"$i"-link-0  "rm -rf $large_file_dir_tmp"
    done
}

function collectlog {
    local test=$1
    echo "collect logs for test $test"
    mkdir $test/all_logs
    mkdir $test/all_logs/namenodes
    mkdir $test/all_logs/datanodes
    mkdir $test/all_logs/journalnodes
    mkdir $test/all_logs/clients
    
    for i in ${namenodes[@]}
    do
        scp node-"$i"-link-0:$HADOOP_HOME/logs/hadoop-root-namenode* $test/all_logs/namenodes
    done
    
    for i in ${datanodes[@]}
    do
        scp node-"$i"-link-0:$HADOOP_HOME/logs/hadoop-root-datanode* $test/all_logs/datanodes
    done
    
    for i in ${journalnodes[@]}
    do
        scp node-"$i"-link-0:$HADOOP_HOME/logs/hadoop-root-journalnode* $test/all_logs/journalnodes
    done
   
    for i in ${clients[@]}
    do
        scp node-"$i"-link-0:/tmp/client*.log $test/all_logs/clients
        ssh node-"$i"-link-0 "rm /tmp/client*.log"
    done
}

command=$1
shift 1

if [ $command = "start" ]; then
    if [ "$#" -eq 2 ]; then
        start $1 $2
    else
	echo "${ERRORS[$COMMAND_ERROR]}[wrong_args]: wrong arguments"
    fi
elif [ $command = "stop" ]; then
    stop
elif [ $command = "collectlog" ]; then
    if [ "$#" -ne 1 ]; then
        echo "${ERRORS[$COMMAND_ERROR]}[wrong_args]: e.g., ./cluster_cmd.sh collectlog TEST_DIR"
    else
        collectlog $1
    fi
elif [ $command = "init_client" ]; then
    init_client $1 $2
    exit $?
elif [ $command = "start_client" ]; then
    if [ "$#" -ne 2 ]; then
	echo "${ERRORS[$COMMAND_ERROR]}[wrong_args]: wrong arguments"
    else
        start_client $1 $2
    fi
elif [ $command = "stop_client" ]; then
    stop_client
elif [ $command = "stop_client_gracefully" ]; then
    stop_client_gracefully
else
    echo "${ERRORS[$COMMAND_ERROR]}[wrong_args]: e.g., ./cluster_cmd.sh [start|stop|collectlog]"
fi
