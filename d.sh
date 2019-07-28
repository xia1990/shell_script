#!/bin/bash
#颜色配置表

colour(){
	case $1 in
		black_green)
		echo '^[[40;32m'
		;;
		black_yellow)
		echo '^[[40;33m'
		;;
		black_white)
		echo '^[[40;37m'
		;;
		black_cyan)
		echo '^[[40m;36m'
		;;
		red_yellow)
		echo '^[[41;32m'
		;;
		black_blue)
		echo '^[[40;34m'
		;;
	esac
}
colour "$1"
