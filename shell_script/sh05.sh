#!/bin/bash

whois(){
	if [ $# -lt 1 ];then
		echo "whois : need user id's please"
		return 1
	fi

	for loop
	do
		_USER_NAME=`grep $loop /etc/passwd | awk -F: '{print $4}'`
		if [ "$_USER_NAME" = "" ];then
			echo "whois:Sorry cannot fine $loop"
		else
			echo "$loop is $_USER_NAME"
		fi
	done
}
whois "username" "uid"
