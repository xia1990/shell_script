#!/bin/bash

#得到本地仓库每个仓库的时间戳和path路径
repo forall -c 'git log --pretty=format:"%ad" --date=raw -1 && echo "$REPO_PATH"' > time_path.txt
#得到最大时间
last_time=`awk 'BEGIN{max=0}{if($1+0 > max+0)max=$1}END{print max}' time_path.txt`
#得到最大时间的path路径
last_path=`grep -n $last_time time_path.txt | awk '{print $3}'`
#进入此仓库，得到这个仓库最后一笔提交
cd $last_path
pwd
git log -1
cd -
