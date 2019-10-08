#!/bin/bash
#修改XML文件，将所有revision=dev全部删除，但default行的revision保留

XML_NAME="gaoyuxia.xml"
NEW_BRANCH="gaoyuxia"

readarray -t xml_array < "$XML_NAME"
for line in "${xml_array[@]}"
do
    echo $line | grep -aoe "project"
    if [ "$?" == 0 ];then
	    revision_line=$(echo $line | grep -aoe "revision=[a-zA-Z0-9\"\"\._]*")
        echo $line | grep -aoe "default"
	    if [ "$?" == 0 ];then #如果是default的行，则直接输出
            echo $line | tee -a local.xml
		#如果revision=dev,则删除
	    elif [ "$revision_line" == 'revision="dev"' ];then 
	        echo ""
		#如果revision为空，则使用的是默认值，默认值是dev,所以也需要删除
	    elif [ -z "$revision_line" ];then 
	        echo ""
	    else #其它情况则输出
	        echo $line | tee -a local.xml
	    fi
    else
	    echo $line | tee -a local.xml
    fi    
done
mv local.xml $XML_NAME
