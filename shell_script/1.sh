#!/bin/bash

str_to_lower(){
	if [ $# -ne 1 ];then
		echo "str_to_lower:I need a string to convert please"
		return 1
	fi
	echo $@ | tr '[A-Z]' '[a-z]'
}
LOWER=`str_to_lower "documents.live"`
echo $LOWER
