#!/bin/bash

chop(){
	_STR=$1
	_CHOP=$2
	CHOP=`expr $_CHOP + 1`
	if [ $# -ne 2 ];then
		echo "check_length:I need a string and how many characters to chop"
		return 1
	fi
	_LENGTH=`echo $_STR | awk '{print length($0)}'`
	if [ "$_LENGTH" -lt "$_CHOP" ];then
		echo "Sorry you have asked to chop more characters than there are in the string"
		return 1
	fi
	echo $_STR | awk '{print  substr($1,'$_CHOP')}'
}
CHOPPED=`chop "Honeysuckle" 5`
echo $CHOPPED
