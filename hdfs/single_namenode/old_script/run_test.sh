#!/bin/bash

type=$1
property=$2
value=$3
command=test

if [ "$#" -ne 3 ]
then
    echo "e.g., ./test.sh [type] [property] [value]"
    exit
fi

./test.sh $type $property $value $command 2>&1 | tee $type/$property/$value/client.log

echo 'test $type $property $value' >> $type/$property/$value/client.log
