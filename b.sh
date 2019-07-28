#!/bin/bash

echo -n "input string :"
read STR
LEN=`echo $STR | wc -c`
COLS=`tput cols`
NEW_COL=`expr \($COLS - $LEN \) / 2`
xy 10 $NEW_COL
echo $STR

