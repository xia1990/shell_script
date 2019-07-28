#!/bin/bash
cat files.txt | while read x
do
	scp user@remote:"\"$x\"".
done
