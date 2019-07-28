#!/bin/bash
ROOT_PATH=`pwd`
NEW_BRANCH_NAME="PDU3_MTK_BRH"
SERVER="10.0.30.8"
CODE_PREFIX="GR6750_66_A_O_ASUS_SW3"

repoc list > name_path.txt
while read line
do
	name=`echo $line | awk -F ' : ' '{print $2}'`
	path=`echo $line | awk -F ' : ' '{print $1}'`
	if [ -d "$path" ]
	then
		pushd $path > /dev/null
			pwd
			git ls-remote git@"$SERVER":"$CODE_PREFIX"/${name} -b "$NEW_BRANCH_NAME" > branch_commit_message.txt
			if [ "$?" != 0 ]
			then
				echo git@"$SERVER":"$CODE_PREFIX"/${name} >> ${ROOT_PATH}/no_name.txt #本次更新新增仓库
				echo "ls-remote failed!!!!"
			else
				remote_commit_id=$(cat branch_commit_message.txt | awk '{print $1}')
				rm branch_commit_message.txt
				local_commit_id=$(git log --format=%H -1)
				if [ "$remote_commit_id" == "$local_commit_id" ]
				then
					:
                else
					git push git@"$SERVER":"$CODE_PREFIX"/${name} HEAD:"$NEW_BRANCH_NAME"
					[ "$?" != 0 ] && echo "$name" "$path" >> ${ROOT_PATH}/push_failed.txt
					echo $name $path >> ${ROOT_PATH}/update_projects.txt
				fi
			fi
		popd > /dev/null
	else
		echo "$path" >> ${ROOT_PATH}/error_path.txt #代码缺失
	fi
done < name_path.txt
