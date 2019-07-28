#!/bin/bash
#收集版本的release_note信息

commit_old="$1"
commit_new="$2"

#得到两个commitId之间的:commitId,author,message
git log "$commit_old".."$commit_new" --pretty=format:"%H %an %s" | grep -v "Merge" | grep -v "Modfiy Version" | awk '{print $0}' > log.txt

readarray -t log_array < log.txt
length=${#log_array[@]}
real_length=$(($length - 1))
echo $real_length
for i in `seq 0 $real_length`
do
	commitId=$(echo ${log_array[$i]} | awk '{print $1}')
	changeId=$(git log $commitId -1 | grep "Change-Id" | awk -F':' '{print $2}')
	echo $changeId
	author=$(git log $commitId -1 | grep "Author" | awk -F' ' '{print $2}')
	echo $author
	message=$(git log $commitId --pretty=format:"%s" -1)
	echo $message
	echo -e "$changeId\t$author\t$message" >> result.txt
done
