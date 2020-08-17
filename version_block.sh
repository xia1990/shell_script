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
#数组长度减一
old_real=$(($array_length - 1))
new_length=${#new_array[@]}
new_real=$(($new_length - 1))

#遍历老仓库
for i in `seq 0 $old_real`
do
	#得到老仓库名称
	name_old=$(echo ${old_array[$i]} | grep -aoe "name=[a-zA-Z0-9\"\"\._]*" | awk -F'"|"' '{print $2}')
	echo $name_old
	name_new=$(echo ${new_array[$i]} | grep -aoe "name=[a-zA-Z0-9\"\"\._]*" | awk -F'"|"' '{print $2}')
	echo $name_new
	#如果仓库名称相同
	if [ $name_old == $name_new ];then
		#得到仓库的分支
		old_upstream=$(echo ${old_array[$i]} | grep -aoe "upstream=[a-zA-Z\"\"]*" | awk -F'"|"' '{print $2}')
		echo $old_upstream
		new_upstream=$(echo ${new_array[$i]} | grep -aoe "upstream=[a-zA-Z\"\"]*" | awk -F'"|"' '{print $2}')
		echo $upstream
		#如果是同一个分支
		if [ $old_upstream == $new_upstream ];then
			#得到仓库commitID
			old_revision_line=$(echo ${old_array[$i]} | grep -aoe "revision=[a-zA-Z0-9\"\"\._]*" | awk -F'"|"' '{print $2}')
			echo $old_revision_line
			new_revision_line=$(echo ${new_array[$i]} | grep -aoe "revision=[a-zA-Z0-9\"\"\._]*" | awk -F'"|"' '{print $2}')
			echo $new_revision_line
			cd ${PATHROOT}	
			if [ -d ${name_old} ];then
				cd $name_old
				#得到两个commitID之间的所有提交
				git log --pretty=oneline ${old_revision_line}..${new_revision_line} | tee log.txt
				cd -
			fi
			cd -
		else
			#如果是不同分支，则报错
			echo "error...."
		fi
	#仓库名称不同，则无法做判断
	else
		echo "Waring..."
	fi
done
popd
#找到所有log文件，输出到一个文件中，汇总
find . -name "log.txt" | xargs cat | tee -a log.txt

