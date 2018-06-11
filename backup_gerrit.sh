#!/bin/bash

echo "start backup gerrit"
rsync -avzp --delete /home/byd/review_project/git/ gaoyuxia@10.30.11.107:/home/gaoyuxia/MIRROR/
echo "start backup mysql"
rsync -avzp --delete /home/byd/backup_script/reviewdb_project`date +%Y-%m-%d` gaoyuxia@10.30.11.107:/home/gaoyuxia/MIRROR/
echo "end backup"
