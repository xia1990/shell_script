#!/bin/bash

ALL=false
HELP=false
FILE=false
VERBOSE=false
COPIES=0

while getopts : ahfgvc : OPTION
do
	case $OPTION in
		a) ALL=true
		echo "ALL is $ALL"
		;;
		h) HELP=true
		echo "HELP is $HELP"
		;;
		f) FILE=true
		echo "FILE is $FILE"
		;;
		v) VERBOSE=true
		echo "VERBOSE is $VERBOSE"
		;;
		c) COPIES=$OPTARG
		echo "COPIES is $COPIES"
		;;
		\?) echo "`basename $0` -[a h f v] -[c value] file" >&2
		;;
	esac
done
