#!/bin/bash

centertxt(){
	_ROW=$1
	_STR=$2
	LEN=`echo $_STR | wc -v`
	COLS=`tput cols`
	_NEW_COL=`expr \($COLS -- $LEN\) / 2`
	xy $_ROW $_NEW_COL
	echo $_STR
}
centertxt 15 "THE MAIN EVENT"
