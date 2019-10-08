#!/bin/bash

num=8
while [ 1 ];do
	echo "Please input a number:"
	read user_num
	if [ $user_num -lt $num ];then
		echo "The number you inputed is lee then my NUMBER."
	elif [ $user_num -gt $num ];then
		echo "The number you inputed is greater then my NUMBER."
	elif [ $user_num -eq $num ];then
		echo "Congratulate: my NUMBER is $num."
		break
	fi
done
