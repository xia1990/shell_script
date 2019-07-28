#!/bin/bash
#此脚本用来修改XML文件，将revision=dev全部删除

XML_NAME="gaoyuxia.xml"
BRANCH="gaoyuxia"


DEFAULT_LINE=$(grep -i "default" $XML_NAME | grep -aoe "revision=[a-zA-Z0-9\"\"\._]*" | awk -F'"|"' '{print $2}')
echo $DEFAULT_LINE

readarray -t array_xml < $XML_NAME
for line in "${array_xml[@]}"
do
if [ "$DEFAULT_LINE" == "master" ];then
	echo $line | grep -aoe "project"
	if [ "$?" == 0 ];then
		revision_line=$(echo $line | grep -aoe "revision=[a-zA-Z0-9\"\"\._]*")
		if [ "$revision_line" == 'revision="dev"' ];then
			echo ""
		else
			echo $line | tee -a local.xml
		fi
	else
		echo $line | tee -a local.xml
	fi
else
	echo $line | grep -aoe "project"
	if [ "$?" == 0 ];then
		revision_line=$(echo $line | grep -aoe "revision=[a-zA-Z0-9\"\"\._]*")
		if [ "$revision_line" == 'revision="dev"' ];then
			echo ""
		elif [ -z "$revision_line" ];then
			echo ""
		else
			echo $line | tee -a local.xml
		fi
	else
		echo $line | tee -a local.xml
	fi
fi
done
