#!/bin/bash

months(){
	_MONTH=$1
	if [ $# -ne 1 ];then
		echo "months:I need a number 1 to 12"
		return 1
	fi

	case $_MONTH in
		1|01|Jan) _FULL="January" ;;
		2|02|Feb) _FULL="February" ;;
		3|03|Mar) _FULL="March" ;;
		4|04|Apr) _FULL="April" ;;
		5|05|May) _FULL="May" ;;
		6|06|Jun) _FULL="June" ;;
		7|07|Jul) _FULL="July" ;;
		8|08|Aug) _FULL="August" ;;
		9|09|Sep|Sept) _FULL="September" ;;
		10|Oct) _FULL="October" ;;
		11|Nov) _FULL="November" ;;
		12|Dec) _FULL="December" ;;
		*) echo "months:Unknown month"
		return 1
		;;
	esac
	echo $_FULL
}
months "$1"
MY_MONTH=`months 06`
echo "Generating the Report for Month End $MY_MONTH"

