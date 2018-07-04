#!/bin/bash
#此脚本用来得到两个快照之间的提交release_note

PATHROOT=$(pwd)
PROJECT="JA32_BSP"
OLD_XML=$1
NEW_XML=$2

function diff_file(){
	pushd ${PATHROOT}/$PROJECT/.repo/manifests
		rm -rf diff_file.txt
		repo diffmanifests $OLD_XML $NEW_XML | grep "changed from" > diff_file.txt
		cp diff_file.txt ${PATHROOT}/$PROJECT/
	popd
}

#得到所有commitID
function get_commit(){
	pushd ${PATHROOT}/$PROJECT
		find . -name "log.txt" | xargs rm -rf 
		rm -rf commit.txt
		#得到仓库名称，开始commit,结束commit
		while read line
		do
			PROJECT_NAME=$(echo $line | awk '{print $1}')
			#echo $PROJECT_NAME
			BEGIN_COMMIT=$(echo $line | awk '{print $4}')
			#echo $BEGIN_COMMIT
			END_COMMIT=$(echo $line | awk '{print $NF}')
			#echo $END_COMMIT
			pushd ${PATHROOT}/$PROJECT/$PROJECT_NAME
				git log --pretty=format:"%H" $BEGIN_COMMIT..$END_COMMIT | grep -v "Merge" >> log.txt
			popd	
		done < diff_file.txt
		find . -name "log.txt" | xargs cat | tee -a commit.txt
	popd
}


function get_release_note(){
	pushd ${PATHROOT}/$PROJECT
		rm -rf release_notes.txt
		readarray -t xml_array < commit.txt
		for line in "${xml_array[@]}"
		do
			export COMMITID=$line
			CHANGE_ID=$(repo forall -c 'git log $COMMITID -1 2>/dev/null' | grep "Change-Id" | awk -F':' '{print $2}')
			echo "change_id:"$CHANGE_ID
			MESSAGE=$(repo forall -c 'git log $COMMITID --pretty=format:"%s" -1 2>/dev/null')
			echo "message:"$MESSAGE
			FILES=$(repo forall -c 'git log $COMMITID --pretty=format:"" --name-status -1 2>/dev/null')
			echo $FILES
			echo -e "$CHANGE_ID\t$MESSAGE\t$FILES" >> change_list.txt
		done
	popd
}

##################
if [ $# -eq 2 ];then
	diff_file
	get_commit
	get_release_note
else
	echo "please input two args"
fi
