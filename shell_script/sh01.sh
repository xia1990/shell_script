#!/bin/bash

uni_prompt(){
	if [ `echo "\007"` = "\007" ] > /dev/null 2>&1
	then
		echo -e -n "$@"
	else
		echo "$@\c"
	fi
}
uni_prompt
