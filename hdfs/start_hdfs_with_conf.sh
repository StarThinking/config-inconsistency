#!/bin/bash

type=$1
property=$2
node=4
namenode=0
datanodes=(1 2 3 4)
HADOOP_HOME=/root/hadoop-3.1.1-src/hadoop-dist/target/hadoop-3.1.1

source ~/.bashrc

scp ~/config-inconsistency/hdfs/etc/* node-"$namenode"-link-0:$HADOOP_HOME/etc/hadoop
$HADOOP_HOME/sbin/stop-dfs.sh

echo "hdfs stopped"

for i in ${datanodes[@]}
do
    scp ~/config-inconsistency/hdfs/etc/* node-"$i"-link-0:$HADOOP_HOME/etc/hadoop
    ssh node-"$i"-link-0 "rm -rf /root/data; mkdir /root/data; rm ~/hadoop-3.1.1-src/hadoop-dist/target/hadoop-3.1.1/logs/*"
done

rm -rf /tmp/hadoop-root

if [ "$#" -ne 2 ]
then
    echo "configuration type property unset, start with default conf"
else
    scp ~/config-inconsistency/hdfs/$type/$property/hdfs-site.xml node-"$node"-link-0:~/hadoop-3.1.1-src/hadoop-dist/target/hadoop-3.1.1/etc/hadoop/hdfs-site.xml
fi

$HADOOP_HOME/bin/hdfs namenode -format
$HADOOP_HOME/sbin/start-dfs.sh
