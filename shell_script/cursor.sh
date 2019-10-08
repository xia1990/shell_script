#!/bin/bash

_OPT=$1
if [ $# -ne 1 ];then
	echo "Usage:`basename $0` cursor [on|off]"
	exit 1
fi

case "$_OPT" in
	on|ON|On) 
	ON=`echo ^[[?25h]]`
	echo $ON
	;;
	off|OFF|Off)
	OFF=`echo ^[[?25]]`
	echo $OFF
	;;
	*) echo "Usage: cursor on|off"
	exit 1
	;;
esac
