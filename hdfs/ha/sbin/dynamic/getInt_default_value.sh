#!/bin/bash

dir=$1

functions+=('Configuration.java:getInt:1480')

for component in namenodes jnodes datanodes
do
    echo "#############"$component"#############"
    
    for function in ${functions[@]} 
    do
	get_method="$function"
	echo ""$function" (`grep -r "$get_method" $dir/all_logs/$component | awk -F " " '{print $9}' | sort -u | wc -l`)"
	grep -r "$get_method" $dir/all_logs/$component | awk -F " " '{print $9" "$10}' | sort -u
	echo ""
#        grep -r msx $dir/all_logs/$component | awk -F " " '{ if ($9 ~ /dfs./) print $8 " " $9}' | awk -F " " '{if ($1 !~ /\.hdfs\./) print $1 " " $2}' | awk -F " " -v f="$function" '{if ($1 == f) print $1 " " $2}' | sort -u
    done

    echo ""
done
