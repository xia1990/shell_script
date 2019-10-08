#!/bin/bash

if [ $# -lt 1 ];then
	echo "continue_prompt:I need a string to display"
	return 1
fi

while :
do
	echo -n "$_STR [Y..N] [$_DEFAULT]:"
	read _ANS
	if [ "$_ANS" = "" ];then
		case $_ANS in
			Y) return 0 ;;
			N) return 1 ;;
		esac
	fi
	
	case $_ANS in
		y|Y|yes|YES)	
			return 0
			;;
		n|N|no|NO)
			return 1
			;;
		*) echo "Answer either Y or N,default is $_DEFAULT"
		;;
	esac
	echo $_ANS
done	
