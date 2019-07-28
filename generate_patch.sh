#!/bin/bash
#给一个ChangeId从gerrit查到，让它生成一笔patch

FILE="changeId.txt"
IP="192.168.0.88"


function get_gerrit_patch_message(){
	readarray -t change_array < $FILE
	for line in "${change_array[@]}"
	do
		changeId=$(echo $line)
		ssh -p 29418 $IP gerrit query --format=JSON --patch-sets change:$changeId | head -1 >>  json.txt
		PROJECT=$(cat json.txt | jq .project | sed -e 's/^"//g' | sed -e 's/"$//g' | tail -1)
		ref=$(cat json.txt | jq .patchSets[0].ref | sed -e 's/^"//g' | sed -e 's/"$//g' | tail -1)
		git fetch ssh://banan@$IP:29418/$PROJECT $ref && git checkout FETCH_HEAD
	done
}

#打patch
function do_patch(){
	#得到commitId
	git log --pretty=format:"%H" >> log.txt
	readarray -t log_array < log.txt
	for i in ${log_array[@]}
	do
		git format-patch -1 "$i" >> patch_name.txt
	done
}

#####################
get_gerrit_patch_message
do_patch
