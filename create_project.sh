#!/bin/bash
#创建仓库

IP="192.168.56.101"
BRANCH_NAME="master"

function create_project(){
	for i in `cat project_name.txt`
	do
		ssh -p 29418 $IP gerrit create-project $i --empty-commit -b $BRANCH_NAME -t FAST_FORWARD_ONLY -p All-Projects
		echo $i":创建完成"
		sleep 1s
	done
}

##########################
create_project
