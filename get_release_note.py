#!/usr/bin/python
# -*- coding: UTF-8 -*-
#读取txt文件内容并写入到excel中
#

from pyExcelerator import *
import os
import re
import sys
w=Workbook()
#添加一个工作簿，并命名为:release note
ws = w.add_sheet('release note')

#列的下标，从1开始
j=1
ws.write(0,0,'CR ID')
ws.write(0,1,'Owner')
ws.write(0,2,'Headline')

#以只读的方式读取文件内容
f=open('release_note.txt','r')
#读取文件中的每一行
for eachLine in f:
	#以\t作为分隔符
	line=eachLine.split('\t')
	#根据下标得到对应的value
	CHANGE_ID=line[0]
	#写入工作簿中
	ws.write(j,0,CHANGE_ID)
	MESSAGE=line[1]
	ws.write(j,1,MESSAGE)
	FILES=line[2]
	ws.write(j,2,FILES)
	#列的下标每次循环，加1，因为列在增加
	j=j+1
#将读取的文件写入到excel表格中
w.save("release_note.xls")
#循环结束后，关闭文件
f.close()

