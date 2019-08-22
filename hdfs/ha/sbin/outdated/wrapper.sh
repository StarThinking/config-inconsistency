#!/bin/bash

if [ -z "$TEST_HOME" ]; then
    echo "TEST_HOME not set."
    exit
fi

if [ "$#" -ne 2 ]; then
    echo "wrong arguments!"
    exit 1
fi

parameter=$1
default_value=$2
inverse_value=''

if [ $default_value = 'true' ]; then
    inverse_value='false'
elif [ $default_value = 'false' ]; then
    inverse_value='true'
else 
    echo 'error'
fi

echo "default_value is $default_value, inverse_value is $inverse_value"

component=namenode
test_mode=default
round=2
waittime=60
ret=0

$TEST_HOME/sbin/run_test.sh $parameter $inverse_value $component $test_mode $round $waittime
testdir="$TEST_HOME"/"$parameter"-"$inverse_value"-$component-$test_mode-$round-$waittime

$TEST_HOME/sbin/verify_result.sh $testdir $component
ret=$?

if [ $ret -eq 0 ]; then
    echo "$parameter seems independent"
    exit 0
else
    echo "$parameter seems suspicious. let's do inverse-value background test"
fi

test_mode=test
round=2
$TEST_HOME/sbin/run_test.sh $parameter $inverse_value $component $test_mode $round $waittime
