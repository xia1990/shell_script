#!/bin/sh
i=0
s=0
while [ $i -lt 100 ]
do
	i=`expr $i + 1`
	s=`expr $s + $i`
done
echo sum\(1..100\)=$s
