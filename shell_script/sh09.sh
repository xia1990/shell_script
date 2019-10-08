#!/bin/bash

is_lower(){
	if [ $# -ne 1 ];then
		echo "is_lower:I need a string to test OK"
		return 1
	fi
	_IS_LOWER=`echo $1|awk '{if($0~/[^a-z]/) print "1"}'`
	if [ "$_IS_LOWER" != "" ];then
		return 1
	else
		return 0
	fi
}

echo -n "Enter the filename:"
read FILENAME
if is_lower $FILENAME;then
	echo "Great it's lower case"
else
	echo "Sorry it's not lower case"
fi
echo $FILENAME
