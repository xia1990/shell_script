#!/bin/bash

read_a_char(){
	SAVEDSTTY=`stty -g`
	stty cbreak
	stty -cbreak
	stty $SAVEDSTTY
}

echo -n "Hit Any Key To Continue"
character=`read_a_char`
echo "In case you are wondering you pressed $character"
