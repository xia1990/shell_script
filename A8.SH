#!/bin/bash

if [ "$#" -ne "1" ];then
	echo "Usage:$0 <directory>"
	exit 1
fi
for i in `ls $1`;do mv $i $(echo $i | tr [A-Z] [a-z]);done
