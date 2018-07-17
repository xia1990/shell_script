#!/bin/bash
#批量修改仓库提交类型

XML="default.xml"
TYPE="CHERRY_PICK"

grep -aoe "name=[.a-z_A-Z0-9\"/-]*" $XML | awk -F'"' '{print $2}' > project_name.txt
readarray -t name_array < project_name.txt
for line in "${name_array[@]}"
do
	ssh -p 29418 10.30.99.88 gerrit set-project $line --submit-type $TYPE
	echo $line:"modified submit type sucessfully!"
done
