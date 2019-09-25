#!/bin/bash
# return >1 if exists command error
set -u

if [ -z "$TEST_HOME" ]; then 
    echo "TEST_HOME not set."
    exit 3
fi

# if a script wants to be executed by itself, 
# it needs to load global variables
. $TEST_HOME/sbin/global_var.sh
. $TEST_HOME/sbin/util/argument_checker.sh

hdfs_para_list=parameter_hdfs.txt
core_para_list=parameter_core.txt
# check which configuration file this parameter belongs to, hdfs or core
function find_parameter { 
    parameter=$1
    hdfs_or_core=""
    for p in $(cat $root_etc/$hdfs_para_list)
    do
        if [ "$p" == "$parameter" ] ; then
    	    hdfs_or_core="hdfs"
        fi
    done
    
    for p in $(cat $root_etc/$core_para_list)
    do
        if [ "$p" == "$parameter" ] ; then
    	    hdfs_or_core="core"
        fi
    done
    if [ "$hdfs_or_core" != "hdfs" ] && [ "$hdfs_or_core" != "core" ]; then
	return 1
    fi

    echo "$hdfs_or_core"
    return 0
}

# perform reconfiguration 
function reconf {
    if [ $# -ne 3 ]; then
	echo "${ERRORS[$COMMAND_ERROR]}[wrong_args_reconf]"
    fi
    local component=$1
    local hdfs_or_core_parameter=$2
    local conf_file=$3

    echo "performing reconfig_$component ..."
    $TEST_HOME/sbin/reconf.sh $component $hdfs_or_core_parameter $conf_file
    if [ $? -ne 0 ]; then
        echo "${ERRORS[$RECONFIG_ERROR]}[test:reconfig_component_failure]: reconfig $component failed"
	return 2
    fi
    echo "reconfig_$component done"
    return 0
}

function clean_up_when_errors {
    if [ $# -ne 1 ]; then
	echo "${ERRORS[$COMMAND_ERROR]}[wrong_args_clean_up]"
	return 1
    fi
    local testdir=$1
    $TEST_HOME/sbin/cluster_cmd.sh stop_client_gracefully
    $TEST_HOME/sbin/cluster_cmd.sh collectlog $testdir
    $TEST_HOME/sbin/cluster_cmd.sh stop
    exit 1
}

argument_num=5
argument_num_optional=7
if [ $# -lt $argument_num ]; then
    echo "${ERRORS[$COMMAND_ERROR]}[wrong_arguments]: ./test.sh [component: <${valid_components[@]}>] [parameter] [value1] [value2] [waittime] optional: [read_times] [benchmark_threads]"
    exit 1
fi

component=$1
parameter=$2
value1=$3
value2=$4
waittime=$5
read_times=10 # default value
benchmark_threads=5 # default value
round_n=1 # round of v1-v2-v1 test
hdfs_or_core_parameter="" # global variable

if [ $# -eq $argument_num_optional ]; then
    read_times=$6
    benchmark_threads=$7
fi

if ! validate_argument $component ${valid_components[@]}; then
    echo "${ERRORS[$COMMAND_ERROR]}[wrong_component]: component: ${valid_components[@]}"
    exit 1
fi

# create test dir
testdir=./"$component""$split""$parameter""$split""$value1""$split""$value2""$split""$waittime"
if ! mkdir $testdir ; then
    echo "${ERRORS[$COMMAND_ERROR]}[mkdir_failed]"
    exit 1
fi

# redirect logs generated by the current shell to file 
exec &> $testdir/run.log

# find out which xml file this parameter comes from
hdfs_or_core_parameter=$(find_parameter $parameter)
if [ $? -ne 0 ]; then
    echo "${ERRORS[$COMMAND_ERROR]}[cannot_find_parameter]: $parameter not in $hdfs_para_list nor $core_para_list"
    exit 1
fi
echo "$parameter is from "$hdfs_or_core_parameter"-site.xml"

# make up configuration files
parameter_stub=nametobereplaced
value_stub=valuetobereplaced
v1_conf_file=$testdir/"$hdfs_or_core_parameter"-site.xml.1
v2_conf_file=$testdir/"$hdfs_or_core_parameter"-site.xml.2
cp $root_etc/"$hdfs_or_core_parameter"-site-template.xml $v1_conf_file
cp $root_etc/"$hdfs_or_core_parameter"-site-template.xml $v2_conf_file
sed -i "s/$parameter_stub/$parameter/g" $v1_conf_file
sed -i "s/$parameter_stub/$parameter/g" $v2_conf_file
sed -i "s/$value_stub/$value1/g" $v1_conf_file
sed -i "s/$value_stub/$value2/g" $v2_conf_file

# main procedure
echo "start cluster"
$TEST_HOME/sbin/cluster_cmd.sh start $hdfs_or_core_parameter $v1_conf_file
sleep 5

# init benchmark
echo "init benchmark..."
wait_client_init_timeout=60
timeout $wait_client_init_timeout $TEST_HOME/sbin/cluster_cmd.sh init_client $read_times $benchmark_threads
if [ $? -eq 0 ]; then
    echo "init client succeed"
else
    echo "${ERRORS[$COMMAND_ERROR]}[test:init_client_failure]: init client timeout"
    clean_up_when_errors $testdir
fi
sleep 5

$TEST_HOME/sbin/cluster_cmd.sh start_client $read_times $benchmark_threads

round=0
while [ $round -lt $round_n ]; do
    round=$(( round + 1 ))
    echo "do the $round v1-v2-v1 reconfiguration test"

    sleep $waittime
    
    # perform v1-v2 reconfiguration
    echo performing v1-v2 "$value1"-"$value2" reconfiguration
    sleep 5
    if ! reconf $component $hdfs_or_core_parameter $v2_conf_file; then
        clean_up_when_errors $testdir
    fi
    
    sleep $waittime
    
    # perform v2-v1 reconfiguration
    echo performing v2-v1 "$value2"-"$value1" reconfiguration
    sleep 5
    if ! reconf $component $hdfs_or_core_parameter $v1_conf_file; then
        clean_up_when_errors $testdir
    fi
    
    sleep $waittime

    # perform v1-v2 reconfiguration
    echo performing v1-v2 "$value1"-"$value2" reconfiguration
    sleep 5
    if ! reconf $component $hdfs_or_core_parameter $v2_conf_file; then
        clean_up_when_errors $testdir
    fi
    
    sleep $waittime
done

$TEST_HOME/sbin/cluster_cmd.sh stop_client_gracefully

# collect logs for this test 
$TEST_HOME/sbin/cluster_cmd.sh collectlog $testdir

# stop and clean the cluster
$TEST_HOME/sbin/cluster_cmd.sh stop

exit 0
