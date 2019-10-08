#!/bin/bash
#此脚本用来修改XML文件
#将XML中revision!=dev的全部删除


XML_NAME="gaoyuxia.xml"
NEW_BRANCH="gaoyuxia"

readarray -t xml_array < "$XML_NAME"
for line in "${xml_array[@]}"
do
    echo $line | grep -aoe "project"
    if [ "$?" == 0 ];then #如果存在project
	    revision_line=$(echo $line | grep -aoe "revision=[a-zA-Z0-9\"\"\._]*")
	    echo $line | grep -aoe "default"
		#在满足<default remote="origin1" revision="dev"/>的情况下
        if [ "$?" == 0 ];then
            echo $line | tee -a local.xml
        elif [ -z "$revision_line" ];then #没有revision属性，则使用默认值，这里为dev,所以也输出
            echo $line | tee -a local.xml
	    elif [ "$revision_line" == 'revision="dev"' ];then #如果是dev，则输出
	        echo $line | tee -a local.xml
  	    else #如果不是dev，则输出为空（等同于删除的效果）
	        echo ""
	    fi
    else
	    echo $line | tee -a local.xml
    fi
done
mv local.xml $XML_NAME
