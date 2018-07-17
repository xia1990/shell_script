#!/bin/bash
#为XML文件添加PATH属性

XML="test.xml"

function add_path(){
	rm -rf local.xml
	readarray -t xml_array < $XML
	for line in "${xml_array[@]}"
	do
		echo $line | grep -aoe "<project" >/dev/null
		if [ "$?" == 0 ];then		
			echo $line | grep -aoe "path=[.a-z_A-Z0-9\"/-]*"
			if [ "$?" == 0 ];then
				echo $line | tee -a local.xml
			else
				name_line=$(echo $line | grep -aoe "name=[.a-z_A-Z0-9\"/-]*" | awk -F'"|"' '{print $2}')
				echo $name_line
				path_line=$(echo $line | grep -aoe "path=[.a-z_A-Z0-9\"/-]*" | awk -F'"|"' '{print $2}')
				echo $path_line
				if [ "$path_line" == "" ];then
					echo "没有path属性，进行添加"
					#new_name=$(echo ${name_line#*/})
					new_name=`echo ${name_line//\//\\\/}`
					echo $new_name
					sleep 1s
					#如果没有path,在name属性前添加path属性的值，path属性的值和name值一样
					#echo $line | sed -n "s:name=[.a-z_A-Z0-9\"/-]*:path=\"$new_name\" &:g"p | tee -a local.xml
					echo $line | sed -n "s/name=[.a-z_A-Z0-9\"/-]*/& path=\"$new_name\"/g"p | tee -a local.xml
				fi
			fi
		else
			echo $line | tee -a local.xml
		fi
	done	
	#mv local.xml $XML
}

add_path
