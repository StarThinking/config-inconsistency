#!/bin/bash

set -u

if [ -z "$TEST_HOME" ]; then
    echo "TEST_HOME not set."
    exit 3
fi

#methods+=('Configuration.java:get:1196')
methods+=('Configuration.java:get:1201')
methods+=('Configuration.java:get:1457')
methods+=('Configuration.java:getBoolean:1668')
methods+=('Configuration.java:getDouble:1640')
methods+=('Configuration.java:getFloat:1610')
methods+=('Configuration.java:getHexDigits:1569')
methods+=('Configuration.java:getInt:1480')
methods+=('Configuration.java:getInts:1502')
methods+=('Configuration.java:getLong:1535')
methods+=('Configuration.java:getLongBytes:1561')
#dir=$TEST_HOME/data/dynamic_result/namenode-dfs.image.compress-false-false-online_reconfig-600/
#dir=~/config-inconsistency/hdfs/ha/none%dfs.image.compress%false%false%60/

if [ $# -ne 3 ]; then
    echo "wrong args, quit. e.g., [component] [get_method] [dir]"
    echo "valid get methods:"
    echo "${methods[@]}"
    exit 1
fi

component=$1
get_method=$2
dir=$3

if [ ! -d $dir ]; then
    echo "dir not exist"
    exit 1
fi

found=0

for f in ${methods[@]}
do
    if [ "$get_method" == "$f" ]; then
        found=1
	break	
    fi
done

if [ $found -eq 0 ]; then
    echo "given get method $get_method cannot be found, quit"
    echo "valid get methods:"
    echo "${methods[@]}"
    exit 1
fi

if [ "$component" != 'namenode' ] && [ "$component" != 'journalnode' ] && [ "$component" != 'datanode' ]; then
    echo "wrong component"
    exit 1
fi

component="$component"s
parameters=($(grep -r "$get_method" $dir/all_logs/$component | awk -F " " '{print $9}' | sort -u))
#echo "parameters used by $get_method on $component: (${#parameters[@]})"
grep -r "$get_method" $dir/all_logs/$component | awk -F " " '{print $9" "$10}' | sort -u
#for p in ${parameters[@]}
#do
#    echo $p
#done
