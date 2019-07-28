#!/bin/bash

#ssh -p 29418 10.0.30.10 gerrit query branch:master after:"2018-09-13" project:^LNX_LA_MSM8953_OWL_PSW/.*  status:merged --format JSON | grep -aoe "subject[^,]*" | awk -F ":"  '{print $2}' > log.txt

#此处得到13号所有的提交修改点（包括13号当天的提交修改点）
ssh -p 29418 10.0.30.10 gerrit query branch:master after:"2018-09-13" project:^LNX_LA_MSM8953_OWL_PSW/.*  status:merged --format JSON | grep -aoe "subject[^,]*" | awk -F ":"  '{print $2}' > log.txt

#ssh -p 29418 10.0.30.10 gerrit query branch:master after:"2018-09-13" project:^LNX_LA_MSM8953_OWL_PSW/.*  status:merged > log.txt

sed -i "s/[[]Bug[a-zA-Z0-9\/\-\[\]\"\_\ ]*//g" log.txt
sed -i "s/\"[a-zA-Z0-9\/\-\[\]\"\_\ ]*\]//g" log.txt
