#!/bin/bash

check_length(){
	_STR=$1
	_MAX=$2
	if [ $# -ne 2 ];then
		echo "check_length:I need a string and max length the string should be"
		return 1
	fi
	_LENGTH=`echo $_STR | awk '{print length($0)}'`
	if [ "$_LENGTH" -gt "$_MAX" ];then
		return 1
	else
		return 0
	fi
}

while :
do
	echo -n "Enter your FIRST name :"
	read NAME
	if check_length $NAME 10
	then
		break
	else
		echo "The name field is too long 10 characters max"
	fi
done
