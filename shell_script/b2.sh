#!/bin/bash
#成批添加50个用户

for (( num=1;num<=50;num++ ))
do
	if ((num<10));then
		st="st0$num"
	else
		st="st$num"
	fi
	useradd $st
	passwd -d $st
done
