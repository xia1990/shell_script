#!/bin/bash

EXT=""
TRCASE=""
FLAG=""
OPT="no"
VERBOSE="off"

while getopts : luv OPTION
do
	case $OPTION in
		l) TRCASE="lower"
		EXT=".LC"
		OPT=yes
		;;
		u) TRCASE="upper"
		EXT=".UC"
		OPT=yes
		;;
		v) VERBOSE=on
		;;
		\?) echo "usage: `basename $0`: -[l|u] --v file[s]"
		exit 1 ;;
	esac 
done	
shift `expr $OPTIND - 1`
if [ "$#" = "0" ] || [ "$OPT" = "no" ]
then
	echo "usage:`basename $0`: -[l|u] -v file[s]" >&2
	exit 1
fi
for LOOP in "$@"
do
	if [ ! -f $LOOP ]
	then
		echo "`basename $0`:Error cannot find file $LOOP" >&2
		exit
	fi
	echo $TRCASE $LOOP
	case $TRCASE in
		lower) 
		if [ "VERBOSE" = "on" ];then
		echo "doing..lower on $LOOP..newfile called $LOOP$EXT"
		fi
		cat $LOOP | tr "[a-z]" "[A-Z]" > $LOOP$EXT
		;;
		upper) 
		if [ "VERBOSE" = "on" ];then
		echo "doing upper on $LOOP..newfile called $LOOP$EXT"
		fi
		cat $LOOP | tr "[A-Z]" "[a-z]" > $LOOP$EXT
		;;
	esac
done	
	
