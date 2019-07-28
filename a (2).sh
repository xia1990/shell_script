#!/bin/bash

xy(){
	_R=$1
	_C=$2
	tput cup $_R $_C
}

clear
xy 1 5
echo -n "Enter your name :"
read NAME
xy 2 5
echo -n "Enter your age :"
read AGE

xy(){
	_R=$1
	_C=$2
	tput cup $_R $_C
	echo -n $_TEXT
}
