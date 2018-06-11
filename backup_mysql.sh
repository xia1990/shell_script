#!/bin/bash
#备份数据库

rm -rf newreviewdb_project_`date +%F` reviewdb_project_`date +%F`
mysqldump -u root -p reviewdb_project > /home/byd/backup_script/reviewdb_project_`date +%F`
mysqldump -u root -p newreviewdb_project > /home/byd/backup_script/newreviewdb_project_`date +%F`

