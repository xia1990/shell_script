#!/bin/bash
repoc list > project.list
readarray -t array < project.list
for i in "${array[@]}"
do
    path=$(echo $i | awk '{print $1}')
    name=$(echo $i | awk '{print $3}')
#    echo $path $name
    ssh -p 29418 10.0.30.9  gerrit set-project-parent "$name" -p "MT6739_P_CODE/ACCESS_CONTROL"
    echo "$name set parent successful"
done
