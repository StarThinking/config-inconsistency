#!/bin/bash

#./shellsiganaltest.sh &
./int.sh &

pid=$!

sleep 10

kill $pid

wait $pid

echo "process $pid is killed"
