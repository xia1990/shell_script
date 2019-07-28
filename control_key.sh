#!/bin/bash

uparrowkey='^[[A'
downarrowkey='^[[B'
leftarrowkey='^[[D'
rightarrowkey='^[[C'
f1key='^[OP'
f2key='^[oQ'

echo -n "Press a control key then hit return"
read KEY

case $KEY in
	$uparrowkey) echo "UP Arrow" ;;
	$downarrowkey) echo "DOWN arrow" ;;
	$leftarrowkey) echo "LEFT arrow" ;;
	$rightarrowkey) echo "RIGHT arrow" ;;
	$f1key) echo "F1 key" ;;
	$f2key) echo "F2 key" ;;
	*) echo "unknown key $key" ;;
esac
