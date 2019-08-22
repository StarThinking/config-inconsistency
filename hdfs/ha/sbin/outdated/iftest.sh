#!/bin/bash

function success {
    return 0
}

function fail {
    return 2
}

#success
#ret=$?
#echo $ret
#if $ret; then
#    echo "success"
#else
#    echo "fail"
#fi

if ! fail; then
    echo "success"
else
    echo "fail"
fi
