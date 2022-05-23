#!/bin/bash
#本脚本用来cherry-pick未入库的提交，并进行预编译操作


ROOTPATH=`pwd`
PROJECT_NAME="SM4250"
GERRIT_IP="192.168.56.101"
PORT="29418"
USER="ubuntu"

function pull_commit(){
	mkdir -p $ROOTPATH/$PROJECT_NAME
	pushd $ROOTPATH/$PROJECT_NAME > /dev/null
		#repo init -u ssh://"$USER"@"$GERRIT_IP":"$PORT"/manifest -m manifest.xml -b master --no-repo-verify
		#repo sync -j4
	
		#获取指定项目所有open状态的提交
		ssh -p "$PORT" "$GERRIT_IP" gerrit query branch:master project:^alps/.* status:open --format JSON --current-patch-set --files | egrep "project|number|revision|Depends-On" > message.txt

		#得到所有open状态的project name
		cat message.txt | jq .project | awk -F'"' '{print $2}' > project_name.txt
		#得到所有open状态的 refs/changes/42/242/1
		cat message.txt | jq .currentPatchSet.ref | awk -F '"' '{print $2}' > project_ref.txt
		#以上2条信息合并
		paste project_name.txt project_ref.txt > project_info.txt
		for name in `cat project_info.txt`
		do
			#根据name属性值 ，在xml中查找对应的path属性值 
			grep "$name" .repo/manifests/manifest.xml | grep "path" > /dev/null
			if [ "$?" == 0 ];then
				project_path=`grep "$name" .repo/manifests/manifest.xml | grep "path" | awk -F'"' '{print $4}'`
			else
				project_path=`grep "$name" .repo/manifests/manifest.xml | awk -F'"' '{print $2}'`
			fi
			
			change_url=`cat project_info.txt | grep "$name" | awk '{print $2}'`

			pushd ./$project_path > /dev/null
				git fetch ssh://"$USER"@"$GERRIT_IP":"$PORT"/"$name" "$change_url" && git cherry-pick FETCH_HEAD
			popd
		done		
	popd
}

###############################
pull_commit
