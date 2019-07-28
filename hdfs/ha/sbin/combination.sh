#!/bin/bash

#if [ $# -ne 1 ]; then
#    echo "wrong arguments"
#    exit 1
#fi

values=('true' 'false')
component=$1
duration=300
#parameters=$(cat $file)

while IFS= read -r parameter
do
    echo $component $parameter false true
    echo $component $parameter true false
done


#for v in ${values[@]}
#do    
#done
