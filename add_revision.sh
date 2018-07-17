#!/bin/bash
#添加revision的值


XML=test.xml
LOGFILE=commitId.txt


readarray -t xml_array < $XML
for line in "${xml_array[@]}"
do
	echo $line | grep -aoe "project"
	if [ "$?" == 0 ];then
		COMMITID=$(cat -n $LOGFILE) 
		echo $line | sed -n "s/path=[.A-Z_a-z0-9\"/-]*/& revision=\"$COMMITID\"/g"p | tee -a local.xml
	else
		echo $line | tee -a local.xml
	fi
done
