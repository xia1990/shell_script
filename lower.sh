#!/bin/sh
#此函数用来将大写字母转换成小写字母

str_to_lower()
{
	if [ $# -ne 1 ];then
		echo "str_to_lower:I need a string to convert please"
		return 1
	fi
	echo $@ | tr '[A-Z]' '[a-z]'
}
str_to_lower "LIFE"
