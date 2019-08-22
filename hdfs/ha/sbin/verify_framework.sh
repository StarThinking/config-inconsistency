#!/bin/bash

# if a script wants to be executed by itself, 
# it needs to load global variables
. $TEST_HOME/sbin/global_var.sh
. $TEST_HOME/sbin/util/subsetof.sh

if [ $# -ne 2 ]; then
    echo "wrong arguments: [dir] [waittime]"
    exit 1
fi

dir=$1
waittime=$2

component=$(echo $dir | awk -F "$split" '{print $1}')
parameter=$(echo $dir | awk -F "$split" '{print $2}')
value1=$(echo $dir | awk -F "$split" '{print $3}')
value2=$(echo $dir | awk -F "$split" '{print $4}')
echo component=$component parameter=$parameter value1=$value1 value2=$value2
tuple_dir="$component""$split""$parameter""$split""$value1""$split""$value2"
cd $tuple_dir

echo "verify online v1-v2 test"
reconfig_mode=online_reconfig
online_12="$component""$split""$parameter""$split""$value1""$split""$value2""$split""$reconfig_mode""$split""$waittime"
if [ ! -d $online_12 ]; then
    echo "$online_12 not exist, quit!"
    exit 1
fi
subsetof $online_12
ret=$?
if [ $ret -eq 0 ]; then
    echo "no issue: online_12 < online_c, stop."
fi

echo "run online v2-v2 test"
reconfig_mode=online_reconfig
online_22="$component""$split""$parameter""$split""$value2""$split""$value2""$split""$reconfig_mode""$split""$waittime"
if [ ! -d $online_22 ]; then
    echo "$online_22 not exist, quit!"
    exit 1
fi
subsetof $online_12 $online_22
ret=$?
if [ $ret -eq 0 ]; then
    echo "no issue: online_12 < online_c + online_22, stop."
fi

echo "run online v1-v1 test"
reconfig_mode=online_reconfig
online_11="$component""$split""$parameter""$split""$value1""$split""$value1""$split""$reconfig_mode""$split""$waittime"
if [ ! -d $online_11 ]; then
    echo "$online_11 not exist, quit!"
    exit 1
fi
subsetof $online_12 $online_22 $online_11
ret=$?
if [ $ret -eq 0 ]; then
    echo "no issue: online_12 < online_c + online_22 + online_11, stop."
fi

echo "run cluster v1-v2 test"
reconfig_mode=cluster_stop
cluster_12="$component""$split""$parameter""$split""$value1""$split""$value2""$split""$reconfig_mode""$split""$waittime"
if [ ! -d $cluster_12 ]; then
    echo "cluster_12 not exist, quit!"
    exit 1
fi
subsetof $online_12 $online_22 $online_11 $cluster_12
ret=$?
if [ $ret -eq 0 ]; then
    echo "ISSUE: not reconfigurable!"
else
    echo "ISSUE: not online reconfigurable!"
fi
