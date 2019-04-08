#!/bin/bash

para+=('dfs.block.access.token.enable')
value+=('true')
para+=('dfs.ha.tail-edits.in-progress')
value+=('true')
para+=('nfs.allow.insecure.ports')
value+=('false')

times=(63)

reconf_type=namenode
round=2
test_mode=test

i=0
for name in ${para[@]}
do   
    v=${value[i]}
    for waittime in ${times[@]}
    do
        ./sbin/run_test.sh $name $v $reconf_type $test_mode $round $waittime
    done
    i=$(( i + 1 ))
done
