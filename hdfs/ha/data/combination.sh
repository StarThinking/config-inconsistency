#!/bin/bash

if [ $# -ne 1 ]; then
    echo "wrong arguments"
    exit 1
fi

component=$1

while IFS= read -r parameter
do
    echo $component $parameter true TRUE
    echo $component $parameter false FALSE
done


#for v in ${values[@]}
#do    
#done
