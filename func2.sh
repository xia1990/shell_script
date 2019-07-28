#!/bin/bash

char_name(){
	_LETTERS_ONLY=$1
	_LETTERS_ONLY=`echo $1|awk '{if($0~/[^a-zA-Z]/) print "1"}'` #如果名字在小写与大写字母之间，打印
	if [ "$_LETTERS_ONLY" != "" ] 
	then
		return 1
	else
		return 0
	fi
}

name_error(){
	echo "$@ contains errors,it must contain only letters" 
}

#脚本从此处开始执行
while :
do
	echo -n "What is your first name :" #输入你的第一个名字
	read F_NAME #读取输入的名字
	if char_name $F_NAME 
	then
		break
	else
		name_error $F_NAME
	fi
done

while :
do
	echo -n "What is your surname :"
	read S_NAME
	if char_name $S_NAME
	then
		break
	else
		name_error $S_NAME
	fi
done


