#!/usr/bin/python
#coding:utf8
# 清除终端


import sys,os
osType=sys.platform
if osType=='linux' or osType=='linux2':
	command='clear'
else:
	command='cls'
os.system(command)
