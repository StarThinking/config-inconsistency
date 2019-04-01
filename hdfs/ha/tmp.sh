#!/bin/bash

para+=('dfs.balancer.getBlocks.size')
para+=('dfs.provided.aliasmap.load.retries')
para+=('dfs.datanode.cache.revocation.timeout.ms')
para+=('dfs.datanode.failed.volumes.tolerated')
para+=('dfs.datanode.lazywriter.interval.sec')

times=(300 301 302 303 304)

min_or_max=min
default_value=0
reconf_type=datanode
round=2
time_senestive=1

for name in ${para[@]}
do    
    for waittime in ${times[@]}
    do
        ./sbin/binary_search.sh $min_or_max $name $default_value $reconf_type $round $waittime $time_senestive
    done
done
