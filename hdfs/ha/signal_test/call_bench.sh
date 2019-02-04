#!/bin/bash

#. ./benchmark.sh

./benchmark.sh 123 2>&1 1>tmp.txt & 
pid=$!

sleep 10

kill $pid
wait $pid

echo 'benchmark caller exits'
