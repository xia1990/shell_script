#!/bin/bash
#打快照


PATHROOT=$(pwd)
PROJECT="JA32_BSP"
XML="default.xml"
PREFIX="JA32_BSP/android/"

function do_snapshot(){
	pushd ${PATHROOT}/$PROJECT/.repo/manifests
	rm -rf local.xml
	
	readarray -t xml_array < $XML
	for line in "${xml_array[@]}"
	do
		echo $line | grep -aoe "<project" >/dev/null
		if [ "$?" == 0 ];then
			fetch_name=$(grep -aoe "fetch=[.a-z_A-Z0-9:\"/-]*" $XML | awk -F'"' '{print $2}')
			echo $fetch_name
			#默认的分支名称
			default_revision=$( grep -aoe "revision=[.a-z_A-Z0-9\"/-]*" $XML | awk -F'"' '{print $2}')
			echo $default_revision 
			#得到仓库名称
			project_name=$(echo $line | grep -aoe "name=[.a-z_A-Z0-9\"/-]*" | awk -F'"' '{print $2}')		
			echo $project_name >> name.txt
			#得到分支名称
			branch_name=$(echo $line | grep -aoe "revision=[.a-z_A-Z0-9\"/-]*" | awk -F '"' '{print $2}')
			echo $branch_name
			#如果没有分支名称，就使用默认分支名称
			if [ "$branch_name" == "" ];then
				echo $default_revision
				branch_name=$default_revision
				echo $branch_name >> branch.txt
				echo "仓库名称："$branch_name
			fi
			#得到每个仓库的最新的commitID
			commitID=$(git ls-remote $fetch_name$PREFIX$project_name -b $branch_name | awk '{print $1}')
			echo $commitID >> commit.txt
			#修改XML文件，并添加commitID,和分支名称
			#echo $line | sed -n "s/path=[.a-z_A-Z0-9\"/-]*/& revision=\"$commitID\"/g"p | sed -n "s/revision=[.a-z_A-Z0-9\"/-]*/& upstream=\"$branch_name\"/g"p | tee -a local.xml
			echo $line | sed -n "s/name=[.a-z_A-Z0-9\"/-]*/& revision=\"$commitID\"/g"p | sed -n "s/revision=[.a-z_A-Z0-9\"/-]*/& upstream=\"$branch_name\"/g"p | tee -a local.xml
		else
			echo $line | tee -a local.xml		
		fi
	done
	popd
}

#######################
do_snapshot
