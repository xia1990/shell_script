#!/bin/bash

function push_project(){
	for line in `cat project_name.txt`
	do
		if [ -d "$line" ];then
			pushd $line
				git init
				git add .
				git commit -m "initial empty repository"
				git push ssh://192.168.56.101:29418/$line.git master
			popd
		fi
	done
}

########################
push_project
