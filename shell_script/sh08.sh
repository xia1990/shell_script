#!/bin/bash

is_upper(){
	if [ $# -ne 1 ];then
		echo "is_upper:I need a string to test OK"
		return 1
	fi
	_IS_UPPER=`echo $1|awk '{if($0~/[^A-Z]/) print "1"}'`
	if [ "$_IS_UPPER" != "" ];then
		return 1
	else
		return 0
	fi
}

echo -n "Enter the filename:"
read FILENAME
if is_upper $FILENAME;then
	echo "Great it's upper case"
else
	echo "Sorry it's not upper case"
fi
