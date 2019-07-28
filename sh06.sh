#!/bin/bash
#此脚本用来给文件添加行号

number_file(){
	_FILENAME=$1 
	if [ $# -ne 1 ];then
		echo "number_file: I need a filename to number"
		return 1
	fi

	loop=1 #行号初始化为1
	while read LINE #读取每一行
	do
		echo "$loop: $LINE"
		loop=`expr $loop + 1`
	done < $_FILENAME
}

number_file "$1"
