#!/bin/bash
#repoc list -n > project_list
grep project .repo/manifest.xml  | grep -aoe "name=[.A-Z_a-z0-9\"/-]*" | awk -F '"|"' '{print $2}' > project_list
readarray -t project_arrsy < project_list
rm project_list
for i in "${project_arrsy[@]}"
do
    ssh -p 29418 10.0.30.9 gerrit gc "$i"
    if [ "$?" == 0 ]
    then
        echo "gc successful $i"
    else
        echo "gc failed $i" && exit 1
    fi
done
