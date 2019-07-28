#!/bin/bash
#更新mirror库脚本

for i in `ls`
do
    if [ -d $i ];then
        cd $i
            repo sync -j4 -f
        cd -
    fi
done
