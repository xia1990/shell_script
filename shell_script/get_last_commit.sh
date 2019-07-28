#!/bin/bash
repo forall -c 'git log --pretty=format:"%ad" --date=raw -1 && echo " $REPO_PATH"' > time_path.txt
last_time=`awk 'BEGIN {max = 0} {if ($1+0 > max+0) max=$1} END {print max}' time_path.txt`
last_path=`grep -n $last_time time_path.txt | awk '{print $3}'`
cd $last_path
    pwd
    git log -1
cd -

#grep '<project' ASUS_X00PD_WW_User_V1.0B48_20180423.xml  | grep -aoe "revision=[.A-Z_a-z0-9\"/-]*" | awk -F '"|"' '{print $2}' > commit_id.txt
#for i in `cat commit_id.txt`
#do
#    ssh -p 29418 10.0.30.9 gerrit query commit:$i
#done
