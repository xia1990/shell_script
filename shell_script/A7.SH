#!/bin/bash
#将当前目录下的所有小写文件名改为大写文件名

for fname in *;do
	fn=$(echo $fname | tr a-z A-Z)
	[[ $fname == $fn ]] && mv $fname $fn
	if [[ $fname != $fn ]];then mv $fname $fn;fi
done
