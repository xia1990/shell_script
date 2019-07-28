#!/bin/bash

_CODE="comet"
_FULLBACKUP="yes"
_LOGFILE="/logs/backup/"
_DEVICE="/dev/rmt/0n"
_INFORM="yes"
_PRINT_STATS="yes"

if [ -r backfunc ];then
	./backfunc
else
	echo "$`basename $0` cannot locate backfunc file"
fi

echo -n "Enter the code name :"
read CODE
if [ "${CODE}" != "${_CODE}" ];then
	echo "Wrong code...exiting..will use defaults"
	exit 1
fi

echo "The environment config file reports"
echo "Full Backup Required	:$_FULLBACKUP"
echo "The Logfile Is		:$_LOGFILE"
echo "The Device To Backup To is	:$_DEVICE"
echo "You Are To Be Informed by Mail	:$_INFORM"
echo "A Statistic Report To Be Printed 	:$_PRINT_STATS"

