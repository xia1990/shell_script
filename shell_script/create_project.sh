#!/bin/bash
#创建远程仓库脚本

for i in `cat project_name.txt`
do
    ssh -p 29418 10.0.30.10 gerrit create-project $i -t FAST_FORWARD_ONLY -p Privilege/test
    echo $i----"创建完成"
done    
