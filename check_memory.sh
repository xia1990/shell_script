#!/bin/bash
#检测内存空间

FreeMem=$(free -m | grep "cache:" | awk '{print $3}')
echo $FreeMem
if [ "$FreeMem" > 100 ];then
	echo "当前剩余内存为:" $FreeMem
else
	echo "内存不足"
fi
