#!/bin/bash

uni_prompt(){
	if [ `echo "Z\c"` = "Z" ] > /dev/null 2>&1
	then
		echo "$@\c"
	else
		echo -e -n "$@"
	fi
}
uni_prompt
