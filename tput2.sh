#!/bin/bash

BOLD=`tput bold`
REV=`tput rev`
NORMAL=`tput sgr0`
CURSOR_OFF=`tput civis`
CURSOR_ON=`tput cnorm`
tput init

echo $CURSOR_OFF
echo "${BOLD} WELCOME TO THE PIZZA PLACE${NORMAL}"
echo -e "\n${REV} WE ARE OPEN 7 DAYS A WEEK${NORMAL}"
echo $CURSOR_ON

