#!/bin/bash
#导出两个版本快照之间每个仓库更新的每笔提交

PATHROOT=$(pwd)
XML_OLD="old.xml" 
XML_NEW="new.xml"

pushd ${PATHROOT}/.repo/manifests
#输出带有project的行到一个文件中
grep "project" $XML_OLD | sort -t' ' -k2 > old_project
grep "project" $XML_NEW | sort -t' ' -k2 > new_project
#将文件读入数组
readarray -t old_array < old_project
readarray -t new_array < new_project
#得到数组长度
old_length=${#old_array[@]}
old_real=$(($old_length - 1))
new_length=${#new_array[@]}
new_real=$(($new_length - 1))

#遍历老仓库
for i in `seq 0 $old_real`
do
	name_old=$(echo ${old_array[$i]} | grep -aoe "name=[a-zA-Z0-9\"\"\._]*")
	#查找旧的仓库名称是否存在new_project中，如果不存在，则该仓库已经删除
	grep -aoe "$name_old" new_project >> list1.txt
	if [ "$?" == 0 ];then
		FLAG=false
		#读取在新仓库存在的旧仓库的列表
		readarray -t list1_array < list1.txt
		for line in ${list1_array[$i]}
		do	
			#在新仓库中存在的所有旧名称
			NAME1=$(echo $line)
			if [ $NAME1 == $name_old ];then
				FLAG=true
				if [ $FLAG == "true" ];then
					#得到仓库名称，分支，以及commitId信息
					echo "true"
				else
					echo "false"
				fi
			fi
		done
	else
		echo "$name_old,的仓库已经删除"
	fi
	
done

#遍历新仓库
for i in `seq 0 $new_real`
do
	name_new=$(echo ${new_array[$i]} | grep -aoe "name=[a-zA-Z0-9\"\"\._]*")
	#查找新的仓库名称是否存在old_project中，如果不存在，则为新增仓库
	grep -aoe "$name_new" old_project >> list2.txt
	if [ "$?" == 0 ];then
		FLAG=false
		#在旧仓库中存在的新仓库的列表
		readarray -t list2_array < list2.txt
		for line in ${list2_array[@]}
		do
			#在新仓库中存在的旧仓库的名称
			NAME2=$(echo $line)
			if [ $NAME2 == $name_new ];then
				FLAG=true
				if [ $FLAG == "true" ];then
					#得到仓库名称，分支，以及commitId信息
					echo "true"
				else
					echo "false"
				fi
			fi
		done
	else
		echo "$name_new,的仓库是新增的"
	fi
done

#遍历
for i in `seq 0 $old_real`
do
	#得到仓库名称，分支，以及commitId信息
	old_name=$(echo ${old_array[$i]} | grep -aoe "name=[a-zA-Z0-9\"\"\._]*" | awk -F'"|"' '{print $2}')
	new_name=$(echo ${new_array[$i]} | grep -aoe "name=[a-zA-Z0-9\"\"\._]*" | awk -F'"|"' '{print $2}')

	old_upstream=$(echo ${old_array[$i]} | grep -aoe "upstream=[a-zA-Z\"\"]*" | awk -F'"|"' '{print $2}')
	new_upstream=$(echo ${new_array[$i]} | grep -aoe "upstream=[a-zA-Z\"\"]*" | awk -F'"|"' '{print $2}')

	old_revision_line=$(echo ${old_array[$i]} | grep -aoe "revision=[a-zA-Z0-9\"\"\._]*" | awk -F'"|"' '{print $2}')
	new_revision_line=$(echo ${new_array[$i]} | grep -aoe "revision=[a-zA-Z0-9\"\"\._]*" | awk -F'"|"' '{print $2}')
	if [ "$old_name" == "$new_name" ];then
		if [ "$old_upstream" == "$new_upstream" ];then
			cd ${PATHROOT}
			if [ -d $old_name ];then
				cd $old_name
				#得到两笔提交中的提交信息
				git log --pretty=oneline ${old_revision_line}..${new_revision_line} | tee log.txt
				cd -				
			fi
			cd -
		fi
	fi
done
popd
find . -name "log.txt" | xargs cat | tee -a log.txt

