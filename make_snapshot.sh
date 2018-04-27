#!/bin/bash

PATHROOT=$(pwd)

#得到default.xml中fetch的值
function get_fetch_and_name(){
	repo init -u /media/hw5t/gaoyuxia/shell_test/mirror/manifest.git -m default.xml -b master
	pushd ${PATHROOT}/.repo/manifests
		rm -rf project_name.txt project_revision.txt
		default_revision=$(grep -w "default" default.xml | grep -aoe "revision=[a-zA-Z0-9\"]*" | awk -F'"' '{print $2}')
		#echo $default_revision
		readarray -t xml_array < default.xml
		for line in "${xml_array[@]}"
		do
			echo $line | grep -aoe "project"
			if [ "$?" == 0 ];then
				#将项目名称输出到一个文件中
 				echo $line | grep -aoe "name=[a-z\"]*" | awk -F'"' '{print $2}' >> project_name.txt
				revision_line=$(echo $line | grep -aoe "revision=[a-zA-Z0-9\"]*" | awk -F'"' '{print $2}')
				echo $revision_line
				if [ -z "$revision_line" ];then
					#如果分支名称不存在，则使用默认分支名称
					revision_line=$default_revision
					echo $revision_line >> project_revision.txt
				else
					#将分支名称输出到一个文件中
					echo $line | grep -aoe "revision=[a-zA-Z0-9\"]*" | awk -F'"' '{print $2}' >> project_revision.txt
				fi
			fi
		done
	popd
}


function prepare_to_do_snapshot(){
	pushd ${PATHROOT}/.repo/manifests
		#将项目名称和分支名称输出到一个文件中
		paste project_name.txt project_revision.txt > project_list.txt
		rm -rf message.txt project_revision.txt
		fetch_name=$(grep -aoe "fetch=[a-z0-9\/\_\"]*" default.xml | awk -F'"' '{print $2}')
		#echo $fetch_name
		while read n
		do
			project_name=$(echo $n | awk '{print $1}')
			#echo $project_name
			branch_name=$(echo $n | awk '{print $2}')
			#echo $branch_name
			#得到所有项目对应分支的最新提交信息
			git ls-remote $fetch_name$n -b $branch_name >> message.txt
		done < project_list.txt
	popd
}


function do_snapshot(){
	pushd ${PATHROOT}/.repo/manifests
		#得到项目名称，commitID,分支名称并输出到一个文件中
		paste project_name.txt message.txt > info.txt
		rm -rf local.xml project_name.txt message.txt project_list.txt
		readarray -t xml_array < default.xml
		for m in "${xml_array[@]}"
		do
			echo $m | grep -aoe "project"
			if [ "$?" == 0 ];then
				revision=$(echo $m | grep -aoe "revision=[a-zA-Z0-9\"]*")
				#如果没有revision
				if [ -z "$revision" ];then
					name=$(echo $m | grep -aoe "name=[a-zA-Z\"]*"  | awk -F'"' '{print $2}')
					echo $name
					branch_name=$(grep -w "$name" info.txt | awk '{print $NF}' | awk -F'/' '{print $NF}')
					echo $branch_name
					commitID=$(grep -w "$name" info.txt | awk '{print $2}')
					echo $commitID
					#添加revision的值，并添加分支名称
					echo $m | sed -n "s/name=[a-zA-Z0-9\"]*/& revision=\"$commitID\"/g"p | sed -n "s/revision=[a-zA-Z0-9\"]*/& upstream=\"$branch_name\"/"p | tee -a local.xml
				else
					name=$(echo $m | grep -aoe "name=[a-zA-Z\"]*"  | awk -F'"' '{print $2}')
					echo $name
					branch_name=$(grep -w "$name" info.txt | awk '{print $NF}' | awk -F'/' '{print $NF}')
					echo $branch_name
					commitID=$(grep -w "$name" info.txt | awk '{print $2}')
					echo $commitID
					#修改revision的值，并添加分支属性
					echo $m | sed -n "s/revision=[a-zA-Z0-9\"]*/revision=\"$commitID\"/g"p | sed -n "s/revision=[a-zA-Z0-9\"]*/& upstream=\"$branch_name\"/"p | tee -a local.xml
				fi
			else
				echo $m | tee -a local.xml
			fi
		done
		mv local.xml snapshot.xml
	popd
}


########## MAIN ###########
function main(){
	get_fetch_and_name
	prepare_to_do_snapshot
	do_snapshot
}
main "$@"

