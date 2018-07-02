#!/bin/bash
#收集release_note信息
#此脚本需先使用repo diffmenifests old.xml new.xml,生成diff_file.txt文件

PATHROOT=$(pwd)
PROJECT="JA32_BSP"

#得到仓库名称，开始commit,结束commit
grep "changed from" "$1" | awk '{print $1,$4,$6}' > file.txt
readarray -t file_array < file.txt
for line in "${file_array[@]}"
do
	name=$(echo $line | awk '{print $1}')
	echo $name
	begincommit=$(echo $line | awk '{print $2}')
	echo $begincommit
	endcommit=$(echo $line | awk '{print $NF}')
	echo $endcommit
	pushd ${PATHROOT}/$PROJECT/$name
	pwd
		git log --pretty=format:"%H   %an  %s" $begincommit..$endcommit | grep -v "Merge" > release_note.txt
	popd
done
find . -name "release_note.txt" | xargs cat | tee -a release_note
