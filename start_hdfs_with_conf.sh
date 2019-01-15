#!/bin/bash

type=$1
property=$2
node=4

~/hadoop-3.1.1-src/hadoop-dist/target/hadoop-3.1.1/sbin/stop-dfs.sh

echo "hdfs stopped"

for i in 1 2 3 4
do
    scp ~/config-inconsistency/hdfs/etc/* node-"$i"-link-0:~/hadoop-3.1.1-src/hadoop-dist/target/hadoop-3.1.1/etc/hadoop
    ssh node-"$i"-link-0 "rm -rf /root/data; mkdir /root/data; rm ~/hadoop-3.1.1-src/hadoop-dist/target/hadoop-3.1.1/logs/*"
done

rm -rf /tmp/hadoop-root

if [ "$#" -ne 2 ]
then
    echo "configuration type property unset, start with default conf"
else
    scp ~/config-inconsistency/hdfs/$type/$property/hdfs-site.xml node-"$node"-link-0:~/hadoop-3.1.1-src/hadoop-dist/target/hadoop-3.1.1/etc/hadoop
fi

~/hadoop-3.1.1-src/hadoop-dist/target/hadoop-3.1.1/bin/hdfs namenode -format
~/hadoop-3.1.1-src/hadoop-dist/target/hadoop-3.1.1/sbin/start-dfs.sh
