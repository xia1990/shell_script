#!/bin/sh
#此函数用来将小写字母转换成大写字母

str_to_upper()
{
	_STR=$1
	if [ $# -ne 1 ];then
		echo "number_file:I need a string to convert please"
		return 1
	fi
	echo $@ | tr '[a-z]' '[A-Z]'
}
str_to_upper "documents.live"
