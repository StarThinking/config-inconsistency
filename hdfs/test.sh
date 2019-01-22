#!/bin/bash

type=$1
property=$2
value=$3
node_update=4
namenode=0
datanodes=(1 2 3 4)
nodes=(0 1 2 3 4)
filenum=5
TEST_HOME=/root/config-inconsistency/hdfs
#HADOOP_HOME=/root/hadoop-3.1.1-src/hadoop-dist/target/hadoop-3.1.1

source ~/.bashrc

rm -rf $TEST_HOME/tmp
mkdir $TEST_HOME/tmp

# copy default configuration
scp $TEST_HOME/etc/* node-"$namenode"-link-0:$HADOOP_HOME/etc/hadoop

for i in ${datanodes[@]}
do
    scp $TEST_HOME/etc/* node-"$i"-link-0:$HADOOP_HOME/etc/hadoop
    ssh node-"$i"-link-0  "mkdir /root/data"
done
:'
# start with default configuration
$HADOOP_HOME/bin/hdfs namenode -format
$HADOOP_HOME/sbin/start-dfs.sh

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

# stop and clear up everything
echo "stop and clear up everything"
$HADOOP_HOME/bin/hdfs dfs -rm -r /test/*
$HADOOP_HOME/bin/hdfs dfs -rm -r /test
$HADOOP_HOME/sbin/stop-dfs.sh


rm -rf /tmp/hadoop-root
rm -rf $HADOOP_HOME/logs/*
for i in ${datanodes[@]}
do
    ssh node-"$i"-link-0 "rm -rf /root/data; rm $HADOOP_HOME/logs/*"
done

rm -rf $TEST_HOME/tmp
'
