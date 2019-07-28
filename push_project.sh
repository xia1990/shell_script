#!/bin/bash

for i in `cat project_path.txt`
do
    pushd $i
        git push origin2 HEAD:master_r3.0.1_00029.1
        #git push origin2 HEAD:master
    popd 
done
