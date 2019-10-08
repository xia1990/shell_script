#!/bin/bash
#将原始XML中name='a,c,e,f'的revision的值改成"gaoyuxia",
#如果没有revision选项，就添加revision="gaoyuxia"
#有就修改


XML_NAME="gaoyuxia.xml"
NEW_BRANCH="gaoyuxia"

readarray -t xml_array < $XML_NAME
for line in "${xml_array[@]}"
do
	#如果name=[a|c|e|f]
    echo $line | grep -aoe "name=\"[a|c|e|f]\""
    if [ "$?" == 0 ];then
        revision_line=$(echo $line | grep -aoe "revision=[a-zA-Z0-9\"\"\._]*")
        if [ -z "$revision_line" ];then
		    #添加revision=gaoyuxia
            echo "$line" | sed -n "s/revision=[a-zA-Z0-9\"\"\._]*/& revision=\"$NEW_BRANCH\"/"p | tee -a local.xml
        else
		    #修改revision的值
            echo "$line" | sed -n "s/revision=[a-zA-Z0-9\"\"\._]*/revision=\"$NEW_BRANCH\"/g"p | tee -a local.xml
	    fi
    else
        echo "$line" | tee -a local.xml
    fi
done
mv local.xml $XML_NAME
