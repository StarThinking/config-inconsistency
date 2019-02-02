#!/bin/bash

if [ $# -lt 1 ]; then
    echo "./test TESTDIR"
    exit
fi

testdir=$1

# start the cluster
./cmd.sh start

# run benchmark
for i in $(seq 1 8)
do
    ./benchmark.sh $i 2>&1 | tee $testdir/client.log &
    pids[$i]=$!
done

# change configuration
./reconf.sh $testdir/hdfs-site.xml

# wait for a long time to perform test
sleep 60
./reconf.sh $testdir/hdfs-site.xml
sleep 60

# kill and wait benchmark finish
for i in $(seq 1 10)
do
    kill ${pid[$i]}
done

for i in $(seq 1 10)
do
    wait ${pid[$i]}
done

# collect logs for this test 
./cmd.sh collectlog $testdir

# stop and clean the cluster
./cmd.sh stop
