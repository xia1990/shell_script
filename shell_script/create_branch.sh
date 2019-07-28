#!/bin/bash
grep '<project' .repo/manifest.xml | grep -aoe "name=[.A-Z_a-z0-9\"/-]*" | awk -F '"' '{print $2}' > name.txt
for i in `cat name.txt`
do
    ssh -p 29418 10.0.30.9 gerrit create-branch $i P118F_DEV_BRH_SW master
    echo $i
done
