#!/bin/bash

#. ./benchmark.sh

./benchmark.sh 123 & 
pid=$!

sleep 10

kill $pid
wait $pid

echo 'benchmark caller exits'
