#!/bin/bash

ALL=false
HELP=false
FILE=false
VERBOSE=false

while getopts ahfgv OPTION
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
	esac
done
