#!/bin/bash
#此脚本用来修改XML文件，将文件中的revision!=dev的值全部删除

XML_NAME="gaoyuxia.xml"
BRANCH="gaoyuxia"

#查找default行中revision中的值
DEFAULT_LINE=$(grep -i "default" $XML_NAME | grep -aoe "revision=[a-zA-Z0-9\"\"\._]*" | awk -F'"|"' '{print $2}')
echo $DEFAULT_LINE
readarray -t array_xml < $XML_NAME
for line in "${array_xml[@]}"
do
	#如果默认是master分支
	if [ "$DEFAULT_LINE" == "master" ];then
		echo $line | grep -aoe "project"
		if [ "$?" == 0 ];then
			revision_line=$(echo $line | grep -aoe "revision=[a-zA-Z0-9\"\"\._]*")
			#如果是dev分支直接输出
			if [ "$revision_line" == 'revision="dev"' ];then
				echo $line | tee -a local.xml
			else
			#如果不是dev分支输出为空
				echo ""
			fi
		else
			echo $line | tee -a local.xml
		fi
	else #如果默认是其它分支
		echo "$line" | grep -aoe "project"
		if [ "$?" == 0 ];then
			revision_line=$(echo $line | grep -aoe "revision=[a-zA-Z0-9\"\"\._]*")
			#如果是dev分支直接输出
			if [ "$revision_line" == 'revision="dev"' ];then
				echo $line | tee -a local.xml
			#如果没有revision属性也直接输出
			elif [ -z "$revision_line" ];then
				echo $line | tee -a local.xml
			else
			#如果revision的值是其它内容，则输出为空，相当于删除操作
				echo ""
			fi
		else
			echo $line | tee -a local.xml			
		fi
	fi
done
