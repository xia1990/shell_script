#!/bin/bash

QUITE=n
DEVICE=awa
LOGFILE=/tmp/logbackup

usage(){
	echo "Usage: `basename $0` -d [device] -l [logfile] -q"
	exit 1
}

if [ $# = 0 ];then
	usage
fi

while getopts :qd:l:OPTION
do
	case $OPTION in
		q) QUIET=y
		LOGFILE="/tmp/backup.log"
		;;
		d) DEVICE=$OPTARG
		;;
		l) LOGFILE=$OPTARG
		;;
		\?) usage
		;;
	esac
done
echo "you chose the following options..I can now process these"
echo "Quite=$QUITE $DEVICE $LOGFILE"
