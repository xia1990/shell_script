#!/bin/bash
#备份数据库

rm -rf reviewdb_project`date +%Y-%m-%d`
mysqldump -u root -p reviewdb_project > /home/byd/backup_script/reviewdb_project`date +%Y-%m-%d`

