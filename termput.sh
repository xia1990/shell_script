#!/bin/bash

tput init
clear
echo " tput <> terminfo"
infocmp -1 $IERM | while read LINE
do
	case $LINE in
		bel*) echo "$LINE: sound the bell" ;;
		blink*) echo "$LINE: begin blinking mode" ;;
		bold*) echo "$LINE: make it bold" ;;
		el*) echo "$LINE: clear to end of line" ;;
		civis*) echo "$LINE: turn cursor off" ;;
		cnorm*) echo "$LINE: turn cursor on" ;;
		clear*) echo "$LINE: clear the screen" ;;
		kcuul*) echo "$LINE: up arrow " ;;
		kcubl*) echo "$LINE: left arrow " ;;
		kcuf1*) echo "$LINE: right arrow " ;;
		kcud1*) echo "$LINE: down arrow " ;;
	esac
done
