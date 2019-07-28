#!/bin/bash
((i=0,s=0))
until ((i==100));do ((i++,s+=i));done
echo sum\(1..100\)=$s
