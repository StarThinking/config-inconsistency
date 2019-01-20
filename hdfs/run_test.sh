#!/bin/bash

type=$1
property=$2
node=4
HDFS_HOME=~/hadoop-3.1.1-src/hadoop-dist/target/hadoop-3.1.1
SLEEP_TIME=10
nodes=(0 1 2 3 4)

if [ "$#" -ne 2 ]
then
    echo "configuration type property unset, quit test"
    exit
fi

# clear up
rm sample*
$HDFS_HOME/bin/hdfs dfs -rm /sample*
rm -rf $type/$property/node*
rm -rf $type/$property/client*



for i in $(seq 1 3)
do
    for j in $(seq 1 5)
    do
	dd if=/dev/urandom of=sample$j.txt.orignal bs=16M count=16
	$HDFS_HOME/bin/hdfs dfs -copyFromLocal sample$j.txt.orignal /sample$j.txt
	$HDFS_HOME/bin/hdfs dfs -copyToLocal /sample$j.txt
	diff sample$j.txt sample$j.txt.orignal >> $type/$property/client.log
    done
    rm sample*
    $HDFS_HOME/bin/hdfs dfs -rm /sample*
    sleep $SLEEP_TIME
done

for i in ${nodes[@]}
do
    mkdir $type/$property/node-"$i"-link-0
    scp -r node-"$i"-link-0:$HDFS_HOME/logs $type/$property/node-"$i"-link-0
done

