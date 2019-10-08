#!/bin/bash

if [ "$#" -eq "2" ];then
	for f in *.$1;do mv $f `basename $f .$1`.$2;done
else
	echo "Usage:$0 <SUFFIX1><SUFFIX2>"
	echo "Example: $0 txt doc"
fi
