#!/bin/bash
readarray -t manifestarray < "$1"
for line in "${manifestarray[@]}"
do
	echo $line | grep '<project' > /dev/null
	if [ "$?" == 0 ]
	then
		name=`echo "$line" | grep -aoe "name=[.A-Z_a-z0-9\"/-]*" | awk -F '"' '{print $2}'`
		path=`echo "$line" | grep -aoe "path=[.A-Z_a-z0-9\"/-]*" | awk -F '"' '{print $2}'`
		if [ "$path" == ""  ]
		then
			echo 'no_path'
			zy_name=`echo ${name//\//\\\/}`
			echo $line| sed "s/name=[.A-Z_a-z0-9\"/-]*/& path=\"$zy_name\"/" >> new_manifest.xml
			if [ "$?" != 0  ]
			then
				sleep 20s
			fi
		else
			echo $line >> new_manifest.xml
		fi
	else
        echo $line | grep 'copyfile'
        copy_result="$?"
        echo $line | grep 'linkfile'
        link_result="$?"
        if [ "$copy_result" == "0" ] || [ "$link_result" == "0" ]
        then
            echo '    '$line >> new_manifest.xml
            echo "+空格"
        else
            echo $line >> new_manifest.xml
        fi
    fi
	unset name path line
	
done
