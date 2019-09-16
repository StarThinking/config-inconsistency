#!/bin/bash

if [ $# -ne 1 ]; then
    echo "wrong arguments"
    exit 1
fi

values=('true' 'false')
component=$1
duration=120
#parameters=$(cat $file)

while IFS= read -r parameter
do
    echo $component $parameter true TRUE
    echo $component $parameter false FALSE
done


#for v in ${values[@]}
#do    
#done
