#!/bin/bash
#测试目录创建结果

DIRECTORY=$1
if [ "$DIRECTORY" = "" ]
then
	echo "Usage : `basename $0` directory to create" >&2
	exit 1
fi

if [ -d $DIRECTORY ]
then : #do nothing
else
	echo "The directory does exist"
	echo -n "Create it now? [y..n] :"
	read ANS
	if  [ "$ANS" = "y" ] || [ "$ANS" = "Y" ]
	then
		echo "creating now"
		mkdir $DIRECTORY >/dev/null 2>&1
		if [ $? != 0 ];then
			echo "Errors creating the directory $DIRECTORY" >&2
			exit 1
		fi
	else : #do nothing
	fi
fi



