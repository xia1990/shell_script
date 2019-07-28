#!/bin/bash

rm -rf project.list
for i in `ls`
do
	if [[ -d "$i" && "$i" != "out" ]];then

		git init --bare "$i".git
		pushd "$i" > /dev/null
		basename "$i" | tee -a ../project.list
		rm -rf .git
		git init
		git add -A
		git commit -m "init git repository"
		git remote add origin ../"$i".git
		git push origin master
		popd > /dev/null
		rm -rf "$i"
	fi
done
