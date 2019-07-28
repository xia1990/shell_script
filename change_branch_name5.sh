#!/bin/bash
#除了a,c,e,f仓库，剩余仓库都拉出"gaoyuxia”分支

XML_NAME="gaoyuxia.xml"
NEW_BRANCH="gaoyuxia"

readarray -t xml_array < $XML_NAME
for line in "${xml_array[@]}"
do
    #查找仓库名称
    echo "$line" | grep -aoe "name=[a-zA-Z0-9\"\"\._]*"
    if [ "$?" == 0 ];then
	    #查找包含fetch的行
	    echo "$line" | grep -v "fetch"
        if [ "$?" == 0 ];then
		    #如果不是a,c,e,f仓库
            echo "$line" | grep -v "name=\"[a|c|e|f]\""
            if [ "$?" == 0 ];then
	            revision_line=$(echo "$line" | grep -aoe "revision=[a-zA-Z0-9\"\"\._]*")
                if [ -z "$revision_line" ];then
	                echo "$line" | sed -n "s/name=[a-zA-Z\"\"\._]*/revision=\"$NEW_BRANCH\"/"p | tee -a local.xml
	            else
	                echo "$line" | sed -n "s/revision=[a-zA-Z0-9\"\"\._]*/revision=\"$NEW_BRANCH\"/g"p | tee -a local.xml
                fi
	        else
               echo "$line" | tee -a local.xml
            fi
        else
	        echo "$line" | tee -a local.xml
        fi
    else	
	    echo "$line" | tee -a local.xml
    fi
done
mv local.xml $XML_NAME
