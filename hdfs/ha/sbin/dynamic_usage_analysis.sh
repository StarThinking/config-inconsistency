#!/bin/bash

dir=$1

for component in namenodes jnodes datanodes
do
    echo ""$component":"
    
    for function in get1 get2 getInt getInts getLong getLongBytes getHexDigits getFloat getDouble getBoolean 
    do
#        grep -r msx $dir/all_logs/$component | awk -F " " '{ if ($9 ~ /dfs./) print $8 " " $9}' | awk -F " " '{if ($1 !~ /\.hdfs\./) print $1 " " $2}' | awk -F " " -v f="$function" '{if ($1 == f) print $1 " " $2}' | sort -u
        echo -n "# of parameters read from $function:"
        grep -r msx $dir/all_logs/$component | awk -F " " '{ if ($9 ~ /dfs./) print $8 " " $9}' | awk -F " " '{if ($1 !~ /\.hdfs\./) print $1 " " $2}' | awk -F " " -v f="$function" '{if ($1 == f) print $1 " " $2}' | sort -u | wc -l
    done

    echo ""
done
