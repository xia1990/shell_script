#!/bin/bash

usage(){
	echo "usage:'basename $0' start|stop process name"
}

OPT=$1
PROCESSID=$1
if [ $# -ne 2 ]
then
	usage
	exit 1
fi
case $OPT in
	start|Start) echo "Starting..$PROCESSID" ;;
	stop|Stop) echo "Stopping..$PROCESSID" ;;
	*) usage ;;
esac
