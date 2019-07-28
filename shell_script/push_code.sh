#!/bin/bash
#推送代码到远程 

for i in `cat project_path.txt`
do
    pushd $i > /dev/null
        git push origin master:master | tee -a error.log
    popd > /dev/null
done
