#!/bin/bash

str_to_upper(){
	_STR=$1
	if [ $# -ne 1 ];then
		_STR=$1
		if [ $# -ne 1 ];then
			echo "number_file:I need a string to convert please"
			return 1
		fi
	
		echo $@ | tr '[a-z]' '[A-Z]'
	fi
}
str_to_upper "$1"
