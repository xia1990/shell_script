#!/bin/bash

for i in `cat project_name.txt`
do
    echo $i
    ssh -p 29418 10.0.30.10 gerrit set-project $i --submit-type FAST_FORWARD_ONLY
done
